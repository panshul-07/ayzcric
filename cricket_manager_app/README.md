# Cricket Dynasty Manager (Flutter)

A full-featured cricket franchise management app built in Flutter.

## What is included

- Multi-screen app architecture (Material 3)
- Dashboard with standings, next fixture, and board goals
- Live match center with ball-by-ball simulation, aggression control, and autoplay
- Auction room with AI bidding and squad registration
- Squad management with playing XI control and training modules
- Finance panel with ledger, infrastructure upgrades, marketing, and sponsor negotiation
- Career progression with season advance and board objective tracking

## Run locally

```bash
cd cricket_manager_app
flutter pub get
flutter run
```

## Test

```bash
cd cricket_manager_app
flutter test
```

## Notes

- Default format can be switched between T20 / ODI / Test in Career tab.
- Simulation engine uses Monte Carlo style sampling on each ball.
- Season progression and economy loops are already connected to match outcomes.
