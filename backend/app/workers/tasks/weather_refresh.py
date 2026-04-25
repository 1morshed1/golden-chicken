import asyncio
import logging

import httpx
import redis as sync_redis

from app.config import settings
from app.services.weather_service import BD_REGIONS, CACHE_TTL
from app.workers.celery_app import celery_app

logger = logging.getLogger(__name__)


def _fetch_and_cache_region(region: str, lat: float, lon: float, r: sync_redis.Redis) -> bool:
    api_key = settings.OPENWEATHERMAP_API_KEY
    if not api_key:
        return False

    cache_key = f"weather:{lat:.2f}:{lon:.2f}"
    try:
        resp = httpx.get(
            "https://api.openweathermap.org/data/2.5/weather",
            params={"lat": lat, "lon": lon, "appid": api_key, "units": "metric"},
            timeout=10,
        )
        resp.raise_for_status()
        current_data = resp.json()

        forecast_resp = httpx.get(
            "https://api.openweathermap.org/data/2.5/forecast",
            params={"lat": lat, "lon": lon, "appid": api_key, "units": "metric"},
            timeout=10,
        )
        forecast_resp.raise_for_status()

        from app.services.weather_service import WeatherService
        ws = WeatherService()

        from app.schemas.weather import CurrentWeather, WeatherResponse
        from datetime import datetime

        current = CurrentWeather(
            temp_c=current_data["main"]["temp"],
            feels_like_c=current_data["main"]["feels_like"],
            condition=current_data["weather"][0]["description"],
            humidity=current_data["main"]["humidity"],
            wind_speed_mps=current_data["wind"]["speed"],
            icon=current_data["weather"][0]["icon"],
        )

        forecast = ws._parse_forecast(forecast_resp.json())
        advisory = ws._generate_poultry_advisory(current.temp_c, current.humidity)

        weather_resp = WeatherResponse(
            location_name=current_data.get("name", region),
            lat=lat, lon=lon,
            current=current,
            alerts=[],
            forecast=forecast,
            poultry_advisory=advisory,
        )

        r.set(cache_key, weather_resp.model_dump_json(), ex=CACHE_TTL)
        return True

    except Exception as e:
        logger.error(f"Weather refresh failed for {region}: {e}")
        return False


@celery_app.task
def refresh_weather_cache():
    r = sync_redis.from_url(settings.REDIS_URL)
    success = 0
    for region, (lat, lon) in BD_REGIONS.items():
        if _fetch_and_cache_region(region, lat, lon, r):
            success += 1

    logger.info(f"Weather cache refreshed: {success}/{len(BD_REGIONS)} regions")
