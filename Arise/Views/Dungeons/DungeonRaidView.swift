import SwiftUI

struct DungeonRaidView: View {
    let dungeon: Dungeon
    @EnvironmentObject var hunterVM: HunterViewModel
    @Environment(\.dismiss) var dismiss

    @State private var dungeonState = DungeonState()
    @State private var showVictory = false
    @State private var bossHP: Double = 1.0
    @State private var bossShake = false

    struct DungeonState {
        var currentPhase = 0
        var completedExercises: Set<UUID> = []
        var phaseCompleted: Set<Int> = []
        var started = false
        var bossHPRemaining: Int = 0
        var timerSeconds = 0
        var timerRunning = false
    }

    var currentPhase: DungeonPhase? {
        guard dungeonState.currentPhase < dungeon.phases.count else { return nil }
        return dungeon.phases[dungeonState.currentPhase]
    }

    var body: some View {
        ZStack {
            AColor.background.ignoresSafeArea()

            if showVictory {
                DungeonVictoryView(dungeon: dungeon, timeSeconds: dungeonState.timerSeconds) {
                    dismiss()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Boss HP bar
                        BossHPBar(dungeon: dungeon, hpPercent: bossHP)
                            .padding(.horizontal)

                        // Phase progress
                        PhaseProgressRow(
                            phases: dungeon.phases,
                            currentPhase: dungeonState.currentPhase,
                            completedPhases: dungeonState.phaseCompleted
                        )
                        .padding(.horizontal)

                        // Current phase
                        if let phase = currentPhase {
                            PhaseCard(
                                phase: phase,
                                phaseIndex: dungeonState.currentPhase,
                                completedExercises: $dungeonState.completedExercises,
                                onPhaseComplete: completeCurrentPhase
                            )
                            .padding(.horizontal)
                        }

                        // Phase nav
                        if dungeonState.currentPhase < dungeon.phases.count {
                            phaseNavigation
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle(dungeon.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            dungeonState.bossHPRemaining = dungeon.boss.hpTotal
            bossHP = 1.0
        }
    }

    var phaseNavigation: some View {
        let phase = currentPhase
        let allDone = phase?.exercises.allSatisfy { dungeonState.completedExercises.contains($0.id) } ?? false

        return Button {
            guard allDone else { return }
            completeCurrentPhase()
        } label: {
            HStack {
                Image(systemName: dungeonState.currentPhase == dungeon.phases.count - 1 ? "trophy.fill" : "arrow.right.circle.fill")
                Text(dungeonState.currentPhase == dungeon.phases.count - 1 ? "DEFEAT THE BOSS" : "NEXT PHASE →")
            }
            .font(AFont.heading(16))
            .foregroundStyle(allDone ? AColor.background : AColor.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(allDone ? AColor.royalPurple : AColor.surfaceRaised)
                    .shadow(color: allDone ? AColor.royalPurple.opacity(0.5) : .clear, radius: 12)
            )
        }
        .disabled(!allDone)
        .animation(.easeInOut(duration: 0.3), value: allDone)
    }

    func completeCurrentPhase() {
        let phase = dungeon.phases[dungeonState.currentPhase]

        // Damage boss
        let newHP = max(0, dungeonState.bossHPRemaining - phase.bossHpDamage)
        dungeonState.bossHPRemaining = newHP
        withAnimation(.easeInOut(duration: 0.6)) {
            bossHP = Double(newHP) / Double(dungeon.boss.hpTotal)
        }

        // Shake boss
        withAnimation(.default) { bossShake = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bossShake = false }

        dungeonState.phaseCompleted.insert(dungeonState.currentPhase)
        dungeonState.completedExercises = []

        if dungeonState.currentPhase >= dungeon.phases.count - 1 {
            // Dungeon complete
            hunterVM.completeDungeon(dungeon)
            withAnimation { showVictory = true }
        } else {
            dungeonState.currentPhase += 1
        }
    }
}

// MARK: - Boss HP Bar

struct BossHPBar: View {
    let dungeon: Dungeon
    let hpPercent: Double
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "person.crop.circle.badge.xmark")
                    .foregroundStyle(AColor.danger)
                    .font(.system(size: 16))
                Text(dungeon.boss.name)
                    .font(AFont.heading(16))
                    .foregroundStyle(AColor.textPrimary)
                Spacer()
                Text("\(Int(hpPercent * 100))% HP")
                    .font(AFont.mono(13))
                    .foregroundStyle(hpPercent > 0.5 ? AColor.success : hpPercent > 0.25 ? AColor.warning : AColor.danger)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AColor.surfaceRaised)
                        .frame(height: 14)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [AColor.danger, hpPercent > 0.5 ? AColor.success : AColor.warning],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * hpPercent, height: 14)
                        .animation(.easeInOut(duration: 0.6), value: hpPercent)
                }
            }
            .frame(height: 14)

            Text(dungeon.boss.description)
                .font(AFont.body(12))
                .foregroundStyle(AColor.textMuted)
                .italic()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AColor.card)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AColor.danger.opacity(pulse ? 0.5 : 0.2), lineWidth: 1))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Phase Progress

