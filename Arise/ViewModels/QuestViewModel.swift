import Foundation
import Combine

class QuestViewModel: ObservableObject {
    @Published var dailyQuests: [Quest] = []
    @Published var weeklyQuests: [Quest] = []
    @Published var activeQuest: Quest?
    @Published var penaltyActive: Bool = false

    private let questsKey = "daily_quests"
    private let lastGenKey = "last_quest_gen"

    init() {
        load()
    }

    func refreshIfNeeded(for hunter: Hunter) {
        let last = UserDefaults.standard.object(forKey: lastGenKey) as? Date
        let needsRefresh = last == nil || !Calendar.current.isDateInToday(last!)

        if needsRefresh || dailyQuests.isEmpty {
            dailyQuests = QuestGenerator.generateDailyQuests(for: hunter)
            UserDefaults.standard.set(Date(), forKey: lastGenKey)
            save()
        }

        // Check for failed quests → penalty
        let failedQuests = dailyQuests.filter { $0.isExpired && !$0.isCompleted }
        if !failedQuests.isEmpty && !penaltyActive {
            penaltyActive = true
        }
    }

    func completeQuest(id: UUID) {
        if let idx = dailyQuests.firstIndex(where: { $0.id == id }) {
            dailyQuests[idx].isCompleted = true
            dailyQuests[idx].completedDate = Date()
            dailyQuests[idx].progressPercent = 1.0
        }
        activeQuest = nil
        save()
    }

    func startQuest(_ quest: Quest) {
        activeQuest = quest
    }

    func updateProgress(questId: UUID, percent: Double) {
        if let idx = dailyQuests.firstIndex(where: { $0.id == questId }) {
            dailyQuests[idx].progressPercent = percent
        }
        save()
    }

    var completedToday: Int {
        dailyQuests.filter { $0.isCompleted }.count
    }

    var totalToday: Int {
        dailyQuests.count
    }

    var allCompletedToday: Bool {
        !dailyQuests.isEmpty && dailyQuests.allSatisfy { $0.isCompleted }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(dailyQuests) {
            UserDefaults.standard.set(data, forKey: questsKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: questsKey),
           let saved = try? JSONDecoder().decode([Quest].self, from: data) {
            dailyQuests = saved
        }
    }
}
