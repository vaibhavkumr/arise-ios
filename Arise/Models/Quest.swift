import Foundation

// MARK: - Quest Type

enum QuestType: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case emergency = "Emergency"
    case penalty = "Penalty"        // fail a quest → face the penalty zone
    case hidden = "Hidden"
    case chain = "Chain"

    var systemColor: String {
        switch self {
        case .daily: return "#4FC3F7"
        case .weekly: return "#A78BFA"
        case .emergency: return "#FF1744"
        case .penalty: return "#FF6D00"
        case .hidden: return "#69F0AE"
        case .chain: return "#FFD740"
        }
    }
}

// MARK: - Exercise

struct ExerciseStep: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var sets: Int?
    var reps: Int?
    var duration: Int?   // seconds
    var distance: Double? // km
    var notes: String?

    var displayText: String {
        var parts: [String] = []
        if let sets, let reps { parts.append("\(sets)x\(reps) \(name)") }
        else if let duration { parts.append("\(name) for \(duration)s") }
        else if let distance { parts.append("\(name) \(String(format: "%.1f", distance))km") }
        else { parts.append(name) }
        return parts.first ?? name
    }
}

// MARK: - Quest

struct Quest: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var systemMessage: String
    var type: QuestType
    var difficulty: HunterRank
    var exercises: [ExerciseStep]
    var xpReward: Int
    var statRewards: [String: Int]   // e.g. ["strength": 2, "vitality": 1]
    var deadline: Date?
    var isCompleted: Bool = false
    var completedDate: Date?
    var isFailed: Bool = false
    var penaltyQuest: Quest?
    var specialReward: String?       // e.g. "Shadow Soldier unlocked"

    var isExpired: Bool {
        guard let deadline else { return false }
        return Date() > deadline && !isCompleted
    }

    var progressPercent: Double = 0
}

// MARK: - Daily Quest Generator

struct QuestGenerator {
    static func generateDailyQuests(for hunter: Hunter) -> [Quest] {
        let rank = hunter.rank
        var quests: [Quest] = []

        quests.append(makeMorningQuest(rank: rank))
        quests.append(makeStrengthQuest(rank: rank))

        if hunter.stats.agility < hunter.stats.strength {
            quests.append(makeCardioQuest(rank: rank))
        } else {
            quests.append(makeEnduranceQuest(rank: rank))
        }

        if Int.random(in: 0..<4) == 0 {
            quests.append(makeHiddenQuest(rank: rank))
        }

        return quests
    }

    static func makeMorningQuest(rank: HunterRank) -> Quest {
        let reps = 10 + rank.rawValue * 5
        return Quest(
            title: "Morning Training Protocol",
            systemMessage: "The System requires your morning activation. Complete the ritual.",
            type: .daily,
            difficulty: rank,
            exercises: [
                ExerciseStep(name: "Jumping Jacks", sets: 3, reps: 20),
                ExerciseStep(name: "Push-Ups", sets: 3, reps: reps),
                ExerciseStep(name: "Sit-Ups", sets: 3, reps: reps),
                ExerciseStep(name: "Squats", sets: 3, reps: reps),
            ],
            xpReward: 50 + rank.rawValue * 25,
            statRewards: ["vitality": 1],
            deadline: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        )
    }

    static func makeStrengthQuest(rank: HunterRank) -> Quest {
        let sets = 3 + rank.rawValue
        let reps = 8 + rank.rawValue * 2
        return Quest(
            title: "Strength Enhancement Quest",
            systemMessage: "Iron will forges iron bodies. Train your muscles, Hunter.",
            type: .daily,
            difficulty: rank,
            exercises: [
                ExerciseStep(name: "Bench Press", sets: sets, reps: reps),
                ExerciseStep(name: "Deadlift", sets: sets, reps: reps - 2),
                ExerciseStep(name: "Pull-Ups", sets: 3, reps: 6 + rank.rawValue),
                ExerciseStep(name: "Dumbbell Rows", sets: sets, reps: reps),
            ],
            xpReward: 80 + rank.rawValue * 30,
            statRewards: ["strength": 2],
            deadline: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        )
    }

    static func makeCardioQuest(rank: HunterRank) -> Quest {
        let distance = 2.0 + Double(rank.rawValue) * 0.5
        return Quest(
            title: "Agility Training — Run",
            systemMessage: "Speed is survival. A Hunter who cannot escape cannot fight.",
            type: .daily,
            difficulty: rank,
            exercises: [
                ExerciseStep(name: "Run", distance: distance),
            ],
            xpReward: 60 + rank.rawValue * 20,
            statRewards: ["agility": 2],
            deadline: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        )
    }

    static func makeEnduranceQuest(rank: HunterRank) -> Quest {
        let duration = 600 + rank.rawValue * 300
        return Quest(
            title: "Endurance Protocol",
            systemMessage: "The dungeon does not wait for the weak. Build your stamina.",
            type: .daily,
            difficulty: rank,
            exercises: [
                ExerciseStep(name: "HIIT Circuit", duration: duration),
                ExerciseStep(name: "Plank Hold", sets: 3, duration: 60 + rank.rawValue * 15),
            ],
            xpReward: 70 + rank.rawValue * 25,
            statRewards: ["endurance": 2, "vitality": 1],
            deadline: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        )
    }

    static func makeHiddenQuest(rank: HunterRank) -> Quest {
        return Quest(
            title: "???",
            systemMessage: "A hidden quest has been revealed. Complete it before midnight.",
            type: .hidden,
            difficulty: rank,
            exercises: [
                ExerciseStep(name: "100 Push-Ups", sets: 1, reps: 100),
                ExerciseStep(name: "100 Sit-Ups", sets: 1, reps: 100),
                ExerciseStep(name: "100 Squats", sets: 1, reps: 100),
                ExerciseStep(name: "10km Run", distance: 10),
            ],
            xpReward: 300,
            statRewards: ["strength": 3, "endurance": 3, "agility": 3],
            deadline: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400),
            specialReward: "Shadow Soldier: Igris"
        )
    }

    static func makePenaltyQuest() -> Quest {
        return Quest(
            title: "⚠️ PENALTY ZONE ACTIVATED",
            systemMessage: "You have failed a quest. The System will not tolerate weakness. Complete the penalty or face stat reduction.",
            type: .penalty,
            difficulty: .e,
            exercises: [
                ExerciseStep(name: "Burpees", sets: 5, reps: 20),
                ExerciseStep(name: "Mountain Climbers", sets: 5, duration: 60),
                ExerciseStep(name: "Jump Squats", sets: 5, reps: 20),
            ],
            xpReward: 0,
            statRewards: [:],
            deadline: Date().addingTimeInterval(3600)
        )
    }
}
