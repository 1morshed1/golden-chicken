import json

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sse_starlette.sse import EventSourceResponse

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.chat import (
    ChatMessageResponse,
    ChatSessionDetail,
    ChatSessionResponse,
    CreateSessionRequest,
    MessageFeedbackRequest,
    SendMessageRequest,
    UpdateSessionRequest,
)
from app.schemas.common import MessageResponse, PaginationMeta, SuccessResponse
from app.services.chat_service import chat_service

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("/sessions", status_code=201)
async def create_session(
    body: CreateSessionRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[ChatSessionResponse]:
    session = await chat_service.create_session(db, user, title=body.title)
    return SuccessResponse(data=ChatSessionResponse.model_validate(session))


@router.get("/sessions")
async def list_sessions(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[list[ChatSessionResponse]]:
    offset = (page - 1) * page_size
    sessions, total = await chat_service.get_user_sessions(
        db, user, offset=offset, limit=page_size
    )
    return SuccessResponse(
        data=[ChatSessionResponse.model_validate(s) for s in sessions],
        meta=PaginationMeta(
            page=page,
            page_size=page_size,
            total=total,
            total_pages=(total + page_size - 1) // page_size,
        ).model_dump(),
    )


@router.get("/sessions/{session_id}")
async def get_session(
    session_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[ChatSessionDetail]:
    session = await chat_service.get_session(db, session_id, user)
    return SuccessResponse(data=ChatSessionDetail.model_validate(session))


@router.put("/sessions/{session_id}")
async def update_session(
    session_id: str,
    body: UpdateSessionRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[ChatSessionResponse]:
    session = await chat_service.update_session_title(
        db, session_id, user, body.title
    )
    return SuccessResponse(data=ChatSessionResponse.model_validate(session))


@router.delete("/sessions/{session_id}", status_code=204)
async def delete_session(
    session_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    await chat_service.delete_session(db, session_id, user)


@router.post("/sessions/{session_id}/messages")
async def send_message(
    session_id: str,
    body: SendMessageRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[dict]:
    user_msg, ai_msg = await chat_service.send_message(
        db, session_id, user, body.content, body.language
    )
    return SuccessResponse(
        data={
            "user_message": ChatMessageResponse.model_validate(user_msg).model_dump(),
            "ai_message": ChatMessageResponse.model_validate(ai_msg).model_dump(),
        }
    )


@router.post("/sessions/{session_id}/messages/stream")
async def send_message_stream(
    session_id: str,
    body: SendMessageRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    async def event_generator():
        async for chunk in chat_service.send_message_stream(
            db, session_id, user, body.content, body.language
        ):
            yield {"event": "message", "data": json.dumps({"text": chunk})}
        yield {"event": "done", "data": "{}"}

    return EventSourceResponse(event_generator())


@router.put("/messages/{message_id}/feedback")
async def update_feedback(
    message_id: str,
    body: MessageFeedbackRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SuccessResponse[ChatMessageResponse]:
    message = await chat_service.update_feedback(
        db, message_id, user, body.feedback
    )
    return SuccessResponse(data=ChatMessageResponse.model_validate(message))
