"""
Knowledge base ingestion script.

Usage:
    python -m app.utils.ingest_knowledge [--dir knowledge_base/raw] [--clear]
"""
import argparse
import asyncio
import logging
from pathlib import Path

from app.ai.rag.embedder import Embedder
from app.ai.rag.ingestion import KnowledgeIngestion
from app.core.database import async_session_factory

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

SUPPORTED_EXTENSIONS = {".md", ".txt", ".text", ".pdf"}


async def ingest_directory(directory: str, clear: bool = False) -> None:
    dir_path = Path(directory)
    if not dir_path.exists():
        logger.error(f"Directory not found: {directory}")
        return

    files = [
        f for f in dir_path.rglob("*")
        if f.is_file() and f.suffix.lower() in SUPPORTED_EXTENSIONS
    ]
    if not files:
        logger.warning(f"No supported files found in {directory}")
        return

    logger.info(f"Found {len(files)} files to ingest")
    embedder = Embedder.get_instance()

    async with async_session_factory() as db:
        if clear:
            from app.repositories.knowledge_repository import KnowledgeRepository
            repo = KnowledgeRepository()
            sources = await repo.get_sources(db)
            for source in sources:
                count = await repo.delete_by_source(db, source)
                logger.info(f"Cleared {count} chunks from {source}")
            await db.commit()
            logger.info("Cleared existing knowledge chunks")

        ingestion = KnowledgeIngestion(embedder, db)
        total_chunks = 0

        for file_path in sorted(files):
            try:
                count = await ingestion.ingest_document(str(file_path))
                total_chunks += count
                logger.info(f"Ingested {file_path.name}: {count} chunks")
            except Exception:
                logger.error(f"Failed to ingest {file_path.name}", exc_info=True)

        await db.commit()
        logger.info(f"Ingestion complete: {total_chunks} total chunks from {len(files)} files")


def main():
    parser = argparse.ArgumentParser(description="Ingest knowledge base documents into pgvector")
    parser.add_argument(
        "--dir",
        default="knowledge_base/raw",
        help="Directory containing documents to ingest",
    )
    parser.add_argument(
        "--clear",
        action="store_true",
        help="Clear existing chunks before ingesting",
    )
    args = parser.parse_args()
    asyncio.run(ingest_directory(args.dir, args.clear))


if __name__ == "__main__":
    main()
