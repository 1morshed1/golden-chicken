from google import genai

from app.config import settings


class GeminiClient:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.text_model = settings.GEMINI_TEXT_MODEL
        self.lite_model = settings.GEMINI_LITE_MODEL

    def _build_prompt(self, user_message: str, context: str | None) -> str:
        if not context:
            return user_message
        return (
            "Use the following reference information to answer:\n\n"
            f"---REFERENCE---\n{context}\n---END REFERENCE---\n\n"
            f"User question: {user_message}"
        )

    def _build_contents(
        self, chat_history: list[dict] | None, final_prompt: str
    ) -> list[genai.types.Content]:
        contents = []
        if chat_history:
            for msg in chat_history[-10:]:
                contents.append(
                    genai.types.Content(
                        role=msg["role"],
                        parts=[genai.types.Part(text=msg["content"])],
                    )
                )
        contents.append(
            genai.types.Content(
                role="user",
                parts=[genai.types.Part(text=final_prompt)],
            )
        )
        return contents

    async def generate_text(
        self,
        system_prompt: str,
        user_message: str,
        chat_history: list[dict] | None = None,
        context: str | None = None,
    ) -> str:
        final_prompt = self._build_prompt(user_message, context)
        contents = self._build_contents(chat_history, final_prompt)

        response = await self.client.aio.models.generate_content(
            model=self.text_model,
            contents=contents,
            config=genai.types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.3,
                top_p=0.85,
                max_output_tokens=2048,
            ),
        )
        return response.text

    async def generate_text_stream(
        self,
        system_prompt: str,
        user_message: str,
        chat_history: list[dict] | None = None,
        context: str | None = None,
    ):
        final_prompt = self._build_prompt(user_message, context)
        contents = self._build_contents(chat_history, final_prompt)

        stream = await self.client.aio.models.generate_content_stream(
            model=self.text_model,
            contents=contents,
            config=genai.types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.3,
                max_output_tokens=2048,
            ),
        )
        async for chunk in stream:
            if chunk.text:
                yield chunk.text

    async def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str,
        prompt: str,
        context: str | None = None,
    ) -> str:
        full_prompt = f"{context}\n\n{prompt}" if context else prompt
        response = await self.client.aio.models.generate_content(
            model=self.text_model,
            contents=[
                genai.types.Content(
                    parts=[
                        genai.types.Part(text=full_prompt),
                        genai.types.Part(
                            inline_data=genai.types.Blob(
                                mime_type=mime_type, data=image_bytes
                            )
                        ),
                    ]
                ),
            ],
            config=genai.types.GenerateContentConfig(
                temperature=0.2,
                max_output_tokens=2048,
            ),
        )
        return response.text

    async def classify_intent_llm(self, message: str) -> str:
        prompt = (
            "Classify this poultry farming query into exactly one category: "
            "disease_diagnosis | feeding | vaccination | biosecurity | "
            "egg_production | broiler_management | weather_advisory | "
            "market_price | general. "
            f"Query: {message}\nCategory:"
        )
        response = await self.client.aio.models.generate_content(
            model=self.lite_model,
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                temperature=0.0,
                max_output_tokens=20,
            ),
        )
        return response.text.strip().lower()

    async def generate_title(self, message: str) -> str:
        prompt = (
            "Generate a short title (max 6 words) for a chat session that "
            f"starts with this message. No quotes.\nMessage: {message}\nTitle:"
        )
        response = await self.client.aio.models.generate_content(
            model=self.lite_model,
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                temperature=0.5,
                max_output_tokens=20,
            ),
        )
        return response.text.strip()[:100]


gemini_client = GeminiClient()
