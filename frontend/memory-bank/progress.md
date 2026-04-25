# Progress — Golden Chicken Frontend

## What exists now
- A comprehensive **Flutter frontend implementation plan** (`GoldenChicken_Flutter_Implementation_Plan.md`)
- A **Figma PDF export** (`Figma.pdf`) containing the current mobile UI/UX screens and visible product copy
- A generated **Memory Bank** (`memory-bank/`) capturing scope, product intent, patterns, and planned tech stack

## What’s not implemented yet
- No Flutter project scaffold (`pubspec.yaml`, `lib/`, etc.) present in this folder yet
- No CI/CD configs present yet
- No screens, blocs, networking layer, localization, or assets added yet (beyond the plan document)

## Design coverage captured from `Figma.pdf`
- Splash / brand: "Golden Chicken", "Poultry_AI Assistant"
- Language selection: English and Bangla choices
- Auth: Welcome Back, Sign In, Create Account, phone number (`+880`) and password fields
- Golden AI home/chat: online status, Water Check and Biosec tips, quick prompts, chat input, LIVE AI entry point
- Live AI states: AI Assistant Live, AI Listening, AI Speaking, Camera Off, processing state
- Flock Overview: total birds, alerts, average age, AI score, weather/temperature alerts, today's feed plan
- Health Center: disease/vaccine/emergency/diagnosis tabs, severity badges, symptom counts, Ask AI actions
- Market Insights: Dhaka live prices, egg/meat/feed costs, 7-day trend, AI confidence tip
- Profile: user identity, location, loyalty points, preferences, dark mode, notifications, data/history, account/help/about/logout

## Planned milestones (from plan)
- **Sprint 1**: Foundations (project setup, theme/tokens, networking skeleton, DI, routing, shared widgets, localization) → app shell with 4 tabs
- **Sprint 2**: Onboarding + Auth + Home
- **Sprint 3**: Chat + Health Center + Production
- **Sprint 4**: Trends + Tasks + Market
- **Sprint 5**: Profile + Insights + Live AI
- **Sprint 6–7**: QA, polish, release prep

## Known issues / watch-outs
- Phone-login UI vs backend email/password alignment
- Live AI protocol details need confirmation (audio/video chunk formats, rate limits, close codes like **4003**)
- Cache TTLs and offline queue rules should be implemented consistently per feature (plan suggests: Health 24h, Market 30m, etc.)

