import logging
from datetime import datetime

import httpx
from redis.asyncio import Redis

from app.config import settings
from app.schemas.weather import (
    CurrentWeather,
    ForecastDay,
    PoultryWeatherAdvisory,
    WeatherAlert,
    WeatherResponse,
)

logger = logging.getLogger(__name__)

BD_REGIONS: dict[str, tuple[float, float]] = {
    "dhaka": (23.81, 90.41),
    "gazipur": (23.99, 90.43),
    "chattogram": (22.36, 91.78),
    "rajshahi": (24.37, 88.60),
    "khulna": (22.82, 89.53),
    "sylhet": (24.90, 91.87),
    "rangpur": (25.74, 89.28),
    "barishal": (22.70, 90.37),
    "mymensingh": (24.75, 90.41),
    "comilla": (23.46, 91.18),
    "bogra": (24.85, 89.37),
    "jessore": (23.17, 89.21),
}

CACHE_TTL = 3600  # 1 hour

# Poultry heat stress thresholds (Celsius)
HEAT_STRESS_WARNING = 32
HEAT_STRESS_CRITICAL = 36
COLD_STRESS_WARNING = 10


class WeatherService:
    async def get_weather(
        self, lat: float, lon: float, redis: Redis
    ) -> WeatherResponse:
        cache_key = f"weather:{lat:.2f}:{lon:.2f}"
        cached = await redis.get(cache_key)
        if cached:
            return WeatherResponse.model_validate_json(cached)

        data = await self._fetch_from_api(lat, lon)
        await redis.set(cache_key, data.model_dump_json(), ex=CACHE_TTL)
        return data

    async def get_weather_by_region(
        self, region: str, redis: Redis
    ) -> WeatherResponse | None:
        coords = BD_REGIONS.get(region.lower())
        if not coords:
            return None
        return await self.get_weather(coords[0], coords[1], redis)

    async def _fetch_from_api(self, lat: float, lon: float) -> WeatherResponse:
        api_key = settings.OPENWEATHERMAP_API_KEY
        if not api_key:
            raise ValueError("OPENWEATHERMAP_API_KEY not configured")

        async with httpx.AsyncClient(timeout=10) as client:
            current_resp = await client.get(
                "https://api.openweathermap.org/data/2.5/weather",
                params={
                    "lat": lat,
                    "lon": lon,
                    "appid": api_key,
                    "units": "metric",
                },
            )
            current_resp.raise_for_status()
            current_data = current_resp.json()

            forecast_resp = await client.get(
                "https://api.openweathermap.org/data/2.5/forecast",
                params={
                    "lat": lat,
                    "lon": lon,
                    "appid": api_key,
                    "units": "metric",
                },
            )
            forecast_resp.raise_for_status()
            forecast_data = forecast_resp.json()

        location_name = current_data.get("name", "Unknown")

        current = CurrentWeather(
            temp_c=current_data["main"]["temp"],
            feels_like_c=current_data["main"]["feels_like"],
            condition=current_data["weather"][0]["description"],
            humidity=current_data["main"]["humidity"],
            wind_speed_mps=current_data["wind"]["speed"],
            icon=current_data["weather"][0]["icon"],
        )

        alerts = []
        if "alerts" in current_data:
            for a in current_data["alerts"]:
                alerts.append(WeatherAlert(
                    event=a.get("event", ""),
                    description=a.get("description", ""),
                    severity=a.get("tags", ["unknown"])[0] if a.get("tags") else "unknown",
                ))

        forecast = self._parse_forecast(forecast_data)
        advisory = self._generate_poultry_advisory(current.temp_c, current.humidity)

        return WeatherResponse(
            location_name=location_name,
            lat=lat,
            lon=lon,
            current=current,
            alerts=alerts,
            forecast=forecast,
            poultry_advisory=advisory,
        )

    def _parse_forecast(self, data: dict) -> list[ForecastDay]:
        daily: dict[str, list[dict]] = {}
        for entry in data.get("list", []):
            dt = datetime.fromtimestamp(entry["dt"])
            day_key = dt.strftime("%Y-%m-%d")
            if day_key not in daily:
                daily[day_key] = []
            daily[day_key].append(entry)

        forecast_days = []
        for day_key in sorted(daily.keys())[:5]:
            entries = daily[day_key]
            temps = [e["main"]["temp"] for e in entries]
            humidities = [e["main"]["humidity"] for e in entries]
            dt = datetime.strptime(day_key, "%Y-%m-%d")

            mid_entry = entries[len(entries) // 2]
            forecast_days.append(ForecastDay(
                date=day_key,
                day_name=dt.strftime("%A"),
                condition=mid_entry["weather"][0]["description"],
                high_c=round(max(temps), 1),
                low_c=round(min(temps), 1),
                humidity=round(sum(humidities) / len(humidities)),
                icon=mid_entry["weather"][0]["icon"],
            ))
        return forecast_days

    def _generate_poultry_advisory(
        self, temp_c: float, humidity: int
    ) -> PoultryWeatherAdvisory | None:
        if temp_c >= HEAT_STRESS_CRITICAL:
            return PoultryWeatherAdvisory(
                level="critical",
                message=(
                    f"CRITICAL: Temperature {temp_c}°C — severe heat stress risk. "
                    "Provide electrolytes in water, increase ventilation, "
                    "reduce stocking density, and avoid handling birds. "
                    "Consider sprinkler cooling."
                ),
            )
        if temp_c >= HEAT_STRESS_WARNING:
            return PoultryWeatherAdvisory(
                level="warning",
                message=(
                    f"WARNING: Temperature {temp_c}°C — heat stress risk. "
                    "Ensure adequate ventilation and cool, clean drinking water. "
                    "Avoid feeding during peak heat hours (12-3 PM)."
                ),
            )
        if temp_c <= COLD_STRESS_WARNING:
            return PoultryWeatherAdvisory(
                level="warning",
                message=(
                    f"WARNING: Temperature {temp_c}°C — cold stress risk for chicks. "
                    "Check brooder temperature and reduce drafts in sheds."
                ),
            )
        if humidity > 85 and temp_c > 28:
            return PoultryWeatherAdvisory(
                level="warning",
                message=(
                    f"WARNING: High humidity ({humidity}%) with warm temperature ({temp_c}°C). "
                    "Birds cannot cool effectively. Improve airflow and ventilation."
                ),
            )
        return None


weather_service = WeatherService()