struct PhaseProgressRow: View {
    let phases: [DungeonPhase]
    let currentPhase: Int
    let completedPhases: Set<Int>

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<phases.count, id: \.self) { i in
                HStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(completedPhases.contains(i) ? AColor.success : (i == currentPhase ? AColor.royalPurple : AColor.surfaceRaised))
                            .frame(width: 28, height: 28)
                        if completedPhases.contains(i) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(i + 1)")
                                .font(AFont.mono(11))
                                .foregroundStyle(i == currentPhase ? .white : AColor.textMuted)
                        }
                    }
                    if i < phases.count - 1 {
                        Rectangle()
                            .fill(completedPhases.contains(i) ? AColor.success : AColor.surfaceRaised)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Phase Card

struct PhaseCard: View {
    let phase: DungeonPhase
    let phaseIndex: Int
    @Binding var completedExercises: Set<UUID>
    let onPhaseComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(phase.name)
                    .font(AFont.heading(17))
                    .foregroundStyle(AColor.textPrimary)
                Text(phase.description)
                    .font(AFont.body(13))
                    .foregroundStyle(AColor.textSecondary)
                    .italic()
            }

            Divider().background(AColor.surfaceRaised)

            ForEach(phase.exercises) { exercise in
                ExerciseCheckRow(
                    exercise: exercise,
                    isCompleted: completedExercises.contains(exercise.id),
                    onToggle: {
                        withAnimation(.spring(response: 0.3)) {
                            if completedExercises.contains(exercise.id) {
                                completedExercises.remove(exercise.id)
                            } else {
                                completedExercises.insert(exercise.id)
                            }
                        }
                    }
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AColor.card)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AColor.royalPurple.opacity(0.2), lineWidth: 1))
        )
    }
}

// MARK: - Victory Screen

struct DungeonVictoryView: View {
    let dungeon: Dungeon
    let timeSeconds: Int
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            AColor.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.system(size: 72))
                    Text("DUNGEON CLEARED")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(AColor.rankS)
                        .glowText(AColor.rankS, radius: 12)
                    Text(dungeon.name)
                        .font(AFont.heading(18))
                        .foregroundStyle(AColor.textSecondary)
                }

                VStack(spacing: 12) {
                    rewardRow(icon: "star.fill", label: "XP Earned", value: "+\(dungeon.xpReward) XP", color: AColor.xpColor)
                    ForEach(dungeon.bonusStatRewards.sorted(by: { $0.key < $1.key }), id: \.key) { stat, val in
                        rewardRow(icon: "arrow.up.circle.fill", label: stat.capitalized, value: "+\(val)", color: AColor.success)
                    }
                    if let shadow = dungeon.shadowReward {
                        rewardRow(icon: "person.fill", label: "Shadow Extracted", value: shadow, color: AColor.lightPurple)
                    }
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 16).fill(AColor.card))
                .padding(.horizontal)

                Button("CLAIM REWARDS") { onContinue() }
                    .font(AFont.heading(16))
                    .foregroundStyle(AColor.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 16).fill(AColor.rankS).shadow(color: AColor.rankS.opacity(0.5), radius: 12))
                    .padding(.horizontal)

                Spacer()
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }

    func rewardRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)
            Text(label)
                .font(AFont.body())
                .foregroundStyle(AColor.textSecondary)
            Spacer()
            Text(value)
                .font(AFont.mono())
                .foregroundStyle(color)
        }
    }
}
