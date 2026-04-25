from unittest.mock import AsyncMock, MagicMock

import pytest

from app.ai.intent import classify_intent


@pytest.fixture
def mock_gemini():
    client = MagicMock()
    client.classify_intent_llm = AsyncMock(return_value="general")
    return client


class TestKeywordClassification:
    async def test_disease_english(self, mock_gemini):
        result = await classify_intent("My chickens are sick and dying", mock_gemini)
        assert result == "disease_diagnosis"

    async def test_disease_bangla(self, mock_gemini):
        result = await classify_intent("আমার মুরগি অসুস্থ হয়ে গেছে", mock_gemini)
        assert result == "disease_diagnosis"

    async def test_feeding(self, mock_gemini):
        result = await classify_intent("What feed should I give my layers?", mock_gemini)
        assert result == "feeding"

    async def test_vaccination(self, mock_gemini):
        result = await classify_intent("When should I give the vaccine dose?", mock_gemini)
        assert result == "vaccination"

    async def test_egg_production(self, mock_gemini):
        result = await classify_intent("My egg production is dropping", mock_gemini)
        assert result == "egg_production"

    async def test_broiler(self, mock_gemini):
        result = await classify_intent("What is the ideal broiler weight at 30 days?", mock_gemini)
        assert result == "broiler_management"

    async def test_weather(self, mock_gemini):
        result = await classify_intent("Is there rain coming?", mock_gemini)
        assert result == "weather_advisory"

    async def test_market_price(self, mock_gemini):
        result = await classify_intent("What is the current egg price in the market?", mock_gemini)
        assert result == "market_price"

    async def test_biosecurity(self, mock_gemini):
        result = await classify_intent("How to disinfect the shed properly?", mock_gemini)
        assert result == "biosecurity"


class TestLLMFallback:
    async def test_ambiguous_falls_back_to_llm(self, mock_gemini):
        mock_gemini.classify_intent_llm = AsyncMock(return_value="feeding")
        result = await classify_intent("How do I optimize my flock management?", mock_gemini)
        assert result == "feeding"
        mock_gemini.classify_intent_llm.assert_called_once()

    async def test_llm_returns_unknown_defaults_to_general(self, mock_gemini):
        mock_gemini.classify_intent_llm = AsyncMock(return_value="unknown_category")
        result = await classify_intent("Tell me something random", mock_gemini)
        assert result == "general"

    async def test_llm_returns_valid_category(self, mock_gemini):
        mock_gemini.classify_intent_llm = AsyncMock(return_value="vaccination")
        result = await classify_intent("Schedule for my birds please", mock_gemini)
        assert result == "vaccination"
