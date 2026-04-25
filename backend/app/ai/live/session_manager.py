import logging
from typing import Any

from google.genai import types as genai_types

from app.ai.live.gemini_live_client import GeminiLiveClient

logger = logging.getLogger(__name__)


class LiveSessionManager:
    def __init__(self, gemini_live: GeminiLiveClient):
        self.gemini_live = gemini_live
        self.active_sessions: dict[str, dict[str, Any]] = {}

    async def start_session(
        self, user_id: str, language: str, tools: list | None = None
    ):
        await self.stop_session(user_id)
        session_ctx = await self.gemini_live.create_live_session(
            language=language, tools=tools
        )
        session = await session_ctx.__aenter__()
        self.active_sessions[user_id] = {
            "session": session,
            "context": session_ctx,
            "language": language,
        }
        return session

    async def stop_session(self, user_id: str) -> None:
        if user_id in self.active_sessions:
            entry = self.active_sessions.pop(user_id)
            try:
                await entry["context"].__aexit__(None, None, None)
            except Exception:
                logger.warning("Error closing live session for user %s", user_id)

    def is_active(self, user_id: str) -> bool:
        return user_id in self.active_sessions

    async def send_audio(self, user_id: str, audio_bytes: bytes) -> None:
        session = self.active_sessions[user_id]["session"]
        await session.send_realtime_input(
            audio=genai_types.Blob(data=audio_bytes, mime_type="audio/pcm;rate=16000")
        )

    async def send_video_frame(self, user_id: str, frame_bytes: bytes) -> None:
        session = self.active_sessions[user_id]["session"]
        await session.send_realtime_input(
            video=genai_types.Blob(data=frame_bytes, mime_type="image/jpeg")
        )

    async def send_text(self, user_id: str, text: str) -> None:
        session = self.active_sessions[user_id]["session"]
        await session.send_client_content(
            turns=genai_types.Content(
                role="user", parts=[genai_types.Part(text=text)]
            )
        )

    async def send_tool_response(
        self, user_id: str, function_responses: list[genai_types.FunctionResponse]
    ) -> None:
        session = self.active_sessions[user_id]["session"]
        await session.send_tool_response(function_responses=function_responses)

    async def receive_responses(self, user_id: str):
        session = self.active_sessions[user_id]["session"]
        async for response in session.receive():
            if response.data:
                yield {
                    "type": "audio",
                    "data": response.data,
                    "mime_type": "audio/pcm;rate=24000",
                }
            if response.server_content:
                sc = response.server_content
                if sc.input_transcription:
                    yield {
                        "type": "input_transcript",
                        "text": sc.input_transcription.text,
                    }
                if sc.output_transcription:
                    yield {
                        "type": "output_transcript",
                        "text": sc.output_transcription.text,
                    }
                if sc.turn_complete:
                    yield {"type": "turn_complete"}
            if response.tool_call:
                yield {
                    "type": "tool_call",
                    "function_calls": response.tool_call.function_calls,
                }
