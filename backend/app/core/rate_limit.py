from fastapi import Request

from app.core.exceptions import RateLimitError
from app.core.redis import redis_client

RATE_LIMIT_RULES: dict[str, tuple[int, int]] = {
    "auth": (10, 60),
    "default": (60, 60),
    "ai": (20, 60),
}

PATH_GROUP_MAP = {
    "/api/v1/auth/": "auth",
    "/api/v1/chat/": "ai",
    "/api/v1/live-ai/": "ai",
}


def _get_group(path: str) -> str:
    for prefix, group in PATH_GROUP_MAP.items():
        if path.startswith(prefix):
            return group
    return "default"


def _get_identifier(request: Request, group: str) -> str:
    if group == "auth":
        return request.client.host if request.client else "unknown"
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        return f"user:{auth[7:20]}"
    return request.client.host if request.client else "unknown"


async def check_rate_limit(request: Request) -> None:
    if redis_client is None:
        return

    group = _get_group(request.url.path)
    max_requests, window_seconds = RATE_LIMIT_RULES.get(
        group, RATE_LIMIT_RULES["default"]
    )
    identifier = _get_identifier(request, group)
    key = f"ratelimit:{group}:{identifier}"

    current = await redis_client.incr(key)
    if current == 1:
        await redis_client.expire(key, window_seconds)

    if current > max_requests:
        raise RateLimitError(
            f"Rate limit exceeded. Max {max_requests} requests per {window_seconds}s for {group} endpoints."
        )
