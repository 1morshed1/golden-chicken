import uuid

from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.exceptions import ValidationError
from app.core.storage import upload_file
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.diagnosis import DiagnosisResponse
from app.services.chat_service import chat_service

router = APIRouter(prefix="/diagnosis", tags=["diagnosis"])

ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10MB


@router.post("", response_model=SuccessResponse[DiagnosisResponse], status_code=201)
async def diagnose_image(
    image: UploadFile = File(...),
    notes: str = Form(default=None),
    language: str = Form(default="en"),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if image.content_type not in ALLOWED_MIME_TYPES:
        raise ValidationError(
            "Unsupported image format. Use JPEG, PNG, or WebP.",
            details=[{"field": "image", "message": f"Got {image.content_type}"}],
        )

    image_bytes = await image.read()
    if len(image_bytes) > MAX_IMAGE_SIZE:
        raise ValidationError("Image too large. Maximum size is 10MB.")

    if len(image_bytes) < 1024:
        raise ValidationError("Image too small or empty.")

    image_key = f"diagnosis/{user.id}/{uuid.uuid4()}{_ext(image.content_type)}"
    image_url = upload_file(image_bytes, image_key, image.content_type)

    result = await chat_service.diagnose_image(
        db=db,
        user=user,
        image_bytes=image_bytes,
        mime_type=image.content_type,
        image_url=image_url,
        additional_notes=notes,
        language=language,
    )

    return SuccessResponse(data=DiagnosisResponse(**result))


def _ext(mime_type: str) -> str:
    return {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }.get(mime_type, ".jpg")
