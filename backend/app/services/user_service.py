import uuid

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants import ALLOWED_IMAGE_TYPES, MAX_UPLOAD_SIZE_MB
from app.core.exceptions import ValidationError
from app.core.storage import upload_file
from app.models.user import User
from app.repositories.user_repository import UserRepository

user_repo = UserRepository()


class UserService:
    async def update_profile(
        self,
        db: AsyncSession,
        user: User,
        **kwargs,
    ) -> User:
        update_data = {k: v for k, v in kwargs.items() if v is not None}
        if not update_data:
            return user
        return await user_repo.update(db, user, **update_data)

    async def upload_avatar(
        self,
        db: AsyncSession,
        user: User,
        file_bytes: bytes,
        content_type: str,
        filename: str,
    ) -> str:
        if content_type not in ALLOWED_IMAGE_TYPES:
            raise ValidationError(
                f"Invalid image type. Allowed: {', '.join(ALLOWED_IMAGE_TYPES)}"
            )

        if len(file_bytes) > MAX_UPLOAD_SIZE_MB * 1024 * 1024:
            raise ValidationError(f"File too large. Max {MAX_UPLOAD_SIZE_MB}MB")

        ext = filename.rsplit(".", 1)[-1] if "." in filename else "jpg"
        key = f"avatars/{user.id}/{uuid.uuid4().hex}.{ext}"
        avatar_url = upload_file(file_bytes, key, content_type)

        await user_repo.update(db, user, avatar_url=avatar_url)
        return avatar_url


user_service = UserService()
