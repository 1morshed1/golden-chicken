import logging
from datetime import date, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.farm import FlockType, Shed
from app.models.insights import FarmInsight, InsightSeverity
from app.models.user import User
from app.repositories.farm_repository import FarmRepository, ShedRepository
from app.repositories.insights_repository import InsightRepository
from app.repositories.production_repository import (
    ChickenRecordRepository,
    EggRecordRepository,
)
from app.repositories.task_repository import TaskRepository

logger = logging.getLogger(__name__)

PRODUCTION_THRESHOLDS = {
    "egg_drop": {
        "warning": 10,
        "critical": 20,
        "action_warning": "Egg production dropped {pct}%. Check feed quality and water supply.",
        "action_critical": (
            "Significant egg production drop ({pct}%). Check for disease symptoms, "
            "feed contamination, or stress factors. Consider veterinary consultation."
        ),
    },
    "mortality_spike": {
        "warning": 2,
        "critical": 5,
        "action_warning": "Mortality rate elevated at {pct}%. Monitor flock closely for symptoms.",
        "action_critical": (
            "CRITICAL: Mortality rate {pct}%. Isolate affected birds immediately. "
            "Contact veterinarian."
        ),
    },
}

farm_repo = FarmRepository()
shed_repo = ShedRepository()
egg_repo = EggRecordRepository()
chicken_repo = ChickenRecordRepository()
task_repo = TaskRepository()
insight_repo = InsightRepository()


