import Foundation

// MARK: - Dungeon Rank

enum DungeonRank: String, Codable, CaseIterable {
    case e = "E-Rank Gate"
    case d = "D-Rank Gate"
    case c = "C-Rank Gate"
    case b = "B-Rank Gate"
    case a = "A-Rank Gate"
    case s = "S-Rank Gate"
    case special = "Red Gate"

    var hunterRankRequired: HunterRank {
        switch self {
        case .e: return .e
        case .d: return .d
        case .c: return .c
        case .b: return .b
        case .a: return .a
        case .s: return .s
        case .special: return .b
        }
    }

    var durationMinutes: Int {
        switch self {
        case .e: return 10
        case .d: return 20
        case .c: return 30
        case .b: return 45
        case .a: return 60
        case .s: return 75
        case .special: return 90
        }
    }
}

// MARK: - Boss

struct DungeonBoss: Codable {
    var name: String
    var description: String
    var hpTotal: Int
    var hpRemaining: Int
    var imageName: String

    var hpPercent: Double {
        Double(hpRemaining) / Double(hpTotal)
    }
}

// MARK: - Dungeon

struct Dungeon: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var flavorText: String
    var rank: DungeonRank
    var boss: DungeonBoss
    var phases: [DungeonPhase]
    var xpReward: Int
    var bonusStatRewards: [String: Int]
    var shadowReward: String?
    var isCompleted: Bool = false
    var completedDate: Date?
    var timeElapsed: TimeInterval = 0
    var stars: Int = 0               // 1-3 stars based on performance

    // Progress
    var currentPhase: Int = 0
    var bossDefeated: Bool = false
}

// MARK: - Dungeon Phase

struct DungeonPhase: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var exercises: [ExerciseStep]
    var bossHpDamage: Int       // completing this phase deals this much boss HP damage
    var isCompleted: Bool = false
}

// MARK: - Dungeon Library

