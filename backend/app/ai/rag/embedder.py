import asyncio

from sentence_transformers import SentenceTransformer

from app.config import settings


class Embedder:
    _instance: "Embedder | None" = None
    _model: SentenceTransformer | None = None

    @classmethod
    def get_instance(cls) -> "Embedder":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def _get_model(self) -> SentenceTransformer:
        if self._model is None:
            self._model = SentenceTransformer(settings.RAG_EMBEDDING_MODEL)
        return self._model

    async def embed(self, text: str) -> list[float]:
        model = self._get_model()
        loop = asyncio.get_running_loop()
        vec = await loop.run_in_executor(
            None, lambda: model.encode(text, normalize_embeddings=True)
        )
        return vec.tolist()

    async def embed_batch(self, texts: list[str], batch_size: int = 8) -> list[list[float]]:
        if not texts:
            return []
        model = self._get_model()
        loop = asyncio.get_running_loop()
        vecs = await loop.run_in_executor(
            None,
            lambda: model.encode(texts, normalize_embeddings=True, batch_size=batch_size),
        )
        return vecs.tolist()
