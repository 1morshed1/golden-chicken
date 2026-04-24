from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.production import (
    ChickenRecordResponse,
    ChickenRecordsListResponse,
    CreateChickenRecordRequest,
    CreateEggRecordRequest,
    EggRecordResponse,
    EggRecordsListResponse,
    FarmOverviewResponse,
    FeedTrendResponse,
    TrendResponse,
)
from app.services.production_service import production_service

router = APIRouter(tags=["production"])


@router.post("/sheds/{shed_id}/eggs", status_code=201)
async def create_egg_record(
    shed_id: str,
    body: CreateEggRecordRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[EggRecordResponse]:
    record = await production_service.create_egg_record(
        db,
        shed_id,
        user,
        record_date=body.record_date,
        total_eggs=body.total_eggs,
        broken_eggs=body.broken_eggs,
        sold_eggs=body.sold_eggs,
        egg_weight_avg_g=body.egg_weight_avg_g,
        notes=body.notes,
    )
    return SuccessResponse(data=EggRecordResponse.model_validate(record))


@router.get("/sheds/{shed_id}/eggs")
async def list_egg_records(
    shed_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    date_from: date | None = Query(None, alias="from"),
    date_to: date | None = Query(None, alias="to"),
) -> SuccessResponse[EggRecordsListResponse]:
    records, summary = await production_service.get_egg_records(
        db, shed_id, user, date_from, date_to
    )
    return SuccessResponse(
        data=EggRecordsListResponse(
            records=[EggRecordResponse.model_validate(r) for r in records],
            summary=summary,
        )
    )


@router.post("/sheds/{shed_id}/chickens", status_code=201)
async def create_chicken_record(
    shed_id: str,
    body: CreateChickenRecordRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[ChickenRecordResponse]:
    record = await production_service.create_chicken_record(
        db,
        shed_id,
        user,
        record_date=body.record_date,
        total_birds=body.total_birds,
        additions=body.additions,
        mortality=body.mortality,
        mortality_cause=body.mortality_cause,
        avg_weight_g=body.avg_weight_g,
        feed_consumed_kg=body.feed_consumed_kg,
        notes=body.notes,
    )
    return SuccessResponse(data=ChickenRecordResponse.model_validate(record))


@router.get("/sheds/{shed_id}/chickens")
async def list_chicken_records(
    shed_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    date_from: date | None = Query(None, alias="from"),
    date_to: date | None = Query(None, alias="to"),
) -> SuccessResponse[ChickenRecordsListResponse]:
    records, summary = await production_service.get_chicken_records(
        db, shed_id, user, date_from, date_to
    )
    return SuccessResponse(
        data=ChickenRecordsListResponse(
            records=[ChickenRecordResponse.model_validate(r) for r in records],
            summary=summary,
        )
    )


@router.get("/sheds/{shed_id}/trends/eggs")
async def egg_trends(
    shed_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    period: str = Query("7d", pattern="^(7d|30d|90d)$"),
) -> SuccessResponse[TrendResponse]:
    data = await production_service.get_egg_trends(db, shed_id, user, period)
    return SuccessResponse(data=data)


@router.get("/sheds/{shed_id}/trends/mortality")
async def mortality_trends(
    shed_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    period: str = Query("7d", pattern="^(7d|30d|90d)$"),
) -> SuccessResponse[TrendResponse]:
    data = await production_service.get_mortality_trends(db, shed_id, user, period)
    return SuccessResponse(data=data)


@router.get("/sheds/{shed_id}/trends/feed")
async def feed_trends(
    shed_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
    period: str = Query("7d", pattern="^(7d|30d|90d)$"),
) -> SuccessResponse[FeedTrendResponse]:
    data = await production_service.get_feed_trends(db, shed_id, user, period)
    return SuccessResponse(data=data)


@router.get("/farms/{farm_id}/trends/overview")
async def farm_overview(
    farm_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[FarmOverviewResponse]:
    data = await production_service.get_farm_overview(db, farm_id, user)
    return SuccessResponse(data=data)
