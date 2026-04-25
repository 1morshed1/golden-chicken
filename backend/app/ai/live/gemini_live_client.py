from google import genai
from google.genai import types as genai_types

from app.ai.prompts.live_prompt import get_live_system_prompt
from app.config import settings


class GeminiLiveClient:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = settings.GEMINI_LIVE_MODEL

    async def create_live_session(
        self, language: str = "en", tools: list | None = None
    ):
        system_prompt = get_live_system_prompt(language)

        config = genai_types.LiveConnectConfig(
            response_modalities=["AUDIO"],
            system_instruction=genai_types.Content(
                parts=[genai_types.Part(text=system_prompt)]
            ),
            speech_config=genai_types.SpeechConfig(
                voice_config=genai_types.VoiceConfig(
                    prebuilt_voice_config=genai_types.PrebuiltVoiceConfig(
                        voice_name="Kore"
                    )
                )
            ),
            input_audio_transcription=genai_types.AudioTranscriptionConfig(enabled=True),
            output_audio_transcription=genai_types.AudioTranscriptionConfig(enabled=True),
        )

        if tools:
            config.tools = tools

        return self.client.aio.live.connect(model=self.model, config=config)


gemini_live_client = GeminiLiveClient()
