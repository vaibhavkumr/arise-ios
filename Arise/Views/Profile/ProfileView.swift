import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var hunterVM: HunterViewModel
    @EnvironmentObject var storeVM: StoreViewModel
    @State private var showPaywall = false
    @State private var editingName = false
    @State private var tempName = ""

    var hunter: Hunter { hunterVM.hunter }

    var body: some View {
        NavigationStack {
            ZStack {
                AColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile header
                        profileHeader

                        // Rank progress card
                        RankProgressCard(hunter: hunter)
                            .padding(.horizontal)

                        // Stats summary
                        profileStats

                        // Shadow army section
                        ShadowArmyFullView()
                            .padding(.horizontal)

                        // Subscription
                        SubscriptionCard(storeVM: storeVM) {
                            showPaywall = true
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Hunter Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(storeVM)
            }
            .alert("Change Name", isPresented: $editingName) {
                TextField("Hunter name", text: $tempName)
                Button("Save") { hunterVM.setName(tempName) }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [AColor.deepBlue, AColor.royalPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: AColor.royalPurple.opacity(0.6), radius: 16)

                Text(String(hunter.name.prefix(1)).uppercased())
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Button {
                    tempName = hunter.name
                    editingName = true
                } label: {
                    HStack(spacing: 6) {
                        Text(hunter.name.isEmpty ? "Set Name" : hunter.name)
                            .font(AFont.title(24))
                            .foregroundStyle(AColor.textPrimary)
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundStyle(AColor.textMuted)
                    }
                }
                .buttonStyle(.plain)

                Text(hunter.rank.title)
                    .font(AFont.subheading(14))
                    .foregroundStyle(rankColor)

                Text("Member since \(formatDate(hunter.joinDate))")
                    .font(AFont.caption(12))
                    .foregroundStyle(AColor.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    var profileStats: some View {
        HStack(spacing: 0) {
            ForEach([
                ("Workouts", "\(hunter.totalWorkouts)"),
                ("Dungeons", "\(hunter.totalDungeons)"),
                ("Streak", "\(hunter.streakDays)d"),
                ("Level", "Lv.\(hunter.level)"),
            ], id: \.0) { label, value in
                VStack(spacing: 4) {
                    Text(value)
                        .font(AFont.mono(18))
                        .foregroundStyle(AColor.textPrimary)
                    Text(label)
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.textMuted)
                }
                .frame(maxWidth: .infinity)
                if label != "Level" {
                    Divider().background(AColor.surfaceRaised)
                }
            }
        }
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(AColor.card))
        .padding(.horizontal)
    }

    var rankColor: Color {
        switch hunter.rank {
        case .e: return AColor.rankE
        case .d: return AColor.rankD
        case .c: return AColor.rankC
        case .b: return AColor.rankB
        case .a: return AColor.rankA
        case .s: return AColor.rankS
        case .national: return AColor.rankNational
        }
    }

    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: - Rank Progress Card

struct RankProgressCard: View {
    let hunter: Hunter

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Rank")
                        .font(AFont.caption())
                        .foregroundStyle(AColor.textMuted)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(hunter.rank.label)
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(rankColor)
                            .glowText(rankColor, radius: 8)
                        Text(hunter.rank.title)
                            .font(AFont.subheading(14))
                            .foregroundStyle(AColor.textSecondary)
                    }
                }
                Spacer()
                if let next = hunter.rank.nextRank {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Next Rank")
                            .font(AFont.caption())
                            .foregroundStyle(AColor.textMuted)
                        Text(next.label)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(AColor.textMuted)
                    }
                } else {
                    Text("MAX RANK")
                        .font(AFont.mono(12))
                        .foregroundStyle(AColor.rankNational)
                        .glowText(AColor.rankNational, radius: 4)
                }
            }

            if let next = hunter.rank.nextRank {
                let needed = next.xpRequired - hunter.totalXPEarned
                let progress = max(0, min(1, Double(hunter.totalXPEarned - hunter.rank.xpRequired) / Double(next.xpRequired - hunter.rank.xpRequired)))

                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AColor.surfaceRaised).frame(height: 10)
                            Capsule()
                                .fill(LinearGradient(colors: [rankColor, AColor.rankColor(for: next)], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * progress, height: 10)
                        }
                    }
                    .frame(height: 10)
                    .animation(.easeInOut(duration: 0.8), value: progress)

                    HStack {
                        Text("\(hunter.totalXPEarned) total XP")
                            .font(AFont.mono(11))
                            .foregroundStyle(AColor.textMuted)
                        Spacer()
                        Text("\(needed) XP to \(next.label)-Rank")
                            .font(AFont.mono(11))
                            .foregroundStyle(AColor.textMuted)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AColor.card)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(rankColor.opacity(0.2), lineWidth: 1))
        )
    }

    var rankColor: Color { AColor.rankColor(for: hunter.rank) }
}

