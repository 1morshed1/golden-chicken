from datetime import datetime, timedelta, timezone

import structlog
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.constants import TOKEN_BLACKLIST_PREFIX
from app.core.exceptions import AuthenticationError, ConflictError
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    hash_refresh_token,
    verify_password,
)
from app.models.user import LanguagePreference, User, UserRole
from app.repositories.session_repository import SessionRepository
from app.repositories.user_repository import UserRepository

logger = structlog.get_logger()

user_repo = UserRepository()
session_repo = SessionRepository()


class AuthService:
    async def register(
        self,
        db: AsyncSession,
        *,
        full_name: str,
        email: str,
        password: str,
        role: UserRole = UserRole.FARMER,
        language_pref: LanguagePreference = LanguagePreference.EN,
        device_info: str | None = None,
    ) -> tuple[User, str, str]:
        existing = await user_repo.get_by_email(db, email)
        if existing:
            raise ConflictError("Email already registered")

        user = await user_repo.create(
            db,
            full_name=full_name,
            email=email,
            password_hash=hash_password(password),
            role=role,
            language_pref=language_pref,
        )

        access_token, refresh_token = await self._create_session(
            db, user, device_info=device_info
        )
        await logger.ainfo("user_registered", user_id=user.id, email=email)
        return user, access_token, refresh_token

    async def login(
        self,
        db: AsyncSession,
        *,
        email: str,
        password: str,
        device_info: str | None = None,
    ) -> tuple[User, str, str]:
        user = await user_repo.get_by_email(db, email)
        if not user or not user.password_hash:
            raise AuthenticationError("Invalid email or password")

        if not verify_password(password, user.password_hash):
            raise AuthenticationError("Invalid email or password")

        if not user.is_active:
            raise AuthenticationError("Account is deactivated")

        access_token, refresh_token = await self._create_session(
            db, user, device_info=device_info
        )
        await logger.ainfo("user_logged_in", user_id=user.id)
        return user, access_token, refresh_token

    async def refresh_tokens(
        self,
        db: AsyncSession,
        redis: Redis,
        *,
        refresh_token_str: str,
    ) -> tuple[str, str]:
        try:
            payload = decode_token(refresh_token_str)
        except Exception:
            raise AuthenticationError("Invalid refresh token")

        if payload.get("type") != "refresh":
            raise AuthenticationError("Invalid token type")

        token_hash = hash_refresh_token(refresh_token_str)
        session = await session_repo.get_by_token_hash(db, token_hash)
        if not session:
            raise AuthenticationError("Refresh token revoked or expired")

        # Revoke old session (rotation)
        await session_repo.revoke(db, session)

        user = await user_repo.get_by_id(db, session.user_id)
        if not user or not user.is_active:
            raise AuthenticationError("User not found or deactivated")

        access_token, new_refresh_token = await self._create_session(
            db, user, device_info=session.device_info
        )
        await logger.ainfo("tokens_refreshed", user_id=user.id)
        return access_token, new_refresh_token

    async def logout(
        self,
        db: AsyncSession,
        redis: Redis,
        *,
        user: User,
        access_token: str,
    ) -> None:
        try:
            payload = decode_token(access_token)
        except Exception:
            raise AuthenticationError("Invalid access token")

        jti = payload.get("jti")
        if jti:
            ttl = settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60
            await redis.setex(f"{TOKEN_BLACKLIST_PREFIX}{jti}", ttl, "1")

        await session_repo.revoke_all_for_user(db, user.id)
        await logger.ainfo("user_logged_out", user_id=user.id)

    async def _create_session(
        self,
        db: AsyncSession,
        user: User,
        *,
        device_info: str | None = None,
    ) -> tuple[str, str]:
        access_token, _ = create_access_token(
            user_id=str(user.id), role=user.role.value, lang=user.language_pref.value
        )
        refresh_token, refresh_jti = create_refresh_token(user_id=str(user.id))

        await session_repo.create(
            db,
            user_id=user.id,
            refresh_token_hash=hash_refresh_token(refresh_token),
            jti=refresh_jti,
            device_info=device_info,
            expires_at=datetime.now(timezone.utc)
            + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS),
        )

        return access_token, refresh_token


auth_service = AuthService()
