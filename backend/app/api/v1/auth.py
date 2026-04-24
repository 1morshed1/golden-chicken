from fastapi import APIRouter, Depends, Request
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.redis import get_redis
from app.models.user import User
from app.schemas.auth import (
    AuthResponse,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserBrief,
)
from app.schemas.common import MessageResponse, SuccessResponse
from app.services.auth_service import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", status_code=201)
async def register(
    body: RegisterRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[AuthResponse]:
    device_info = request.headers.get("User-Agent")
    user, access_token, refresh_token = await auth_service.register(
        db,
        full_name=body.full_name,
        email=body.email,
        password=body.password,
        role=body.role,
        language_pref=body.language_pref,
        device_info=device_info,
    )
    return SuccessResponse(
        data=AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserBrief.model_validate(user),
        )
    )


@router.post("/login")
async def login(
    body: LoginRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[AuthResponse]:
    device_info = request.headers.get("User-Agent")
    user, access_token, refresh_token = await auth_service.login(
        db,
        email=body.email,
        password=body.password,
        device_info=device_info,
    )
    return SuccessResponse(
        data=AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserBrief.model_validate(user),
        )
    )


@router.post("/refresh")
async def refresh(
    body: RefreshRequest,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
) -> SuccessResponse[TokenResponse]:
    access_token, refresh_token = await auth_service.refresh_tokens(
        db,
        redis,
        refresh_token_str=body.refresh_token,
    )
    return SuccessResponse(
        data=TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
        )
    )


@router.post("/logout")
async def logout(
    request: Request,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
    user: User = Depends(get_current_user),
) -> MessageResponse:
    token = request.headers.get("Authorization", "").removeprefix("Bearer ")
    await auth_service.logout(db, redis, user=user, access_token=token)
    return MessageResponse(data={"message": "Logged out"})
