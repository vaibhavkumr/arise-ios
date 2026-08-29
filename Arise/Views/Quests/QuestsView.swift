import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var hunterVM: HunterViewModel
    @EnvironmentObject var questVM: QuestViewModel
    @State private var selectedType: QuestType? = nil

    var filteredQuests: [Quest] {
        if let type = selectedType {
            return questVM.dailyQuests.filter { $0.type == type }
        }
        return questVM.dailyQuests
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Penalty zone warning
                        if questVM.penaltyActive {
                            PenaltyZoneBanner()
                                .padding(.horizontal)
                        }

                        // Quest type filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(label: "All", isActive: selectedType == nil) {
                                    selectedType = nil
                                }
                                ForEach(QuestType.allCases, id: \.self) { type in
                                    FilterChip(label: type.rawValue, isActive: selectedType == type) {
                                        selectedType = type
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Quest progress summary
                        QuestProgressSummary(
                            completed: questVM.completedToday,
                            total: questVM.totalToday
                        )
                        .padding(.horizontal)

                        // Quest list
                        LazyVStack(spacing: 12) {
                            ForEach(filteredQuests) { quest in
                                NavigationLink(destination: QuestDetailView(quest: quest)) {
                                    QuestRowCard(quest: quest)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Quest Board")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            questVM.refreshIfNeeded(for: hunterVM.hunter)
        }
    }
}

// MARK: - Penalty Zone Banner

struct PenaltyZoneBanner: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.octagon.fill")
                .foregroundStyle(AColor.danger)
                .font(.system(size: 20))
                .scaleEffect(pulse ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: pulse)

            VStack(alignment: .leading, spacing: 2) {
                Text("⚠️ PENALTY ZONE ACTIVATED")
                    .font(AFont.subheading())
                    .foregroundStyle(AColor.danger)
                Text("You failed a quest. Complete the penalty or lose stats.")
                    .font(AFont.body(12))
                    .foregroundStyle(AColor.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AColor.danger.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AColor.danger.opacity(0.4), lineWidth: 1))
        )
        .onAppear { pulse = true }
    }
}

// MARK: - Quest Progress Summary

struct QuestProgressSummary: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(completed) of \(total) Quests Complete")
                    .font(AFont.subheading())
                    .foregroundStyle(AColor.textPrimary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AColor.surfaceRaised).frame(height: 8)
                        Capsule()
                            .fill(LinearGradient(colors: [AColor.electricBlue, AColor.royalPurple], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * (total > 0 ? CGFloat(completed)/CGFloat(total) : 0), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AColor.card))
    }
}

// MARK: - Quest Row Card

struct QuestRowCard: View {
    let quest: Quest

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(questTypeColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: questIcon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(questTypeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(quest.title)
                        .font(AFont.subheading(14))
                        .foregroundStyle(quest.isCompleted ? AColor.textMuted : AColor.textPrimary)
                        .strikethrough(quest.isCompleted)
                        .lineLimit(1)

                    Spacer()

                    Text(quest.type.rawValue)
                        .font(AFont.caption(10))
                        .foregroundStyle(questTypeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(questTypeColor.opacity(0.15))
                        .clipShape(Capsule())
                }

                HStack(spacing: 8) {
                    Text("\(quest.exercises.count) exercises")
                        .font(AFont.body(12))
                        .foregroundStyle(AColor.textMuted)

                    Text("•")
                        .foregroundStyle(AColor.textMuted)
                        .font(AFont.body(12))

                    Text("+\(quest.xpReward) XP")
                        .font(AFont.mono(12))
                        .foregroundStyle(AColor.xpColor)
                }

                // Progress bar
                if quest.progressPercent > 0 && !quest.isCompleted {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AColor.surfaceRaised).frame(height: 3)
                            Capsule()
                                .fill(questTypeColor)
                                .frame(width: geo.size.width * quest.progressPercent, height: 3)
                        }
                    }
                    .frame(height: 3)
                }
            }

            if quest.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AColor.success)
                    .font(.system(size: 20))
                    .glowText(AColor.success, radius: 4)
            } else if quest.isExpired {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(AColor.danger)
                    .font(.system(size: 20))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(AColor.textMuted)
                    .font(.system(size: 14))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(quest.isCompleted ? AColor.success.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        )
        .opacity(quest.isExpired && !quest.isCompleted ? 0.5 : 1)
    }

    var questTypeColor: Color {
        Color(hex: quest.type.systemColor)
    }

    var questIcon: String {
        switch quest.type {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar"
        case .emergency: return "bolt.fill"
        case .penalty: return "exclamationmark.triangle.fill"
        case .hidden: return "eye.slash.fill"
        case .chain: return "link"
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AFont.caption(12))
                .foregroundStyle(isActive ? AColor.background : AColor.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isActive ? AColor.electricBlue : AColor.surfaceRaised)
                )
        }
        .buttonStyle(.plain)
    }
}
