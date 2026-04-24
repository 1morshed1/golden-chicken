# Product Context — Golden Chicken Backend

## Why this exists
Poultry farmers in Bangladesh often make decisions under uncertainty (disease risk, heat stress, feed costs, market price swings). Golden Chicken aims to provide a **single mobile-first assistant** that helps farmers:
- Track farm operations and performance
- Detect problems early via trends and alerts
- Get practical guidance in **Bangla/English**
- Use AI responsibly for symptom/photo/voice-based support

## Problems it solves
- **Fragmented record-keeping**: egg count, mortality, feed consumption are often handwritten or missing.
- **Delayed diagnostics**: farmers may not recognize disease patterns early.
- **Weather-driven losses**: heat/monsoon impacts need timely advice.
- **Market volatility**: farmers need price context and “stale data” warnings.
- **Action paralysis**: too much info, too little “what do I do today?”

## How it should work (user-facing behaviors)
- **Fast onboarding**: register/login, create farm and sheds quickly.
- **Daily logging**: quick add of egg and chicken records; view trends.
- **Task planner**: today’s tasks, overdue tasks, recurring routines.
- **Health tab**: select a disease/symptom tab → prefilled prompt → AI chat.
- **Chat**:
  - Supports text and optional images.
  - Streams AI response for perceived speed.
  - Stores sessions, supports feedback, auto-titles sessions.
- **Live AI**:
  - WebSocket session where user sends short audio chunks and occasional camera frames.
  - Backend forwards to Gemini Live and returns audio + transcripts.
  - Guardrails: daily minutes cap, concurrent session limit, spend cap.
- **Insights**:
  - Simple dashboard of critical/warning/info insights.
  - Each insight includes a proposed action that’s “doable today”.

## UX and content principles (backend implications)
- **Practical over verbose**: responses should be step-based, with measurable quantities (kg/liter, BDT).
- **Safety first**: avoid unsafe/banned recommendations; include withdrawal period warnings.
- **Local relevance**: Bangladesh seasons, breeds, common stressors (heat).
- **Bilingual**: user language preference influences prompts and responses.

