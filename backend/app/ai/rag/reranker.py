import asyncio

from sentence_transformers import CrossEncoder

from app.config import settings


class Reranker:
    _instance: "Reranker | None" = None
    _model: CrossEncoder | None = None

    @classmethod
    def get_instance(cls) -> "Reranker":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def _get_model(self) -> CrossEncoder:
        if self._model is None:
            self._model = CrossEncoder(settings.RAG_RERANKER_MODEL, max_length=512)
        return self._model

    async def rerank(
        self, query: str, candidates: list, top_k: int = 5
    ) -> list:
        if not candidates:
            return []
        model = self._get_model()
        pairs = [(query, c.content) for c in candidates]
        loop = asyncio.get_running_loop()
        scores = await loop.run_in_executor(
            None, lambda: model.predict(pairs)
        )
        scored = sorted(zip(candidates, scores), key=lambda x: x[1], reverse=True)
        return [c for c, _ in scored[:top_k]]
