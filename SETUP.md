# Arise — Solo Leveling Fitness RPG

## Opening in Xcode

1. Open `Arise.xcodeproj` in Xcode 15+ on a Mac
2. Select your Team in Signing & Capabilities
3. Change Bundle ID from `com.arise.fitness` to something unique you own
4. Build & Run on iPhone simulator or device (iOS 17+)

## Publishing to App Store

### 1. App Store Connect Setup
- Create app at appstoreconnect.apple.com
- Bundle ID: your chosen ID
- Set up In-App Purchases (see Monetization below)

### 2. In-App Purchase Setup (App Store Connect)
Create 4 subscription products:
| Product ID | Type | Price |
|---|---|---|
| `com.arise.fitness.shadow.monthly` | Auto-Renewable Subscription | $4.99/mo |
| `com.arise.fitness.shadow.yearly` | Auto-Renewable Subscription | $39.99/yr |
| `com.arise.fitness.monarch.monthly` | Auto-Renewable Subscription | $9.99/mo |
| `com.arise.fitness.monarch.yearly` | Auto-Renewable Subscription | $79.99/yr |

Group: "Arise Premium" → Subscription Groups in App Store Connect

### 3. StoreKit Configuration (Testing)
In Xcode: File → New → File → StoreKit Configuration File
Add the same 4 product IDs for local testing.

### 4. Capabilities to Enable (Xcode)
- In-App Purchase ✓
- HealthKit ✓ (optional — for real workout sync)

## App Store Listing

**Name:** Arise: Fitness RPG

**Subtitle:** Solo Leveling Workout Tracker

**Description:**
You have been detected by the System.

Arise is the fitness app for people who think regular workout trackers are boring. Built on the Solo Leveling universe aesthetic — dark, dramatic, and rewarding.

FEATURES:
• Hunter Ranking System (E → D → C → B → A → S → National Level)
• Daily Quest Board — The System assigns your workouts
• Gate Raids — Dungeon-style workout challenges with boss battles
• Shadow Army — Extract soldiers from completed dungeons
• 5 Stats: STR, AGI, VIT, END, INT — grow them with real training
• Level up with XP from every workout
• 12+ Achievements to unlock
• Penalty Zone — skip a quest and face the consequences
• RPG Onboarding — Choose your class (Warrior, Assassin, Tank, Mage, Healer)

FREE: Full quest system, E-D rank dungeons, basic stats tracking
SHADOW PASS ($4.99/mo): Advanced dungeons, party mode, leaderboards
MONARCH PASS ($9.99/mo): Everything + AI programming, exclusive content

**Keywords:** fitness, workout, RPG, solo leveling, hunter, gym, exercise, tracker, anime, level up

**Category:** Health & Fitness

**Age Rating:** 4+

## Monetization Strategy

### Revenue Model
- Free tier: Full core experience (E-D rank content)
- Shadow Pass: $4.99/mo or $39.99/yr (~$3.33/mo)
- Monarch Pass: $9.99/mo or $79.99/yr (~$6.67/mo)

### Target: 1,000 subscribers @ avg $6/mo = $6,000 MRR

### Growth Channels
1. TikTok/YouTube: "I trained like Sung Jin-Woo for 30 days"
2. Reddit: r/sololeveling, r/fitness, r/bodyweightfitness
3. Instagram: Daily workout screenshots with the dark UI
4. The anime/manhwa fandom crossover is the unique hook

## Architecture

```
Arise/
├── App/              — Entry point, tab view
├── Design/           — Colors, typography system
├── Models/           — Hunter, Quest, Dungeon, Achievement data
├── ViewModels/       — Business logic (Hunter, Quest, Store)
└── Views/
    ├── Onboarding/   — 4-page onboarding flow
    ├── Home/         — Dashboard with hunter card, quests preview
    ├── Quests/       — Quest board + active quest tracker
    ├── Dungeons/     — Gate list + dungeon raid flow
    ├── Stats/        — Radar chart, stat details, achievements
    ├── Profile/      — Hunter profile, rank progress, shadow army
    └── Shared/       — Paywall, reusable components
```

## What to Build Next (Phase 2)
- [ ] HealthKit integration — award XP from real workout data
- [ ] Push notifications — daily quest reminders from "The System"
- [ ] Party mode — invite friends to raid dungeons together
- [ ] Leaderboard — global S-rank chase
- [ ] Custom quest builder — create your own training programs
- [ ] iCloud sync — progress across devices
- [ ] Apple Watch app — workout tracking on wrist
- [ ] Animated gate opening sequence (Lottie)
- [ ] Boss artwork (commission an artist on Fiverr)
