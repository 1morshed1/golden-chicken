import asyncio
import base64
import json
import logging
import time

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from jwt import ExpiredSignatureError, InvalidTokenError

from app.ai.live.gemini_live_client import gemini_live_client
from app.ai.safety import sanitize_user_input
from app.ai.live.guardrails import (
    check_live_ai_guardrails,
    get_remaining_minutes,
    record_usage_minutes,
    register_session_end,
    register_session_start,
)
from app.ai.live.session_manager import LiveSessionManager
from app.ai.live.tool_definitions import LIVE_AI_TOOLS
from app.ai.live.tool_executor import execute_tool_calls
from app.config import settings
from app.core.database import async_session_factory
from app.core.redis import get_redis
from app.core.security import decode_token
from app.repositories.user_repository import UserRepository

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/live-ai", tags=["live-ai"])

session_manager = LiveSessionManager(gemini_live_client)
user_repo = UserRepository()


async def _authenticate_ws(token: str):
    try:
        payload = decode_token(token)
    except (ExpiredSignatureError, InvalidTokenError):
        return None

    jti = payload.get("jti")
    if not jti:
        return None

    redis = await get_redis()
    if await redis.get(f"blacklist:{jti}"):
        return None

    async with async_session_factory() as db:
        user = await user_repo.get_by_id(db, payload["sub"])
        if not user or not user.is_active:
            return None
        return user


@router.websocket("/stream")
async def live_ai_stream(websocket: WebSocket, token: str):
    user = await _authenticate_ws(token)
    if not user:
        await websocket.close(code=4001, reason="Unauthorized")
        return

    user_id = str(user.id)
    language = getattr(user, "language_pref", "en") or "en"

    can_start, rejection = await check_live_ai_guardrails(user_id)
    if not can_start:
        await websocket.accept()
        await websocket.send_json({
            "type": "error",
            "code": rejection.code,
            "message": rejection.message,
        })
        await websocket.close(code=4003)
        return

    await websocket.accept()
    await register_session_start(user_id)
    session_start = time.monotonic()

    try:
        await session_manager.start_session(
            user_id=user_id, language=language, tools=LIVE_AI_TOOLS
        )

        remaining = await get_remaining_minutes(user_id)
        session_max = min(settings.LIVE_AI_SESSION_MAX_MINUTES, remaining)
        await websocket.send_json({
            "type": "session_started",
            "max_minutes": session_max,
        })

        stop_event = asyncio.Event()

        async def forward_client_to_gemini():
            try:
                while not stop_event.is_set():
                    raw = await websocket.receive_text()
                    msg = json.loads(raw)
                    msg_type = msg.get("type")

                    if msg_type == "audio":
                        await session_manager.send_audio(
                            user_id, base64.b64decode(msg["data"])
                        )
                    elif msg_type == "video_frame":
                        await session_manager.send_video_frame(
                            user_id, base64.b64decode(msg["data"])
                        )
                    elif msg_type == "text":
                        safe_text = sanitize_user_input(msg["text"])
                        await session_manager.send_text(user_id, safe_text)
                    elif msg_type == "end_session":
                        stop_event.set()
                        break
            except WebSocketDisconnect:
                stop_event.set()
            except Exception:
                logger.exception("Error in client→gemini forwarding")
                stop_event.set()

        async def forward_gemini_to_client():
            try:
                async for response in session_manager.receive_responses(user_id):
                    if stop_event.is_set():
                        break

                    if response["type"] == "audio":
                        await websocket.send_json({
                            "type": "audio",
                            "data": base64.b64encode(response["data"]).decode(),
                            "mime_type": response["mime_type"],
                        })
                    elif response["type"] in (
                        "input_transcript",
                        "output_transcript",
                        "turn_complete",
                    ):
                        await websocket.send_json(response)
                    elif response["type"] == "tool_call":
                        results = await execute_tool_calls(
                            response["function_calls"], user_id=user_id
                        )
                        await session_manager.send_tool_response(user_id, results)
            except WebSocketDisconnect:
                stop_event.set()
            except Exception:
                logger.exception("Error in gemini→client forwarding")
                stop_event.set()

        async def session_timer():
            max_seconds = session_max * 60
            while not stop_event.is_set():
                elapsed = time.monotonic() - session_start
                if elapsed >= max_seconds:
                    try:
                        await websocket.send_json({
                            "type": "error",
                            "code": "SESSION_TIMEOUT",
                            "message": "Session time limit reached.",
                        })
                    except Exception:
                        pass
                    stop_event.set()
                    break

                remaining_secs = max_seconds - elapsed
                if remaining_secs <= 60 and remaining_secs > 59:
                    try:
                        await websocket.send_json({
                            "type": "warning",
                            "message": "1 minute remaining in this session.",
                        })
                    except Exception:
                        pass

                await asyncio.sleep(5)

        await asyncio.gather(
            forward_client_to_gemini(),
            forward_gemini_to_client(),
            session_timer(),
        )

    finally:
        elapsed_minutes = (time.monotonic() - session_start) / 60.0
        await record_usage_minutes(user_id, elapsed_minutes)
        await session_manager.stop_session(user_id)
        await register_session_end(user_id)
        try:
            await websocket.close()
        except Exception:
            pass
