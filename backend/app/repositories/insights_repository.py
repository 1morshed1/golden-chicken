from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.insights import FarmInsight, InsightSeverity
from app.repositories.base import BaseRepository


class InsightRepository(BaseRepository[FarmInsight]):
    def __init__(self):
        super().__init__(FarmInsight)

    async def get_user_insights(
        self,
        db: AsyncSession,
        user_id: str,
        *,
        severity: InsightSeverity | None = None,
        shed_id: str | None = None,
        include_resolved: bool = False,
        offset: int = 0,
        limit: int = 50,
    ) -> list[FarmInsight]:
        stmt = select(FarmInsight).where(FarmInsight.user_id == user_id)

        if not include_resolved:
            stmt = stmt.where(FarmInsight.is_resolved == False)
        if severity:
            stmt = stmt.where(FarmInsight.severity == severity)
        if shed_id:
            stmt = stmt.where(FarmInsight.shed_id == shed_id)

        stmt = stmt.order_by(
            FarmInsight.severity,
            FarmInsight.created_at.desc(),
        ).offset(offset).limit(limit)

        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_severity_counts(
        self, db: AsyncSession, user_id: str
    ) -> dict[str, int]:
        stmt = (
            select(FarmInsight.severity, func.count())
            .where(
                and_(
                    FarmInsight.user_id == user_id,
                    FarmInsight.is_resolved == False,
                )
            )
            .group_by(FarmInsight.severity)
        )
        result = await db.execute(stmt)
        counts = {row[0].value: row[1] for row in result.all()}
        return {
            "critical": counts.get("critical", 0),
            "warning": counts.get("warning", 0),
            "info": counts.get("info", 0),
        }

    async def get_unresolved_actions(
        self, db: AsyncSession, user_id: str
    ) -> list[FarmInsight]:
        stmt = (
            select(FarmInsight)
            .where(
                and_(
                    FarmInsight.user_id == user_id,
                    FarmInsight.is_resolved == False,
                    FarmInsight.proposed_action.isnot(None),
                )
            )
            .order_by(FarmInsight.severity, FarmInsight.created_at.desc())
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def acknowledge(
        self, db: AsyncSession, insight: FarmInsight
    ) -> FarmInsight:
        insight.is_acknowledged = True
        await db.flush()
        await db.refresh(insight)
        return insight

    async def resolve(
        self, db: AsyncSession, insight: FarmInsight
    ) -> FarmInsight:
        insight.is_resolved = True
        await db.flush()
        await db.refresh(insight)
        return insight
