import Foundation

// MARK: - Hunter Rank

enum HunterRank: Int, CaseIterable, Codable {
    case e = 0, d, c, b, a, s, national

    var label: String {
        switch self {
        case .e: return "E"
        case .d: return "D"
        case .c: return "C"
        case .b: return "B"
        case .a: return "A"
        case .s: return "S"
        case .national: return "NATIONAL"
        }
    }

    var title: String {
        switch self {
        case .e: return "Awakened"
        case .d: return "Novice Hunter"
        case .c: return "Field Hunter"
        case .b: return "Elite Hunter"
        case .a: return "Shadow Monarch"
        case .s: return "S-Rank Hunter"
        case .national: return "National Level Hunter"
        }
    }

    var xpRequired: Int {
        switch self {
        case .e: return 0
        case .d: return 1_000
        case .c: return 5_000
        case .b: return 15_000
        case .a: return 40_000
        case .s: return 100_000
        case .national: return 250_000
        }
    }

    var nextRank: HunterRank? {
        HunterRank(rawValue: rawValue + 1)
    }

    var systemMessage: String {
        switch self {
        case .e: return "The System has detected your awakening. Begin your training, Hunter."
        case .d: return "You have proven your worth. D-Rank acknowledged."
        case .c: return "The gates tremble before you. C-Rank Hunter — rise."
        case .b: return "Few reach this level. Your shadow grows stronger."
        case .a: return "You stand among the elite. The shadow army awaits your command."
        case .s: return "S-Rank. The world will know your name."
        case .national: return "NATIONAL LEVEL HUNTER. You are no longer bound by limits."
        }
    }
}

// MARK: - Hunter Stats

struct HunterStats: Codable {
    var strength: Int = 10     // STR — from lifts/push/pull workouts
    var agility: Int = 10      // AGI — from cardio/speed
    var vitality: Int = 10     // VIT — from endurance/HIIT
    var endurance: Int = 10    // END — from duration/consistency
    var intelligence: Int = 10 // INT — from flexibility/mobility/tracking

    var total: Int { strength + agility + vitality + endurance + intelligence }
}

// MARK: - Hunter

struct Hunter: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var rank: HunterRank = .e
    var level: Int = 1
    var currentXP: Int = 0
    var stats: HunterStats = HunterStats()
    var streakDays: Int = 0
    var lastActiveDate: Date?
    var totalWorkouts: Int = 0
    var totalDungeons: Int = 0
    var shadowArmy: [ShadowSoldier] = []
    var achievements: [String] = []
    var joinDate: Date = Date()
    var subscriptionTier: SubscriptionTier = .free

    var xpForNextLevel: Int {
        level * 100 + (level * level * 10)
    }

    var xpProgress: Double {
        Double(currentXP) / Double(xpForNextLevel)
    }

    var xpForNextRank: Int {
        rank.nextRank?.xpRequired ?? rank.xpRequired
    }

    var totalXPEarned: Int {
        rank.xpRequired + currentXP
    }

    mutating func addXP(_ amount: Int) -> Bool {
        currentXP += amount
        var leveledUp = false

        while currentXP >= xpForNextLevel {
            currentXP -= xpForNextLevel
            level += 1
            leveledUp = true
        }

        if let next = rank.nextRank, totalXPEarned >= next.xpRequired {
            rank = next
        }

        return leveledUp
    }

    mutating func updateStreak() {
        let calendar = Calendar.current
        let now = Date()

        if let last = lastActiveDate {
            let daysDiff = calendar.dateComponents([.day], from: last, to: now).day ?? 0
            if daysDiff == 1 {
                streakDays += 1
            } else if daysDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActiveDate = now
    }
}

// MARK: - Shadow Soldier (Shadow Army)

struct ShadowSoldier: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: SoldierType
    var level: Int
    var extractedFrom: String // workout that created it

    enum SoldierType: String, Codable, CaseIterable {
        case ironBody = "Iron Body"      // from strength workouts
        case swiftShadow = "Swift Shadow" // from cardio
        case steelHeart = "Steel Heart"  // from endurance
        case strikeFang = "Strike Fang"  // from HIIT
        case silentStep = "Silent Step"  // from yoga/flexibility
    }
}

// MARK: - Subscription

enum SubscriptionTier: String, Codable {
    case free
    case shadow   // $4.99/mo
    case monarch  // $9.99/mo
}
