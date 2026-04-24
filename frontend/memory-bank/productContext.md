# Product Context — Golden Chicken

## Why this exists
Poultry farmers need **actionable, localized guidance** for day-to-day operations: disease risk, production tracking, routine tasks, and market timing. Golden Chicken unifies these into a single assistant-driven app with Bangla support.

## Problems it solves
- **Slow diagnosis and response** to health issues (symptoms → guidance + image-based diagnosis)
- **Fragmented farm records** (eggs/chickens/trends) and lack of insight
- **Routine drift** (missed tasks, overdue actions)
- **Market uncertainty** (prices change frequently; timing matters)
- **Low connectivity reality** (need caching, offline queues, and resilient UX)

## How it should work (user mental model)
- Home is an **AI-first dashboard**: “Ask Golden AI” + quick actions.
- Health Center offers **browsable knowledge** but always routes to AI for personalized help.
- Production and Market screens show **simple KPI cards + trend charts**, with “Updated now” cues.
- Live AI provides a **call-like experience** with clear states: idle → connecting → listening → AI speaking.

## UX principles
- **Bangla-first terminology** and numerals/currency formatting (৳ BDT, Bangla digits where needed)
- **Explicit system status** (online/offline, streaming, loading, errors)
- **Low-friction navigation** via bottom tabs + drawer shortcuts
- **Consistency**: shared widgets (buttons, fields, cards), predictable layout and spacing

## Localization requirements
- Two locales: **Bangla (`bn`) and English (`en`)**
- Copy lives in ARB files; fonts differ by locale (BN: Hind Siliguri, EN: Plus Jakarta Sans)

