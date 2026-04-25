import logging
import re

logger = logging.getLogger(__name__)

INJECTION_PATTERNS = [
    r"ignore\s+(previous|above|all)\s+instructions",
    r"you\s+are\s+now\s+",
    r"system\s*:\s*",
    r"act\s+as\s+",
    r"pretend\s+(you|to)\b",
    r"jailbreak",
    r"do\s+not\s+tell\s+anyone",
    r"reveal\s+(your|the)\s+(system\s+)?prompt",
    r"override\s+(safety|your|the)",
    r"disregard\s+(all|your|previous)",
    r"forget\s+(all|your|previous)\s+(instructions|rules)",
    r"new\s+instructions?\s*:",
    r"ignore\s+safety\s+rules",
]

SAFE_RESPONSE = "Please ask a question about poultry farming."


def sanitize_user_input(text: str) -> str:
    for pattern in INJECTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            logger.warning("prompt_injection_attempt: %s", text[:100])
            return SAFE_RESPONSE
    return text
