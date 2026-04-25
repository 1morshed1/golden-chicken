from fastapi import APIRouter, Depends, Query
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.exceptions import ValidationError
from app.core.redis import get_redis
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.weather import WeatherResponse
from app.services.weather_service import BD_REGIONS, weather_service

router = APIRouter(prefix="/weather", tags=["weather"])


@router.get("", response_model=SuccessResponse[WeatherResponse])
async def get_weather(
    lat: float | None = Query(default=None),
    lon: float | None = Query(default=None),
    region: str | None = Query(default=None),
    user: User = Depends(get_current_user),
    redis: Redis = Depends(get_redis),
):
    if region:
        if region.lower() not in BD_REGIONS:
            raise ValidationError(
                f"Unknown region '{region}'. Available: {', '.join(sorted(BD_REGIONS.keys()))}"
            )
        data = await weather_service.get_weather_by_region(region, redis)
        return SuccessResponse(data=data)

    if lat is not None and lon is not None:
        data = await weather_service.get_weather(lat, lon, redis)
        return SuccessResponse(data=data)

    if user.latitude and user.longitude:
        data = await weather_service.get_weather(user.latitude, user.longitude, redis)
        return SuccessResponse(data=data)

    raise ValidationError(
        "Provide lat/lon, region name, or set your location in profile."
    )


@router.get("/regions")
async def list_regions(user: User = Depends(get_current_user)):
    regions = [
        {"name": name, "lat": coords[0], "lon": coords[1]}
        for name, coords in sorted(BD_REGIONS.items())
    ]
    return SuccessResponse(data=regions)
