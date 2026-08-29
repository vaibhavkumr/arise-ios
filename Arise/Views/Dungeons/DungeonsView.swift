import SwiftUI

struct DungeonsView: View {
    @EnvironmentObject var hunterVM: HunterViewModel
    @State private var completedDungeonIDs: Set<UUID> = []
    @State private var selectedDungeon: Dungeon?

    var availableDungeons: [Dungeon] {
        DungeonLibrary.allDungeons.filter {
            hunterVM.hunter.rank.rawValue >= $0.rank.hunterRankRequired.rawValue
        }
    }

    var lockedDungeons: [Dungeon] {
        DungeonLibrary.allDungeons.filter {
            hunterVM.hunter.rank.rawValue < $0.rank.hunterRankRequired.rawValue
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Gate status
                        GateStatusBanner(cleared: hunterVM.hunter.totalDungeons)
                            .padding(.horizontal)

                        // Available gates
                        if !availableDungeons.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Available Gates", icon: "shield.lefthalf.filled", color: AColor.royalPurple)
                                    .padding(.horizontal)

                                ForEach(availableDungeons) { dungeon in
                                    NavigationLink(destination: DungeonRaidView(dungeon: dungeon)) {
                                        DungeonCard(
                                            dungeon: dungeon,
                                            isCompleted: completedDungeonIDs.contains(dungeon.id)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // Locked gates
                        if !lockedDungeons.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Locked Gates", icon: "lock.fill", color: AColor.textMuted)
                                    .padding(.horizontal)

                                ForEach(lockedDungeons) { dungeon in
                                    LockedDungeonCard(dungeon: dungeon)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Gates")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Gate Status Banner

struct GateStatusBanner: View {
    let cleared: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AColor.royalPurple.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AColor.royalPurple)
                    .glowText(AColor.royalPurple, radius: 4)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Gates Cleared: \(cleared)")
                    .font(AFont.heading(16))
                    .foregroundStyle(AColor.textPrimary)
                Text("Enter a gate to raid. Defeat the boss. Extract the shadow.")
                    .font(AFont.body(12))
                    .foregroundStyle(AColor.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(AColor.card))
    }
}

// MARK: - Dungeon Card

struct DungeonCard: View {
    let dungeon: Dungeon
    let isCompleted: Bool
    @State private var glow = false

    var rankColor: Color {
        switch dungeon.rank {
        case .e: return AColor.rankE
        case .d: return AColor.rankD
        case .c: return AColor.rankC
        case .b: return AColor.rankB
        case .a: return AColor.rankA
        case .s: return AColor.rankS
        case .special: return AColor.rankNational
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top — rank & title
            HStack {
                Text(dungeon.rank.rawValue.uppercased())
                    .font(AFont.mono(11))
                    .foregroundStyle(rankColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rankColor.opacity(0.15))
                    .clipShape(Capsule())
                    .glowText(rankColor, radius: 2)

                Spacer()

                if dungeon.rank == .special {
                    Text("⚠️ DANGER")
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.danger)
                }

                Text("+\(dungeon.xpReward) XP")
                    .font(AFont.mono(11))
                    .foregroundStyle(AColor.xpColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Title
            Text(dungeon.name)
                .font(AFont.heading(18))
                .foregroundStyle(AColor.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 10)

            Text(dungeon.flavorText)
                .font(AFont.body(13))
                .foregroundStyle(AColor.textSecondary)
                .lineLimit(2)
                .padding(.horizontal, 16)
                .padding(.top, 4)

            // Boss preview
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.xmark")
                    .font(.system(size: 16))
                    .foregroundStyle(AColor.danger)
                Text("Boss: \(dungeon.boss.name)")
                    .font(AFont.caption(12))
                    .foregroundStyle(AColor.textSecondary)
                Spacer()
                Text("\(dungeon.phases.count) phases")
                    .font(AFont.caption(12))
                    .foregroundStyle(AColor.textMuted)
                Text("~\(dungeon.rank.durationMinutes) min")
                    .font(AFont.caption(12))
                    .foregroundStyle(AColor.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Shadow reward
            if let shadow = dungeon.shadowReward {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AColor.lightPurple)
                    Text("Shadow: \(shadow)")
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.lightPurple)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            // Enter button
            HStack {
                Spacer()
                Text(isCompleted ? "CLEARED ✓" : "ENTER GATE →")
                    .font(AFont.heading(13))
                    .foregroundStyle(isCompleted ? AColor.success : rankColor)
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rankColor.opacity(glow ? 0.6 : 0.2), lineWidth: 1)
                )
                .shadow(color: rankColor.opacity(glow ? 0.2 : 0), radius: 12)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}

// MARK: - Locked Dungeon Card

struct LockedDungeonCard: View {
    let dungeon: Dungeon

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AColor.surfaceRaised)
                    .frame(width: 44, height: 44)
                Image(systemName: "lock.fill")
                    .foregroundStyle(AColor.textMuted)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(dungeon.name)
                    .font(AFont.subheading(14))
                    .foregroundStyle(AColor.textMuted)
                Text("Requires \(dungeon.rank.hunterRankRequired.label)-Rank or higher")
                    .font(AFont.body(12))
                    .foregroundStyle(AColor.textMuted)
            }

            Spacer()

            Text(dungeon.rank.rawValue)
                .font(AFont.caption(11))
                .foregroundStyle(AColor.textMuted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AColor.card.opacity(0.5))
        )
        .opacity(0.6)
    }
}
