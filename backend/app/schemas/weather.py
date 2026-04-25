from pydantic import BaseModel


class WeatherAlert(BaseModel):
    event: str
    description: str
    severity: str


class CurrentWeather(BaseModel):
    temp_c: float
    feels_like_c: float
    condition: str
    humidity: int
    wind_speed_mps: float
    icon: str


class ForecastDay(BaseModel):
    date: str
    day_name: str
    condition: str
    high_c: float
    low_c: float
    humidity: int
    icon: str


class PoultryWeatherAdvisory(BaseModel):
    level: str
    message: str


class WeatherResponse(BaseModel):
    location_name: str
    lat: float
    lon: float
    current: CurrentWeather
    alerts: list[WeatherAlert] = []
    forecast: list[ForecastDay] = []
    poultry_advisory: PoultryWeatherAdvisory | None = None
