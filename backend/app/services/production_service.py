from datetime import date, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ConflictError, NotFoundError
from app.models.farm import Farm, Shed
from app.models.production import ChickenRecord, EggRecord
from app.models.user import User
from app.repositories.farm_repository import FarmRepository, ShedRepository
from app.repositories.production_repository import (
    ChickenRecordRepository,
    EggRecordRepository,
)
from app.schemas.production import (
    ChickenSummary,
    EggSummary,
    FarmOverviewResponse,
    FeedTrendResponse,
    TrendDataPoint,
    TrendResponse,
)

farm_repo = FarmRepository()
shed_repo = ShedRepository()
egg_repo = EggRecordRepository()
chicken_repo = ChickenRecordRepository()

PERIOD_DAYS = {"7d": 7, "30d": 30, "90d": 90}


class ProductionService:
    async def create_egg_record(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        **kwargs,
    ) -> EggRecord:
        await self._verify_shed_access(db, shed_id, user)
        existing = await egg_repo.get_by_shed_and_date(
            db, shed_id, kwargs["record_date"]
        )
        if existing:
            raise ConflictError("Egg record already exists for this date")
        return await egg_repo.create(db, shed_id=shed_id, **kwargs)

    async def get_egg_records(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        date_from: date | None = None,
        date_to: date | None = None,
    ) -> tuple[list[EggRecord], EggSummary]:
        await self._verify_shed_access(db, shed_id, user)
        records = await egg_repo.get_by_shed_and_date_range(
            db, shed_id, date_from, date_to
        )
        summary = self._compute_egg_summary(records)
        return records, summary

    async def create_chicken_record(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        **kwargs,
    ) -> ChickenRecord:
        await self._verify_shed_access(db, shed_id, user)
        existing = await chicken_repo.get_by_shed_and_date(
            db, shed_id, kwargs["record_date"]
        )
        if existing:
            raise ConflictError("Chicken record already exists for this date")
        return await chicken_repo.create(db, shed_id=shed_id, **kwargs)

    async def get_chicken_records(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        date_from: date | None = None,
        date_to: date | None = None,
    ) -> tuple[list[ChickenRecord], ChickenSummary]:
        await self._verify_shed_access(db, shed_id, user)
        records = await chicken_repo.get_by_shed_and_date_range(
            db, shed_id, date_from, date_to
        )
        summary = self._compute_chicken_summary(records)
        return records, summary

    async def get_egg_trends(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        period: str = "7d",
    ) -> TrendResponse:
        await self._verify_shed_access(db, shed_id, user)
        days = PERIOD_DAYS.get(period, 7)
        date_from = date.today() - timedelta(days=days)
        records = await egg_repo.get_by_shed_and_date_range(db, shed_id, date_from)

        data_points = [
            TrendDataPoint(
                date=r.record_date,
                value=float(r.total_eggs),
                secondary=float(r.broken_eggs),
            )
            for r in sorted(records, key=lambda r: r.record_date)
        ]
        direction, change = self._calc_trend(
            [p.value for p in data_points]
        )
        return TrendResponse(
            data_points=data_points,
            trend_direction=direction,
            change_pct=change,
        )

    async def get_mortality_trends(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        period: str = "7d",
    ) -> TrendResponse:
        await self._verify_shed_access(db, shed_id, user)
        days = PERIOD_DAYS.get(period, 7)
        date_from = date.today() - timedelta(days=days)
        records = await chicken_repo.get_by_shed_and_date_range(
            db, shed_id, date_from
        )

        cumulative = 0
        data_points = []
        for r in sorted(records, key=lambda r: r.record_date):
            cumulative += r.mortality
            data_points.append(
                TrendDataPoint(
                    date=r.record_date,
                    value=float(r.mortality),
                    secondary=float(cumulative),
                )
            )
        direction, change = self._calc_trend(
            [p.value for p in data_points]
        )
        return TrendResponse(
            data_points=data_points,
            trend_direction=direction,
            change_pct=change,
        )

    async def get_feed_trends(
        self,
        db: AsyncSession,
        shed_id: str,
        user: User,
        period: str = "7d",
    ) -> FeedTrendResponse:
        await self._verify_shed_access(db, shed_id, user)
        days = PERIOD_DAYS.get(period, 7)
        date_from = date.today() - timedelta(days=days)
        records = await chicken_repo.get_by_shed_and_date_range(
            db, shed_id, date_from
        )

        data_points = []
        total_feed = 0.0
        total_weight_gain = 0.0

        sorted_records = sorted(records, key=lambda r: r.record_date)
        for i, r in enumerate(sorted_records):
            feed = r.feed_consumed_kg or 0.0
            total_feed += feed
            fcr = None
            if i > 0 and r.avg_weight_g and sorted_records[i - 1].avg_weight_g:
                weight_gain_kg = (
                    r.avg_weight_g - sorted_records[i - 1].avg_weight_g
                ) / 1000.0
                if weight_gain_kg > 0:
                    fcr = feed / (weight_gain_kg * r.total_birds)
                    total_weight_gain += weight_gain_kg
            data_points.append(
                TrendDataPoint(date=r.record_date, value=feed, secondary=fcr)
            )

        avg_fcr = None
        if total_weight_gain > 0 and total_feed > 0:
            avg_fcr = round(total_feed / total_weight_gain, 2)

        return FeedTrendResponse(data_points=data_points, avg_fcr=avg_fcr)

    async def get_farm_overview(
        self,
        db: AsyncSession,
        farm_id: str,
        user: User,
    ) -> FarmOverviewResponse:
        farm = await farm_repo.get_by_id(db, farm_id)
        if not farm or not farm.is_active:
            raise NotFoundError("Farm")
        if str(farm.user_id) != str(user.id):
            from app.core.exceptions import AuthorizationError
            raise AuthorizationError("You don't own this farm")

        sheds = await shed_repo.get_farm_sheds(db, farm_id)
        today = date.today()
        week_ago = today - timedelta(days=7)

        total_birds = 0
        total_eggs_today = 0
        total_mortality_7d = 0
        total_birds_start = 0
        total_feed_7d = 0.0

        for shed in sheds:
            egg_today = await egg_repo.get_by_shed_and_date(db, str(shed.id), today)
            if egg_today:
                total_eggs_today += egg_today.total_eggs

            chicken_records = await chicken_repo.get_by_shed_and_date_range(
                db, str(shed.id), week_ago, today
            )
            if chicken_records:
                latest = max(chicken_records, key=lambda r: r.record_date)
                total_birds += latest.total_birds
                for cr in chicken_records:
                    total_mortality_7d += cr.mortality
                    total_feed_7d += cr.feed_consumed_kg or 0.0
                earliest = min(chicken_records, key=lambda r: r.record_date)
                total_birds_start += earliest.total_birds
            else:
                total_birds += shed.bird_count

        mortality_rate = 0.0
        if total_birds_start > 0:
            mortality_rate = round(
                (total_mortality_7d / total_birds_start) * 100, 2
            )

        return FarmOverviewResponse(
            total_birds=total_birds,
            total_eggs_today=total_eggs_today,
            mortality_rate_7d=mortality_rate,
            feed_efficiency=round(total_feed_7d, 2) if total_feed_7d else None,
        )

    async def _verify_shed_access(
        self, db: AsyncSession, shed_id: str, user: User
    ) -> Shed:
        shed = await shed_repo.get_by_id(db, shed_id)
        if not shed or not shed.is_active:
            raise NotFoundError("Shed")
        farm = await farm_repo.get_by_id(db, shed.farm_id)
        if not farm or str(farm.user_id) != str(user.id):
            from app.core.exceptions import AuthorizationError
            raise AuthorizationError("You don't own this shed")
        return shed

    def _compute_egg_summary(self, records: list[EggRecord]) -> EggSummary:
        if not records:
            return EggSummary(avg_daily=0, total=0, trend="stable")
        total = sum(r.total_eggs for r in records)
        avg_daily = round(total / len(records), 1)
        values = [r.total_eggs for r in sorted(records, key=lambda r: r.record_date)]
        direction, _ = self._calc_trend(values)
        return EggSummary(avg_daily=avg_daily, total=total, trend=direction)

    def _compute_chicken_summary(
        self, records: list[ChickenRecord]
    ) -> ChickenSummary:
        if not records:
            return ChickenSummary(current_count=0, total_mortality=0)
        latest = max(records, key=lambda r: r.record_date)
        total_mortality = sum(r.mortality for r in records)
        total_feed = sum(r.feed_consumed_kg or 0.0 for r in records)
        total_weight_gain = 0.0
        sorted_recs = sorted(records, key=lambda r: r.record_date)
        if len(sorted_recs) >= 2:
            first_w = sorted_recs[0].avg_weight_g
            last_w = sorted_recs[-1].avg_weight_g
            if first_w and last_w and last_w > first_w:
                total_weight_gain = (last_w - first_w) / 1000.0 * latest.total_birds
        fcr = None
        if total_weight_gain > 0 and total_feed > 0:
            fcr = round(total_feed / total_weight_gain, 2)
        return ChickenSummary(
            current_count=latest.total_birds,
            total_mortality=total_mortality,
            fcr=fcr,
        )

    @staticmethod
    def _calc_trend(values: list[float]) -> tuple[str, float | None]:
        if len(values) < 2:
            return "stable", None
        first_half = values[: len(values) // 2]
        second_half = values[len(values) // 2 :]
        avg_first = sum(first_half) / len(first_half)
        avg_second = sum(second_half) / len(second_half)
        if avg_first == 0:
            return "stable", None
        change = round(((avg_second - avg_first) / avg_first) * 100, 1)
        if change > 5:
            return "up", change
        elif change < -5:
            return "down", change
        return "stable", change


production_service = ProductionService()
