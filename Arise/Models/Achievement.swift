import Foundation

struct Achievement: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var systemMessage: String
    var iconName: String
    var xpReward: Int
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var requirement: AchievementRequirement
}

enum AchievementRequirement: Codable {
    case workoutCount(Int)
    case dungeonCount(Int)
    case streakDays(Int)
    case rankReached(HunterRank)
    case level(Int)
    case statTotal(Int)
    case shadowArmy(Int)
    case hiddenQuestComplete
}

struct AchievementLibrary {
    static let all: [Achievement] = [
        Achievement(id: "first_blood", title: "First Blood", description: "Complete your first workout", systemMessage: "You have taken your first step. The System acknowledges your existence.", iconName: "drop.fill", xpReward: 100, requirement: .workoutCount(1)),
        Achievement(id: "streak_7", title: "Week of Shadows", description: "7-day workout streak", systemMessage: "Seven days of unbroken training. The shadows grow stronger.", iconName: "flame.fill", xpReward: 300, requirement: .streakDays(7)),
        Achievement(id: "streak_30", title: "Iron Discipline", description: "30-day workout streak", systemMessage: "A month of devotion. You are no longer human — you are a Hunter.", iconName: "crown.fill", xpReward: 1500, requirement: .streakDays(30)),
        Achievement(id: "streak_100", title: "Monarch's Path", description: "100-day workout streak", systemMessage: "100 days. The Monarch is forged through fire, not talent.", iconName: "star.fill", xpReward: 5000, requirement: .streakDays(100)),
        Achievement(id: "dungeon_1", title: "Gate Cleared", description: "Complete your first Dungeon", systemMessage: "Your first Gate has been cleared. The System has recorded your victory.", iconName: "shield.fill", xpReward: 200, requirement: .dungeonCount(1)),
        Achievement(id: "dungeon_10", title: "Shadow Raider", description: "Complete 10 Dungeons", systemMessage: "10 Gates cleared. Monsters flee at the sound of your name.", iconName: "bolt.shield.fill", xpReward: 800, requirement: .dungeonCount(10)),
        Achievement(id: "rank_d", title: "D-Rank Awakening", description: "Reach D-Rank", systemMessage: "D-Rank achieved. You are no longer cannon fodder.", iconName: "rosette", xpReward: 500, requirement: .rankReached(.d)),
        Achievement(id: "rank_s", title: "The Strongest", description: "Reach S-Rank", systemMessage: "S-Rank. There are fewer than 10 in the world. You are one of them.", iconName: "trophy.fill", xpReward: 10000, requirement: .rankReached(.s)),
        Achievement(id: "shadow_army_10", title: "Shadow Commander", description: "Build an army of 10 shadows", systemMessage: "10 shadows under your command. Arise.", iconName: "person.3.fill", xpReward: 1000, requirement: .shadowArmy(10)),
        Achievement(id: "level_10", title: "True Awakening", description: "Reach Level 10", systemMessage: "Level 10. The true journey begins now.", iconName: "arrow.up.circle.fill", xpReward: 300, requirement: .level(10)),
        Achievement(id: "level_50", title: "Shadow Monarch Candidate", description: "Reach Level 50", systemMessage: "Level 50. Few ever come this far. The shadows call to you.", iconName: "moon.stars.fill", xpReward: 2000, requirement: .level(50)),
        Achievement(id: "hidden_quest", title: "The One Who Sees Hidden Quests", description: "Complete a Hidden Quest", systemMessage: "You saw what others could not. Hidden Quest completed — the System is pleased.", iconName: "eye.fill", xpReward: 500, requirement: .hiddenQuestComplete),
    ]
}
