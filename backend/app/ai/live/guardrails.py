import logging
from dataclasses import dataclass
from datetime import date

from redis.asyncio import Redis

from app.config import settings
from app.core.redis import get_redis

logger = logging.getLogger(__name__)

DAILY_MINUTES_KEY = "live_ai:minutes:{user_id}:{date}"
CONCURRENT_KEY = "live_ai:active:{user_id}"
SPEND_KEY = "live_ai:spend:{date}"
TTL_24H = 86400


@dataclass
class GuardrailRejection:
    code: str
    message: str


async def check_live_ai_guardrails(user_id: str) -> tuple[bool, GuardrailRejection | None]:
    redis = await get_redis()
    today = date.today().isoformat()

    concurrent = await redis.get(CONCURRENT_KEY.format(user_id=user_id))
    if concurrent:
        active_count = int(concurrent)
        if active_count >= settings.LIVE_AI_CONCURRENT_SESSIONS:
            return False, GuardrailRejection(
                code="LIVE_AI_CONCURRENT",
                message="You already have an active Live AI session. Please end it first.",
            )

    daily_key = DAILY_MINUTES_KEY.format(user_id=user_id, date=today)
    daily_minutes = await redis.get(daily_key)
    if daily_minutes and float(daily_minutes) >= settings.LIVE_AI_DAILY_MAX_MINUTES:
        return False, GuardrailRejection(
            code="LIVE_AI_DAILY_LIMIT",
            message=f"You have used your daily limit of {settings.LIVE_AI_DAILY_MAX_MINUTES} minutes for Live AI.",
        )

    spend_key = SPEND_KEY.format(date=today)
    spend = await redis.get(spend_key)
    if spend and float(spend) >= settings.LIVE_AI_DAILY_SPEND_CAP_USD:
        return False, GuardrailRejection(
            code="LIVE_AI_SPEND_CAP",
            message="Live AI service is temporarily unavailable due to usage limits. Please try again tomorrow.",
        )

    return True, None


async def register_session_start(user_id: str) -> None:
    redis = await get_redis()
    key = CONCURRENT_KEY.format(user_id=user_id)
    await redis.incr(key)
    await redis.expire(key, TTL_24H)


async def register_session_end(user_id: str) -> None:
    redis = await get_redis()
    key = CONCURRENT_KEY.format(user_id=user_id)
    val = await redis.decr(key)
    if val <= 0:
        await redis.delete(key)


async def record_usage_minutes(user_id: str, minutes: float) -> None:
    redis = await get_redis()
    today = date.today().isoformat()

    daily_key = DAILY_MINUTES_KEY.format(user_id=user_id, date=today)
    await redis.incrbyfloat(daily_key, minutes)
    await redis.expire(daily_key, TTL_24H)

    cost_per_minute = 0.02
    estimated_cost = minutes * cost_per_minute
    spend_key = SPEND_KEY.format(date=today)
    await redis.incrbyfloat(spend_key, estimated_cost)
    await redis.expire(spend_key, TTL_24H)


async def get_remaining_minutes(user_id: str) -> float:
    redis = await get_redis()
    today = date.today().isoformat()
    daily_key = DAILY_MINUTES_KEY.format(user_id=user_id, date=today)
    used = await redis.get(daily_key)
    used_mins = float(used) if used else 0.0
    return max(0.0, settings.LIVE_AI_DAILY_MAX_MINUTES - used_mins)
