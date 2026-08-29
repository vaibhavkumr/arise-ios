# Arise

A native iOS fitness app that structures workouts as an RPG: you play a hunter
who levels up by training, with quests standing in for workout goals and
"dungeon raids" for longer sessions.

Built in SwiftUI, MVVM, no third-party dependencies.

## What's in it

- **Quests** — workout goals with a list and detail flow
  (`Views/Quests/`, `ViewModels/QuestViewModel.swift`)
- **Dungeons** — longer guided sessions with their own raid view
  (`Views/Dungeons/`)
- **Hunter progression** — stats, levelling and achievements as models with a
  view model driving them (`Models/Hunter.swift`, `Models/Achievement.swift`,
  `ViewModels/HunterViewModel.swift`)
- **Stats and profile** screens (`Views/Stats/`, `Views/Profile/`)
- **Onboarding** flow for first launch (`Views/Onboarding/`)
- **Paywall** with a store view model for subscription gating
  (`Views/Shared/PaywallView.swift`, `ViewModels/StoreViewModel.swift`)
- **Design system** — centralised colour and typography tokens
  (`Design/Colors.swift`, `Design/Typography.swift`)

## Layout

```
App/          app entry point, tab navigation
Models/       Hunter, Quest, Dungeon, Achievement
ViewModels/   Hunter, Quest, Store
Views/        Home, Quests, Dungeons, Stats, Profile, Onboarding, Shared
Design/       colour + type tokens
```

## Building

Needs a Mac with Xcode 15+ and iOS 17+. See [SETUP.md](SETUP.md) for signing
and bundle identifier steps.

```
open Arise.xcodeproj
```

## Status

The full screen flow is implemented and navigable. Progression state is local
— there's no backend, no account sync, and the paywall is wired to the store
view model but not to a live App Store product. A React Native port of the same
concept lives in `arise-expo`.

## Timeline

Written April 2026 (20 source files).

Dates come from file modification times on disk, not from commit history - this repository was initialised later, so the commit dates are all from when it was published rather than when the code was written.