struct DungeonLibrary {
    static let allDungeons: [Dungeon] = [
        Dungeon(
            name: "Cavern of Iron Will",
            flavorText: "An E-Rank gate pulses weakly at the edge of the city. Your first gate awaits.",
            rank: .e,
            boss: DungeonBoss(name: "Stone Golem", description: "A slow but powerful construct. Wear it down.", hpTotal: 1000, hpRemaining: 1000, imageName: "boss_golem"),
            phases: [
                DungeonPhase(name: "Phase 1 — Entrance", description: "Clear the outer cavern.", exercises: [
                    ExerciseStep(name: "Jumping Jacks", sets: 3, reps: 30),
                    ExerciseStep(name: "Push-Ups", sets: 3, reps: 15),
                ], bossHpDamage: 333),
                DungeonPhase(name: "Phase 2 — Boss Chamber", description: "The Golem awakens.", exercises: [
                    ExerciseStep(name: "Squats", sets: 3, reps: 20),
                    ExerciseStep(name: "Lunges", sets: 3, reps: 16),
                ], bossHpDamage: 333),
                DungeonPhase(name: "Final Phase — Defeat the Boss", description: "Finish it.", exercises: [
                    ExerciseStep(name: "Burpees", sets: 3, reps: 10),
                    ExerciseStep(name: "Mountain Climbers", duration: 60),
                ], bossHpDamage: 334),
            ],
            xpReward: 200,
            bonusStatRewards: ["strength": 2, "vitality": 1],
            shadowReward: "Stone Soldier"
        ),
        Dungeon(
            name: "The Shadow Marsh",
            flavorText: "A D-Rank gate. Shadows move within. Are you ready?",
            rank: .d,
            boss: DungeonBoss(name: "Marsh Wraith", description: "A shadow creature born of despair. Fast and relentless.", hpTotal: 2500, hpRemaining: 2500, imageName: "boss_wraith"),
            phases: [
                DungeonPhase(name: "Phase 1 — The Swamp", description: "Push through the fog.", exercises: [
                    ExerciseStep(name: "Run", distance: 1.0),
                    ExerciseStep(name: "Pull-Ups", sets: 4, reps: 8),
                ], bossHpDamage: 833),
                DungeonPhase(name: "Phase 2 — Shadow Ambush", description: "Shadows attack from all sides.", exercises: [
                    ExerciseStep(name: "HIIT Sprint Intervals", duration: 600),
                    ExerciseStep(name: "Dips", sets: 4, reps: 12),
                ], bossHpDamage: 833),
                DungeonPhase(name: "Boss Phase — Wraith Rising", description: "The Wraith reveals its true form.", exercises: [
                    ExerciseStep(name: "Box Jumps", sets: 4, reps: 15),
                    ExerciseStep(name: "Plank", sets: 3, duration: 60),
                    ExerciseStep(name: "Burpees", sets: 3, reps: 15),
                ], bossHpDamage: 834),
            ],
            xpReward: 500,
            bonusStatRewards: ["agility": 3, "endurance": 2],
            shadowReward: "Marsh Stalker"
        ),
        Dungeon(
            name: "Dungeon of Iron Blood",
            flavorText: "C-Rank. Casualties among weak hunters are reported. Enter if you dare.",
            rank: .c,
            boss: DungeonBoss(name: "Iron Knight Commander", description: "A warrior who has never known defeat. Until today.", hpTotal: 5000, hpRemaining: 5000, imageName: "boss_knight"),
            phases: [
                DungeonPhase(name: "Phase 1 — The Iron Corridor", description: "Knight patrols await.", exercises: [
                    ExerciseStep(name: "Barbell Squat", sets: 5, reps: 10),
                    ExerciseStep(name: "Bent-Over Row", sets: 5, reps: 10),
                    ExerciseStep(name: "Overhead Press", sets: 4, reps: 10),
                ], bossHpDamage: 1666),
                DungeonPhase(name: "Phase 2 — The Throne Room", description: "Elite Knights guard the commander.", exercises: [
                    ExerciseStep(name: "Deadlift", sets: 4, reps: 8),
                    ExerciseStep(name: "Weighted Pull-Ups", sets: 4, reps: 8),
                    ExerciseStep(name: "Dumbbell Bench Press", sets: 4, reps: 10),
                ], bossHpDamage: 1666),
                DungeonPhase(name: "Final Phase — Iron Knight", description: "The Commander's full power unleashed.", exercises: [
                    ExerciseStep(name: "Clean & Press", sets: 5, reps: 8),
                    ExerciseStep(name: "Farmer's Carry", duration: 120),
                    ExerciseStep(name: "Battle Rope Slams", sets: 5, duration: 30),
                ], bossHpDamage: 1668),
            ],
            xpReward: 1200,
            bonusStatRewards: ["strength": 4, "endurance": 3],
            shadowReward: "Iron Knight"
        ),
        Dungeon(
            name: "Red Gate — Demon's Lair",
            flavorText: "⚠️ RED GATE DETECTED. Hunters who enter may not return. This is not a drill.",
            rank: .special,
            boss: DungeonBoss(name: "Demon Lord Baran", description: "A demon king of catastrophic power. This is your ultimate test.", hpTotal: 10000, hpRemaining: 10000, imageName: "boss_demon"),
            phases: [
                DungeonPhase(name: "Phase 1 — Demon's Threshold", description: "Survive the initial onslaught.", exercises: [
                    ExerciseStep(name: "Pull-Ups", sets: 5, reps: 15),
                    ExerciseStep(name: "Dips", sets: 5, reps: 15),
                    ExerciseStep(name: "Sprint 400m", sets: 5),
                ], bossHpDamage: 2500),
                DungeonPhase(name: "Phase 2 — Hellfire Corridor", description: "The heat of hell itself.", exercises: [
                    ExerciseStep(name: "Barbell Squat", sets: 5, reps: 12),
                    ExerciseStep(name: "Deadlift", sets: 5, reps: 10),
                    ExerciseStep(name: "HIIT", duration: 900),
                ], bossHpDamage: 2500),
                DungeonPhase(name: "Phase 3 — Baran's Army", description: "Endless waves of demons.", exercises: [
                    ExerciseStep(name: "Box Jumps", sets: 5, reps: 20),
                    ExerciseStep(name: "Clean & Jerk", sets: 5, reps: 8),
                    ExerciseStep(name: "Rope Climbs", sets: 5, reps: 3),
                ], bossHpDamage: 2500),
                DungeonPhase(name: "FINAL PHASE — Demon Lord Baran", description: "NO RETREAT. NO SURRENDER.", exercises: [
                    ExerciseStep(name: "1 Mile Run", distance: 1.6),
                    ExerciseStep(name: "100 Burpees", sets: 1, reps: 100),
                    ExerciseStep(name: "50 Pull-Ups", sets: 1, reps: 50),
                ], bossHpDamage: 2500),
            ],
            xpReward: 5000,
            bonusStatRewards: ["strength": 8, "agility": 6, "vitality": 6, "endurance": 8],
            shadowReward: "Demon Commander Baran"
        ),
    ]
}
