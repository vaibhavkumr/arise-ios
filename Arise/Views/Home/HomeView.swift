import SwiftUI

struct HomeView: View {
    @EnvironmentObject var hunterVM: HunterViewModel
    @EnvironmentObject var questVM: QuestViewModel
    @State private var showSystemMessage = true
    @State private var greeting = ""
    @State private var particles: [Particle] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AColor.background.ignoresSafeArea()
                ParticleField(particles: $particles)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // System message banner
                        if showSystemMessage {
                            SystemMessageBanner(
                                message: dailySystemMessage,
                                onDismiss: { withAnimation { showSystemMessage = false } }
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }

                        // Header — Hunter info
                        HunterHeaderCard()
                            .padding(.horizontal)
                            .padding(.top, 16)

                        // Daily progress ring
                        DailyProgressCard()
                            .padding(.horizontal)
                            .padding(.top, 16)

                        // Quick actions
                        QuickActionsRow()
                            .padding(.horizontal)
                            .padding(.top, 16)

                        // Today's quests preview
                        TodayQuestsSection()
                            .padding(.horizontal)
                            .padding(.top, 20)

                        // Shadow Army preview
                        ShadowArmyPreview()
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                questVM.refreshIfNeeded(for: hunterVM.hunter)
                spawnParticles()
            }
        }
    }

    var dailySystemMessage: String {
        let messages = [
            "A new day has begun, Hunter. Complete your quests.",
            "The gates are open. Are you prepared to raid?",
            "Your shadow army grows stronger with every workout.",
            "The System demands progress. Do not disappoint it.",
            "Every rep, every mile — the System watches.",
            "A hunter who does not train is simply prey.",
        ]
        let index = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return messages[index % messages.count]
    }

    func spawnParticles() {
        particles = (0..<20).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.1...0.4),
                speed: Double.random(in: 2...8)
            )
        }
    }
}

// MARK: - System Message Banner

struct SystemMessageBanner: View {
    let message: String
    let onDismiss: () -> Void
    @State private var visible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AColor.electricBlue)
                .font(.system(size: 16, weight: .bold))

            Text(message)
                .font(AFont.system(14))
                .foregroundStyle(AColor.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AColor.textMuted)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AColor.surfaceRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AColor.electricBlue.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : -10)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                visible = true
            }
        }
    }
}

// MARK: - Hunter Header

struct HunterHeaderCard: View {
    @EnvironmentObject var hunterVM: HunterViewModel

    var hunter: Hunter { hunterVM.hunter }

    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle().stroke(rankColor.opacity(0.5), lineWidth: 1.5)
                    )
                    .shadow(color: rankColor.opacity(0.5), radius: 8)

                Text(hunter.rank.label)
                    .font(.system(size: hunter.rank == .national ? 11 : 22, weight: .black))
                    .foregroundStyle(rankColor)
                    .glowText(rankColor, radius: 6)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(hunter.name.isEmpty ? "Hunter" : hunter.name)
                        .font(AFont.heading(20))
                        .foregroundStyle(AColor.textPrimary)
                    Text("Lv.\(hunter.level)")
                        .font(AFont.mono(13))
                        .foregroundStyle(AColor.electricBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AColor.electricBlue.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text(hunter.rank.title)
                    .font(AFont.caption())
                    .foregroundStyle(rankColor)

                // XP bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AColor.surfaceRaised)
                            .frame(height: 6)
                        Capsule()
                            .fill(
                                LinearGradient(colors: [AColor.electricBlue, AColor.royalPurple], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * hunter.xpProgress, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(hunter.currentXP) / \(hunter.xpForNextLevel) XP")
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.textMuted)
                    Spacer()
                    if hunter.streakDays > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(AColor.warning)
                                .font(.system(size: 11))
                            Text("\(hunter.streakDays) day streak")
                                .font(AFont.caption(11))
                                .foregroundStyle(AColor.warning)
                        }
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
}

// MARK: - Daily Progress Card

struct DailyProgressCard: View {
    @EnvironmentObject var questVM: QuestViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(AColor.surfaceRaised, lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        LinearGradient(colors: [AColor.electricBlue, AColor.royalPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progressFraction)

                VStack(spacing: 0) {
                    Text("\(questVM.completedToday)")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AColor.textPrimary)
                    Text("/ \(questVM.totalToday)")
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Daily Quests")
                    .font(AFont.heading(16))
                    .foregroundStyle(AColor.textPrimary)

                Text(questVM.allCompletedToday ? "All quests complete. The System is satisfied." : "\(questVM.totalToday - questVM.completedToday) quests remaining")
                    .font(AFont.body(13))
                    .foregroundStyle(questVM.allCompletedToday ? AColor.success : AColor.textSecondary)

                if questVM.allCompletedToday {
                    Label("QUEST CLEAR", systemImage: "checkmark.seal.fill")
                        .font(AFont.caption(11))
                        .foregroundStyle(AColor.success)
                        .glowText(AColor.success, radius: 4)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AColor.card)
        )
    }

