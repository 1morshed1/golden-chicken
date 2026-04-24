from fastapi import APIRouter, Depends, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.user import UpdateProfileRequest, UserResponse
from app.services.user_service import user_service

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
async def get_profile(
    user: User = Depends(get_current_user),
) -> SuccessResponse[UserResponse]:
    return SuccessResponse(data=UserResponse.model_validate(user))


@router.put("/me")
async def update_profile(
    body: UpdateProfileRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[UserResponse]:
    updated = await user_service.update_profile(
        db,
        user,
        full_name=body.full_name,
        phone=body.phone,
        location=body.location,
        latitude=body.latitude,
        longitude=body.longitude,
        language_pref=body.language_pref,
    )
    return SuccessResponse(data=UserResponse.model_validate(updated))


@router.put("/me/avatar")
async def upload_avatar(
    avatar: UploadFile,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SuccessResponse[dict]:
    file_bytes = await avatar.read()
    url = await user_service.upload_avatar(
        db,
        user,
        file_bytes=file_bytes,
        content_type=avatar.content_type or "image/jpeg",
        filename=avatar.filename or "avatar.jpg",
    )
    return SuccessResponse(data={"avatar_url": url})
