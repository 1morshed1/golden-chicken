from pydantic import BaseModel


class DiagnosisResponse(BaseModel):
    session_id: str
    user_message_id: str
    ai_message_id: str
    diagnosis: str
    image_url: str
    intent: str
    rag_used: bool