    var progressFraction: CGFloat {
        guard questVM.totalToday > 0 else { return 0 }
        return CGFloat(questVM.completedToday) / CGFloat(questVM.totalToday)
    }
}

// MARK: - Quick Actions

struct QuickActionsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: DungeonsView()) {
                QuickActionButton(icon: "shield.lefthalf.filled", label: "Enter Gate", color: AColor.royalPurple)
            }
            NavigationLink(destination: QuestsView()) {
                QuickActionButton(icon: "scroll.fill", label: "Quests", color: AColor.electricBlue)
            }
            NavigationLink(destination: StatsView()) {
                QuickActionButton(icon: "chart.bar.fill", label: "Stats", color: AColor.rankS)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.15))
                    .frame(height: 56)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(color)
                    .glowText(color, radius: 4)
            }
            Text(label)
                .font(AFont.caption(11))
                .foregroundStyle(AColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Today's Quests Section

struct TodayQuestsSection: View {
    @EnvironmentObject var questVM: QuestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Today's Quests", icon: "scroll.fill", color: AColor.electricBlue)

            ForEach(questVM.dailyQuests.prefix(3)) { quest in
                NavigationLink(destination: QuestDetailView(quest: quest)) {
                    QuestRowCard(quest: quest)
                }
                .buttonStyle(.plain)
            }

            if questVM.dailyQuests.count > 3 {
                NavigationLink(destination: QuestsView()) {
                    Text("View all \(questVM.dailyQuests.count) quests →")
                        .font(AFont.caption())
                        .foregroundStyle(AColor.electricBlue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

// MARK: - Shadow Army Preview

struct ShadowArmyPreview: View {
    @EnvironmentObject var hunterVM: HunterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Shadow Army", icon: "person.3.fill", color: AColor.royalPurple)

            if hunterVM.hunter.shadowArmy.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(AColor.textMuted)
                    Text("No shadows yet. Complete dungeons to extract soldiers.")
                        .font(AFont.body(13))
                        .foregroundStyle(AColor.textMuted)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(AColor.card))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(hunterVM.hunter.shadowArmy) { soldier in
                            ShadowSoldierCard(soldier: soldier)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
}

struct ShadowSoldierCard: View {
    let soldier: ShadowSoldier

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AColor.royalPurple.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .shadow(color: AColor.royalPurple.opacity(0.5), radius: 8)
                Image(systemName: "person.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AColor.lightPurple)
            }
            Text(soldier.name)
                .font(AFont.caption(11))
                .foregroundStyle(AColor.textSecondary)
                .multilineTextAlignment(.center)
            Text("Lv.\(soldier.level)")
                .font(AFont.mono(10))
                .foregroundStyle(AColor.royalPurple)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AColor.card))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(title)
                .font(AFont.heading(15))
                .foregroundStyle(AColor.textPrimary)
        }
    }
}

// MARK: - Particle System

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
}

struct ParticleField: View {
    @Binding var particles: [Particle]
    @State private var animating = false

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { p in
                Circle()
                    .fill(AColor.electricBlue)
                    .frame(width: p.size, height: p.size)
                    .opacity(animating ? p.opacity : 0)
                    .position(
                        x: p.x * geo.size.width,
                        y: animating ? p.y * geo.size.height - 50 : p.y * geo.size.height
                    )
                    .animation(
                        .easeInOut(duration: p.speed)
                        .repeatForever(autoreverses: true),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Level Up Overlay

struct LevelUpOverlay: View {
    let level: Int
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                Text("LEVEL UP")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(AColor.rankS)
                    .glowText(AColor.rankS, radius: 16)

                Text("Level \(level)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AColor.textPrimary)

                Text("The System acknowledges your growth.")
                    .font(AFont.system(16))
                    .foregroundStyle(AColor.electricBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button("CONTINUE") { onDismiss() }
                    .font(AFont.heading(16))
                    .foregroundStyle(AColor.background)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
                    .background(AColor.electricBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AColor.electricBlue.opacity(0.5), radius: 12)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
}
