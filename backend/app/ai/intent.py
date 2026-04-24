from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.ai.gemini_client import GeminiClient

INTENT_CATEGORIES: dict[str, list[str]] = {
    "disease_diagnosis": [
        "disease", "sick", "dying", "symptoms", "swollen",
        "bleeding", "cough", "sneeze", "diarrhea",
        "রোগ", "অসুস্থ", "মারা", "লক্ষণ",
    ],
    "feeding": [
        "feed", "food", "diet", "protein", "calcium",
        "খাবার", "খাদ্য", "দানা",
    ],
    "vaccination": [
        "vaccine", "vaccination", "immunize", "dose",
        "টিকা", "ভ্যাক্সিন",
    ],
    "biosecurity": [
        "disinfect", "biosecurity", "sanitize", "clean",
        "জীবনিরাপত্তা", "পরিষ্কার",
    ],
    "egg_production": [
        "egg", "laying", "production", "layer",
        "ডিম", "উৎপাদন", "লেয়ার",
    ],
    "broiler_management": [
        "broiler", "weight", "growth", "fcr", "harvest",
        "ব্রয়লার", "ওজন", "বৃদ্ধি",
    ],
    "weather_advisory": [
        "weather", "rain", "heat", "cold", "storm",
        "আবহাওয়া", "গরম", "ঠান্ডা", "বৃষ্টি",
    ],
    "market_price": [
        "price", "cost", "market", "sell", "buy",
        "দাম", "বাজার", "বিক্রি",
    ],
    "general": [],
}


async def classify_intent(message: str, gemini: GeminiClient) -> str:
    message_lower = message.lower()
    scores = {
        intent: sum(1 for kw in keywords if kw in message_lower)
        for intent, keywords in INTENT_CATEGORIES.items()
    }
    best = max(scores, key=scores.get)
    if scores[best] > 0:
        return best

    llm_intent = await gemini.classify_intent_llm(message)
    if llm_intent in INTENT_CATEGORIES:
        return llm_intent
    return "general"
