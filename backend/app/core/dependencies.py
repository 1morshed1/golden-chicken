from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import ExpiredSignatureError, InvalidTokenError
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import AuthenticationError, AuthorizationError
from app.core.redis import get_redis
from app.core.security import decode_token
from app.models.user import User, UserRole
from app.repositories.user_repository import UserRepository

bearer_scheme = HTTPBearer()
user_repo = UserRepository()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
) -> User:
    token = credentials.credentials
    try:
        payload = decode_token(token)
    except ExpiredSignatureError:
        raise AuthenticationError("Token expired")
    except InvalidTokenError:
        raise AuthenticationError("Invalid token")

    jti = payload.get("jti")
    if not jti:
        raise AuthenticationError("Malformed token")

    if await redis.get(f"blacklist:{jti}"):
        raise AuthenticationError("Token revoked")

    user = await user_repo.get_by_id(db, payload["sub"])
    if not user or not user.is_active:
        raise AuthenticationError("User not found")
    return user


def require_role(*roles: UserRole):
    async def checker(user: User = Depends(get_current_user)):
        if user.role not in roles:
            raise AuthorizationError()
        return user

    return checker