extension AColor {
    static func rankColor(for rank: HunterRank) -> Color {
        switch rank {
        case .e: return AColor.rankE
        case .d: return AColor.rankD
        case .c: return AColor.rankC
        case .b: return AColor.rankB
        case .a: return AColor.rankA
        case .s: return AColor.rankS
        case .national: return AColor.rankNational
        }
    }
}

// MARK: - Shadow Army Full View

struct ShadowArmyFullView: View {
    @EnvironmentObject var hunterVM: HunterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Shadow Army (\(hunterVM.hunter.shadowArmy.count))",
                icon: "person.3.fill",
                color: AColor.royalPurple
            )

            if hunterVM.hunter.shadowArmy.isEmpty {
                Text("Extract shadows by clearing dungeons. They fight for you.")
                    .font(AFont.body(13))
                    .foregroundStyle(AColor.textMuted)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(AColor.card))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(hunterVM.hunter.shadowArmy) { soldier in
                        ShadowSoldierCard(soldier: soldier)
                    }
                }
            }
        }
    }
}

// MARK: - Subscription Card

struct SubscriptionCard: View {
    let storeVM: StoreViewModel
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if storeVM.isMonarch {
                        Text("👑 MONARCH PASS")
                            .font(AFont.heading(15))
                            .foregroundStyle(AColor.rankS)
                        Text("All features unlocked")
                            .font(AFont.body(12))
                            .foregroundStyle(AColor.textMuted)
                    } else if storeVM.isShadow {
                        Text("🌑 SHADOW PASS")
                            .font(AFont.heading(15))
                            .foregroundStyle(AColor.lightPurple)
                        Text("Shadow features active")
                            .font(AFont.body(12))
                            .foregroundStyle(AColor.textMuted)
                    } else {
                        Text("FREE HUNTER")
                            .font(AFont.heading(15))
                            .foregroundStyle(AColor.textSecondary)
                        Text("Upgrade to unlock advanced features")
                            .font(AFont.body(12))
                            .foregroundStyle(AColor.textMuted)
                    }
                }
                Spacer()
                if !storeVM.isMonarch {
                    Button(action: onUpgrade) {
                        Text(storeVM.isShadow ? "Upgrade" : "Go Premium")
                            .font(AFont.subheading(13))
                            .foregroundStyle(AColor.background)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AColor.rankS)
                            .clipShape(Capsule())
                    }
                }
            }

            if !storeVM.isMonarch {
                Divider().background(AColor.surfaceRaised)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Unlock with Shadow Pass ($4.99/mo):")
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.textMuted)
                    ForEach(["Advanced dungeon raids", "Party mode (workout with friends)", "Leaderboards", "Custom quest builder"], id: \.self) { feature in
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(AColor.lightPurple)
                            Text(feature)
                                .font(AFont.body(12))
                                .foregroundStyle(AColor.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(storeVM.isMonarch ? AColor.rankS.opacity(0.3) : AColor.surfaceRaised, lineWidth: 1)
                )
        )
    }
}
