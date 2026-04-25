from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.insights import (
    InsightAction,
    InsightResponse,
    InsightsListResponse,
    InsightsSummary,
)
from app.services.insights_service import insights_service

router = APIRouter(prefix="/insights", tags=["insights"])


@router.get("", response_model=SuccessResponse[InsightsListResponse])
async def get_insights(
    severity: str | None = Query(default=None, pattern="^(critical|warning|info)$"),
    shed_id: str | None = Query(default=None),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await insights_service.get_insights(
        db, user, severity=severity, shed_id=shed_id
    )
    return SuccessResponse(
        data=InsightsListResponse(
            insights=[InsightResponse.model_validate(i) for i in result["insights"]],
            summary=InsightsSummary(**result["summary"]),
        )
    )


@router.get("/actions", response_model=SuccessResponse[list[InsightAction]])
async def get_actions(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    actions = await insights_service.get_actions(db, user)
    return SuccessResponse(data=[InsightAction(**a) for a in actions])


@router.post(
    "/{insight_id}/acknowledge",
    response_model=SuccessResponse[InsightResponse],
)
async def acknowledge_insight(
    insight_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    insight = await insights_service.acknowledge_insight(db, insight_id, user)
    return SuccessResponse(data=InsightResponse.model_validate(insight))


@router.post(
    "/{insight_id}/resolve",
    response_model=SuccessResponse[InsightResponse],
)
async def resolve_insight(
    insight_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    insight = await insights_service.resolve_insight(db, insight_id, user)
    return SuccessResponse(data=InsightResponse.model_validate(insight))


@router.post("/generate", response_model=SuccessResponse[list[InsightResponse]])
async def generate_insights(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    insights = await insights_service.generate_daily_insights(db, user.id)
    return SuccessResponse(
        data=[InsightResponse.model_validate(i) for i in insights]
    )
