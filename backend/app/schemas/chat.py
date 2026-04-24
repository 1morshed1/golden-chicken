from datetime import datetime

from pydantic import BaseModel, Field


class CreateSessionRequest(BaseModel):
    title: str | None = None


class UpdateSessionRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)


class SendMessageRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=5000)
    language: str = Field("en", pattern=r"^(en|bn)$")


class MessageFeedbackRequest(BaseModel):
    feedback: int = Field(..., ge=-1, le=1)


class ChatSessionResponse(BaseModel):
    id: str
    title: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ChatMessageResponse(BaseModel):
    id: str
    session_id: str
    role: str
    content: str
    image_url: str | None = None
    feedback: int | None = None
    message_metadata: dict | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ChatSessionDetail(ChatSessionResponse):
    messages: list[ChatMessageResponse] = []
