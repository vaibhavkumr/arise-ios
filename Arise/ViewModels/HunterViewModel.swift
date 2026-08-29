import Foundation
import Combine

class HunterViewModel: ObservableObject {
    @Published var hunter: Hunter
    @Published var achievements: [Achievement]
    @Published var justLeveledUp: Bool = false
    @Published var justRankedUp: Bool = false
    @Published var newAchievement: Achievement?

    private let saveKey = "saved_hunter"
    private let achievementsKey = "achievements"

    init() {
        if let data = UserDefaults.standard.data(forKey: "saved_hunter"),
           let saved = try? JSONDecoder().decode(Hunter.self, from: data) {
            self.hunter = saved
        } else {
            self.hunter = Hunter(name: "Hunter")
        }

        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = saved
        } else {
            self.achievements = AchievementLibrary.all
        }
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(hunter) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }

    // MARK: - XP & Level

    func awardXP(_ amount: Int) {
        let prevRank = hunter.rank
        let leveledUp = hunter.addXP(amount)

        if leveledUp {
            justLeveledUp = true
        }
        if hunter.rank != prevRank {
            justRankedUp = true
        }

        checkAchievements()
        save()
    }

    // MARK: - Stat Improvements

    func improveStats(_ rewards: [String: Int]) {
        for (stat, amount) in rewards {
            switch stat {
            case "strength":   hunter.stats.strength += amount
            case "agility":    hunter.stats.agility += amount
            case "vitality":   hunter.stats.vitality += amount
            case "endurance":  hunter.stats.endurance += amount
            case "intelligence": hunter.stats.intelligence += amount
            default: break
            }
        }
        save()
    }

    // MARK: - Streak

    func recordActivity() {
        hunter.updateStreak()
        hunter.totalWorkouts += 1
        checkAchievements()
        save()
    }

    // MARK: - Shadow Army

    func addShadowSoldier(name: String, type: ShadowSoldier.SoldierType, from workout: String) {
        let soldier = ShadowSoldier(name: name, type: type, level: hunter.level, extractedFrom: workout)
        hunter.shadowArmy.append(soldier)
        checkAchievements()
        save()
    }

    // MARK: - Dungeon Completed

    func completeDungeon(_ dungeon: Dungeon) {
        hunter.totalDungeons += 1
        awardXP(dungeon.xpReward)
        improveStats(dungeon.bonusStatRewards)

        if let shadowName = dungeon.shadowReward {
            let types = ShadowSoldier.SoldierType.allCases
            let type = types[hunter.totalDungeons % types.count]
            addShadowSoldier(name: shadowName, type: type, from: dungeon.name)
        }

        checkAchievements()
        save()
    }

    // MARK: - Quest Completed

    func completeQuest(_ quest: Quest) {
        awardXP(quest.xpReward)
        improveStats(quest.statRewards)
        recordActivity()

        if quest.type == .hidden {
            unlockAchievement(id: "hidden_quest")
        }
    }

    // MARK: - Achievements

    func checkAchievements() {
        for (i, achievement) in achievements.enumerated() {
            guard !achievement.isUnlocked else { continue }

            var shouldUnlock = false
            switch achievement.requirement {
            case .workoutCount(let n):   shouldUnlock = hunter.totalWorkouts >= n
            case .dungeonCount(let n):   shouldUnlock = hunter.totalDungeons >= n
            case .streakDays(let n):     shouldUnlock = hunter.streakDays >= n
            case .rankReached(let r):    shouldUnlock = hunter.rank.rawValue >= r.rawValue
            case .level(let n):          shouldUnlock = hunter.level >= n
            case .statTotal(let n):      shouldUnlock = hunter.stats.total >= n
            case .shadowArmy(let n):     shouldUnlock = hunter.shadowArmy.count >= n
            case .hiddenQuestComplete:   break
            }

            if shouldUnlock {
                achievements[i].isUnlocked = true
                achievements[i].unlockedDate = Date()
                awardXP(achievement.xpReward)
                newAchievement = achievements[i]
            }
        }
    }

    func unlockAchievement(id: String) {
        guard let idx = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) else { return }
        achievements[idx].isUnlocked = true
        achievements[idx].unlockedDate = Date()
        awardXP(achievements[idx].xpReward)
        newAchievement = achievements[idx]
        save()
    }

    // MARK: - Name Setup

    func setName(_ name: String) {
        hunter.name = name
        save()
    }
}
