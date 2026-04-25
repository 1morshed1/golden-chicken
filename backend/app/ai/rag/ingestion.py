from dataclasses import dataclass
from pathlib import Path
import re

from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.rag.embedder import Embedder
from app.models.knowledge import KnowledgeChunk


CATEGORY_MAP = {
    "disease": "disease_diagnosis",
    "vaccination": "vaccination",
    "feed": "feeding",
    "nutrition": "feeding",
    "biosecurity": "biosecurity",
    "shed": "biosecurity",
    "heat": "weather_advisory",
    "weather": "weather_advisory",
    "breed": "general",
    "egg": "egg_production",
    "economics": "market_price",
    "medicine": "disease_diagnosis",
    "emergency": "disease_diagnosis",
    "broiler": "broiler_management",
}


@dataclass
class ChunkData:
    text: str
    index: int
    start: int
    end: int


class KnowledgeIngestion:
    def __init__(self, embedder: Embedder, db: AsyncSession):
        self.embedder = embedder
        self.db = db

    async def ingest_document(
        self,
        file_path: str,
        category: str | None = None,
        metadata: dict | None = None,
    ) -> int:
        path = Path(file_path)
        ext = path.suffix.lower()

        if ext == ".md":
            text = path.read_text(encoding="utf-8")
            ocr_used = False
        elif ext == ".pdf":
            text, ocr_used = self._extract_pdf_text(file_path)
        elif ext in (".txt", ".text"):
            text = path.read_text(encoding="utf-8")
            ocr_used = False
        else:
            raise ValueError(f"Unsupported file type: {ext}")

        text = self._clean_text(text)
        if not text.strip():
            return 0

        if category is None:
            category = self._infer_category(path.stem)

        chunks = self._chunk_text(text, chunk_size=500, overlap=50)
        if not chunks:
            return 0

        embeddings = await self.embedder.embed_batch([c.text for c in chunks])

        for chunk, embedding in zip(chunks, embeddings):
            knowledge_chunk = KnowledgeChunk(
                content=chunk.text,
                source_document=path.name,
                category=category,
                embedding=embedding,
                chunk_metadata={
                    **(metadata or {}),
                    "chunk_index": chunk.index,
                    "ocr_source": ocr_used,
                    "file_path": str(path),
                },
            )
            self.db.add(knowledge_chunk)

        await self.db.flush()
        return len(chunks)

    def _extract_pdf_text(self, file_path: str) -> tuple[str, bool]:
        try:
            import pdfplumber

            with pdfplumber.open(file_path) as pdf:
                text = "\n\n".join(
                    page.extract_text() or "" for page in pdf.pages
                )
        except Exception:
            text = ""

        if len(text.strip()) >= 100:
            return text, False

        try:
            from pdf2image import convert_from_path
            import pytesseract

            ocr_parts = []
            for page_image in convert_from_path(file_path, dpi=300):
                page_text = pytesseract.image_to_string(
                    page_image, lang="eng+ben"
                )
                ocr_parts.append(page_text)
            return "\n\n".join(ocr_parts), True
        except Exception:
            return text, False

    def _clean_text(self, text: str) -> str:
        text = re.sub(r"#{1,6}\s*", "", text)
        text = re.sub(r"\*{1,2}([^*]+)\*{1,2}", r"\1", text)
        text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
        text = re.sub(r"\n{3,}", "\n\n", text)
        text = re.sub(r"[^\S\n]+", " ", text)
        return text.strip()

    def _chunk_text(
        self, text: str, chunk_size: int = 500, overlap: int = 50
    ) -> list[ChunkData]:
        words = text.split()
        if not words:
            return []
        chunks = []
        start = 0
        while start < len(words):
            end = min(start + chunk_size, len(words))
            chunk_text = " ".join(words[start:end])
            chunks.append(
                ChunkData(
                    text=chunk_text,
                    index=len(chunks),
                    start=start,
                    end=end,
                )
            )
            if end >= len(words):
                break
            start += chunk_size - overlap
        return chunks

    def _infer_category(self, filename: str) -> str:
        name_lower = filename.lower()
        for keyword, category in CATEGORY_MAP.items():
            if keyword in name_lower:
                return category
        return "general"
