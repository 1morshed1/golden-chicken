from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.exceptions import NotFoundError
from app.models.user import User
from app.repositories.health_repository import HealthTabRepository
from app.schemas.chat import ChatSessionResponse
from app.schemas.common import SuccessResponse
from app.schemas.health import AskHealthTabRequest, HealthTabResponse
from app.services.chat_service import chat_service

router = APIRouter(prefix="/health-tabs", tags=["Health Tabs"])

health_repo = HealthTabRepository()


@router.get("")
async def list_health_tabs(
    category: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[list[HealthTabResponse]]:
    tabs = await health_repo.get_active_tabs(db, category=category)
    return SuccessResponse(
        data=[HealthTabResponse.model_validate(t) for t in tabs]
    )


@router.get("/{tab_id}")
async def get_health_tab(
    tab_id: str,
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[HealthTabResponse]:
    tab = await health_repo.get_by_id(db, tab_id)
    if not tab or not tab.is_active:
        raise NotFoundError("Health tab")
    return SuccessResponse(data=HealthTabResponse.model_validate(tab))


@router.post("/{tab_id}/ask")
async def ask_health_tab(
    tab_id: str,
    body: AskHealthTabRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[dict]:
    tab = await health_repo.get_by_id(db, tab_id)
    if not tab or not tab.is_active:
        raise NotFoundError("Health tab")

    prompt = tab.prefilled_prompt_bn if body.language == "bn" else tab.prefilled_prompt_en
    if body.additional_context:
        prompt = f"{prompt}\n\nAdditional context: {body.additional_context}"

    session = await chat_service.create_session(
        db, user, title=tab.disease_name_en
    )
    user_msg, ai_msg = await chat_service.send_message(
        db, session.id, user, prompt, body.language
    )

    from app.schemas.chat import ChatMessageResponse

    return SuccessResponse(
        data={
            "session": ChatSessionResponse.model_validate(session).model_dump(),
            "user_message": ChatMessageResponse.model_validate(user_msg).model_dump(),
            "ai_message": ChatMessageResponse.model_validate(ai_msg).model_dump(),
        }
    )
