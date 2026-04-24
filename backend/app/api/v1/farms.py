from fastapi import APIRouter, Depends, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.farm import (
    CreateFarmRequest,
    CreateShedRequest,
    FarmDetailResponse,
    FarmResponse,
    ShedResponse,
    UpdateFarmRequest,
    UpdateShedRequest,
)
from app.services.farm_service import farm_service

router = APIRouter(tags=["farms"])


@router.get("/farms")
async def list_farms(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[list[FarmResponse]]:
    farms = await farm_service.get_user_farms(db, user)
    data = []
    for farm in farms:
        resp = FarmResponse.model_validate(farm)
        resp.sheds_count = len([s for s in farm.sheds if s.is_active])
        data.append(resp)
    return SuccessResponse(data=data)


@router.post("/farms", status_code=201)
async def create_farm(
    body: CreateFarmRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[FarmResponse]:
    farm = await farm_service.create_farm(
        db,
        user,
        name=body.name,
        location=body.location,
        latitude=body.latitude,
        longitude=body.longitude,
    )
    resp = FarmResponse.model_validate(farm)
    resp.sheds_count = 0
    return SuccessResponse(data=resp)


@router.get("/farms/{farm_id}")
async def get_farm(
    farm_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[FarmDetailResponse]:
    farm = await farm_service.get_farm(db, farm_id, user)
    return SuccessResponse(data=FarmDetailResponse.model_validate(farm))


@router.put("/farms/{farm_id}")
async def update_farm(
    farm_id: str,
    body: UpdateFarmRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[FarmResponse]:
    farm = await farm_service.update_farm(
        db,
        farm_id,
        user,
        name=body.name,
        location=body.location,
        latitude=body.latitude,
        longitude=body.longitude,
    )
    return SuccessResponse(data=FarmResponse.model_validate(farm))


@router.delete("/farms/{farm_id}", status_code=204)
async def delete_farm(
    farm_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> Response:
    await farm_service.delete_farm(db, farm_id, user)
    return Response(status_code=204)


@router.get("/farms/{farm_id}/sheds")
async def list_sheds(
    farm_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[list[ShedResponse]]:
    sheds = await farm_service.get_farm_sheds(db, farm_id, user)
    return SuccessResponse(data=[ShedResponse.model_validate(s) for s in sheds])


@router.post("/farms/{farm_id}/sheds", status_code=201)
async def create_shed(
    farm_id: str,
    body: CreateShedRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[ShedResponse]:
    shed = await farm_service.create_shed(
        db,
        farm_id,
        user,
        name=body.name,
        flock_type=body.flock_type,
        bird_count=body.bird_count,
        bird_age_days=body.bird_age_days,
        breed=body.breed,
        stocked_at=body.stocked_at,
    )
    return SuccessResponse(data=ShedResponse.model_validate(shed))


@router.put("/sheds/{shed_id}")
async def update_shed(
    shed_id: str,
    body: UpdateShedRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[ShedResponse]:
    shed = await farm_service.update_shed(
        db,
        shed_id,
        user,
        name=body.name,
        flock_type=body.flock_type,
        bird_count=body.bird_count,
        bird_age_days=body.bird_age_days,
        breed=body.breed,
        status=body.status,
    )
    return SuccessResponse(data=ShedResponse.model_validate(shed))


@router.delete("/sheds/{shed_id}", status_code=204)
async def delete_shed(
    shed_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> Response:
    await farm_service.delete_shed(db, shed_id, user)
    return Response(status_code=204)