class InsightsService:
    async def get_insights(
        self,
        db: AsyncSession,
        user: User,
        *,
        severity: str | None = None,
        shed_id: str | None = None,
    ) -> dict:
        sev = InsightSeverity(severity) if severity else None
        insights = await insight_repo.get_user_insights(
            db, user.id, severity=sev, shed_id=shed_id
        )
        counts = await insight_repo.get_severity_counts(db, user.id)
        return {"insights": insights, "summary": counts}

    async def get_actions(self, db: AsyncSession, user: User) -> list[dict]:
        insights = await insight_repo.get_unresolved_actions(db, user.id)
        return [
            {
                "text": i.proposed_action,
                "priority": i.severity.value,
                "source": i.source,
                "insight_id": i.id,
            }
            for i in insights
            if i.proposed_action
        ]

    async def acknowledge_insight(
        self, db: AsyncSession, insight_id: str, user: User
    ) -> FarmInsight:
        insight = await insight_repo.get_by_id(db, insight_id)
        if not insight:
            raise NotFoundError("Insight")
        if insight.user_id != user.id:
            raise AuthorizationError()
        return await insight_repo.acknowledge(db, insight)

    async def resolve_insight(
        self, db: AsyncSession, insight_id: str, user: User
    ) -> FarmInsight:
        insight = await insight_repo.get_by_id(db, insight_id)
        if not insight:
            raise NotFoundError("Insight")
        if insight.user_id != user.id:
            raise AuthorizationError()
        return await insight_repo.resolve(db, insight)

    async def generate_daily_insights(
        self, db: AsyncSession, user_id: str
    ) -> list[FarmInsight]:
        insights: list[FarmInsight] = []
        farms = await farm_repo.get_user_farms(db, user_id)

        for farm in farms:
            for shed in farm.sheds:
                if not shed.is_active:
                    continue

                if shed.flock_type in (FlockType.LAYER, FlockType.MIXED):
                    insights.extend(
                        await self._check_egg_production(db, user_id, shed)
                    )

                insights.extend(
                    await self._check_mortality(db, user_id, shed)
                )

        insights.extend(await self._check_overdue_tasks(db, user_id))

        for insight in insights:
            db.add(insight)
        await db.flush()

        return sorted(
            insights,
            key=lambda i: {"critical": 0, "warning": 1, "info": 2}[i.severity.value],
        )

    async def _check_egg_production(
        self, db: AsyncSession, user_id: str, shed: Shed
    ) -> list[FarmInsight]:
        today = date.today()
        week_ago = today - timedelta(days=7)
        records = await egg_repo.get_by_shed_and_date_range(
            db, shed.id, date_from=week_ago, date_to=today
        )

        if len(records) < 3:
            return []

        avg_eggs = sum(r.total_eggs for r in records) / len(records)
        if avg_eggs == 0:
            return []

        latest = records[0]  # desc order
        pct_change = ((latest.total_eggs - avg_eggs) / avg_eggs) * 100

        thresholds = PRODUCTION_THRESHOLDS["egg_drop"]
        if pct_change <= -thresholds["critical"]:
            return [self._make_insight(
                user_id, shed.id,
                insight_type="egg_production_drop",
                title=f"Critical egg production drop in {shed.name}",
                description=f"Egg production dropped {abs(pct_change):.0f}% vs 7-day average.",
                severity=InsightSeverity.CRITICAL,
                proposed_action=thresholds["action_critical"].format(pct=f"{abs(pct_change):.0f}"),
                source="production_analysis",
            )]
        if pct_change <= -thresholds["warning"]:
            return [self._make_insight(
                user_id, shed.id,
                insight_type="egg_production_drop",
                title=f"Egg production declining in {shed.name}",
                description=f"Egg production dropped {abs(pct_change):.0f}% vs 7-day average.",
                severity=InsightSeverity.WARNING,
                proposed_action=thresholds["action_warning"].format(pct=f"{abs(pct_change):.0f}"),
                source="production_analysis",
            )]
        return []

    async def _check_mortality(
        self, db: AsyncSession, user_id: str, shed: Shed
    ) -> list[FarmInsight]:
        today = date.today()
        record = await chicken_repo.get_by_shed_and_date(db, shed.id, today)
        if not record or record.total_birds == 0:
            return []

        mortality_pct = (record.mortality / record.total_birds) * 100
        thresholds = PRODUCTION_THRESHOLDS["mortality_spike"]

        if mortality_pct >= thresholds["critical"]:
            return [self._make_insight(
                user_id, shed.id,
                insight_type="mortality_spike",
                title=f"CRITICAL mortality in {shed.name}",
                description=f"Mortality rate {mortality_pct:.1f}% ({record.mortality} birds).",
                severity=InsightSeverity.CRITICAL,
                proposed_action=thresholds["action_critical"].format(pct=f"{mortality_pct:.1f}"),
                source="production_analysis",
            )]
        if mortality_pct >= thresholds["warning"]:
            return [self._make_insight(
                user_id, shed.id,
                insight_type="mortality_spike",
                title=f"Elevated mortality in {shed.name}",
                description=f"Mortality rate {mortality_pct:.1f}% ({record.mortality} birds).",
                severity=InsightSeverity.WARNING,
                proposed_action=thresholds["action_warning"].format(pct=f"{mortality_pct:.1f}"),
                source="production_analysis",
            )]
        return []

    async def _check_overdue_tasks(
        self, db: AsyncSession, user_id: str
    ) -> list[FarmInsight]:
        overdue = await task_repo.get_overdue_tasks(db, user_id)
        if not overdue:
            return []

        vaccination_overdue = [t for t in overdue if t.task_type.value == "vaccination"]
        other_overdue = [t for t in overdue if t.task_type.value != "vaccination"]

        insights = []
        if vaccination_overdue:
            titles = ", ".join(t.title for t in vaccination_overdue[:3])
            insights.append(self._make_insight(
                user_id, None,
                insight_type="overdue_vaccination",
                title=f"{len(vaccination_overdue)} overdue vaccination(s)",
                description=f"Overdue: {titles}{'...' if len(vaccination_overdue) > 3 else ''}",
                severity=InsightSeverity.CRITICAL,
                proposed_action="Complete overdue vaccinations immediately to prevent disease outbreaks.",
                source="task_compliance",
            ))

        if len(other_overdue) >= 3:
            insights.append(self._make_insight(
                user_id, None,
                insight_type="overdue_tasks",
                title=f"{len(other_overdue)} overdue farm tasks",
                description=f"You have {len(other_overdue)} pending overdue tasks.",
                severity=InsightSeverity.WARNING,
                proposed_action="Review and complete overdue tasks in your task list.",
                source="task_compliance",
            ))

        return insights

    def _make_insight(
        self,
        user_id: str,
        shed_id: str | None,
        *,
        insight_type: str,
        title: str,
        description: str,
        severity: InsightSeverity,
        proposed_action: str,
        source: str,
    ) -> FarmInsight:
        return FarmInsight(
            user_id=user_id,
            shed_id=shed_id,
            insight_type=insight_type,
            title=title,
            description=description,
            severity=severity,
            proposed_action=proposed_action,
            source=source,
        )


insights_service = InsightsService()
