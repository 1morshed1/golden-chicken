import pytest

from app.services.weather_service import WeatherService


@pytest.fixture
def weather_svc():
    return WeatherService()


class TestPoultryAdvisory:
    def test_critical_heat(self, weather_svc):
        advisory = weather_svc._generate_poultry_advisory(38.0, 60)
        assert advisory is not None
        assert advisory.level == "critical"
        assert "electrolytes" in advisory.message.lower()

    def test_warning_heat(self, weather_svc):
        advisory = weather_svc._generate_poultry_advisory(34.0, 50)
        assert advisory is not None
        assert advisory.level == "warning"
        assert "ventilation" in advisory.message.lower()

    def test_cold_stress(self, weather_svc):
        advisory = weather_svc._generate_poultry_advisory(8.0, 40)
        assert advisory is not None
        assert advisory.level == "warning"
        assert "cold" in advisory.message.lower()

    def test_high_humidity_warm(self, weather_svc):
        advisory = weather_svc._generate_poultry_advisory(30.0, 90)
        assert advisory is not None
        assert advisory.level == "warning"
        assert "humidity" in advisory.message.lower()

    def test_normal_conditions_no_advisory(self, weather_svc):
        advisory = weather_svc._generate_poultry_advisory(25.0, 60)
        assert advisory is None

    def test_threshold_boundaries(self, weather_svc):
        assert weather_svc._generate_poultry_advisory(32.0, 50) is not None
        assert weather_svc._generate_poultry_advisory(36.0, 50) is not None
        assert weather_svc._generate_poultry_advisory(10.0, 50) is not None
        assert weather_svc._generate_poultry_advisory(31.9, 50) is None
        assert weather_svc._generate_poultry_advisory(10.1, 50) is None
