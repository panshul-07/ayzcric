# Guideline Mapping

This project implements the design document sections as follows.

## Game mechanics and simulation engine
- Ball-by-ball engine with Monte Carlo sampling: `lib/game/match_engine.dart`
- Format-aware behavior (T20/ODI/Test overs and phases): `lib/game/models.dart`, `lib/game/match_engine.dart`
- Aggression control and live simulation: `lib/screens/match_center_screen.dart`

## Player attributes and traits
- Technical, mental, and physical stats in `Player`: `lib/game/models.dart`
- Trait modifiers integrated into probability model: `lib/game/match_engine.dart`
- Training systems and XI selection: `lib/game/game_controller.dart`, `lib/screens/squad_screen.dart`

## Auction and squad building
- AI bidding and lot closing flow: `lib/game/game_controller.dart`
- Auction room UI: `lib/screens/auction_screen.dart`
- Youth signing objective tracking: `lib/game/game_controller.dart`

## Economy and infrastructure
- Income/sink ledger model: `FinanceEntry` + ledger operations in controller
- Marketing, sponsor negotiation, and infra upgrade actions: `lib/game/game_controller.dart`
- Finance screen and ledger: `lib/screens/finance_screen.dart`

## UI flow and screen mapping
- Dashboard: `lib/screens/dashboard_screen.dart`
- Squad Screen: `lib/screens/squad_screen.dart`
- Auction Room: `lib/screens/auction_screen.dart`
- Match Center: `lib/screens/match_center_screen.dart`
- Career + board management: `lib/screens/career_screen.dart`

## Match analytics (as requested)
- Worm chart: `lib/widgets/worm_chart.dart`
- Wagon wheel: `lib/widgets/wagon_wheel.dart`

## Career mode and dynamic events
- Board objectives and firing logic: `lib/game/game_controller.dart`
- Dynamic events (injury/dispute/retirement): `lib/game/game_controller.dart`
- Youth academy promotion system: `lib/game/game_controller.dart`, `lib/screens/career_screen.dart`
