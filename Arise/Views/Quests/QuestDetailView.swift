import SwiftUI

struct QuestDetailView: View {
    let quest: Quest
    @EnvironmentObject var hunterVM: HunterViewModel
    @EnvironmentObject var questVM: QuestViewModel
    @Environment(\.dismiss) var dismiss

    @State private var completedExercises: Set<UUID> = []
    @State private var showComplete = false
    @State private var timerSeconds = 0
    @State private var timerRunning = false
    @State private var timer: Timer?

    var progress: Double {
        guard !quest.exercises.isEmpty else { return 0 }
        return Double(completedExercises.count) / Double(quest.exercises.count)
    }

    var canComplete: Bool {
        completedExercises.count == quest.exercises.count
    }

    var body: some View {
        ZStack {
            AColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    questHeader

                    // System message
                    systemMessageBox

                    // Timer
                    timerCard

                    // Exercise list
                    exerciseList

                    // Complete button
                    if !quest.isCompleted {
                        completeButton
                    } else {
                        questClearBanner
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(quest.type.rawValue + " Quest")
        .toolbarBackground(AColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onDisappear { stopTimer() }
    }

    var questHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(AFont.title(22))
                        .foregroundStyle(AColor.textPrimary)

                    HStack(spacing: 12) {
                        Label(quest.difficulty.label + "-Rank", systemImage: "shield.fill")
                            .font(AFont.caption())
                            .foregroundStyle(rankColor)

                        Label("+\(quest.xpReward) XP", systemImage: "star.fill")
                            .font(AFont.caption())
                            .foregroundStyle(AColor.xpColor)
                    }
                }
                Spacer()
            }

            // Progress
            VStack(spacing: 4) {
                HStack {
                    Text("\(completedExercises.count)/\(quest.exercises.count) exercises")
                        .font(AFont.mono(12))
                        .foregroundStyle(AColor.textMuted)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(AFont.mono(12))
                        .foregroundStyle(AColor.electricBlue)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AColor.surfaceRaised).frame(height: 8)
                        Capsule()
                            .fill(LinearGradient(colors: [AColor.electricBlue, AColor.royalPurple], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
                .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(AColor.card))
    }

    var systemMessageBox: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(AColor.electricBlue)
                .font(.system(size: 14))
            Text(quest.systemMessage)
                .font(AFont.system(13))
                .foregroundStyle(AColor.electricBlue)
                .italic()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AColor.electricBlue.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AColor.electricBlue.opacity(0.2), lineWidth: 1))
        )
    }

    var timerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quest Timer")
                    .font(AFont.caption())
                    .foregroundStyle(AColor.textMuted)
                Text(formatTime(timerSeconds))
                    .font(AFont.mono(28))
                    .foregroundStyle(AColor.textPrimary)
            }
            Spacer()
            Button {
                timerRunning ? stopTimer() : startTimer()
            } label: {
                Image(systemName: timerRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(timerRunning ? AColor.warning : AColor.success)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(AColor.card))
    }

    var exerciseList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXERCISES")
                .font(AFont.caption(11))
                .foregroundStyle(AColor.textMuted)
                .padding(.leading, 4)

            ForEach(quest.exercises) { exercise in
                ExerciseCheckRow(
                    exercise: exercise,
                    isCompleted: completedExercises.contains(exercise.id),
                    onToggle: {
                        withAnimation(.spring(response: 0.3)) {
                            if completedExercises.contains(exercise.id) {
                                completedExercises.remove(exercise.id)
                            } else {
                                completedExercises.insert(exercise.id)
                                if !timerRunning { startTimer() }
                            }
                        }
                        questVM.updateProgress(questId: quest.id, percent: progress)
                    }
                )
            }
        }
    }

    var completeButton: some View {
        Button {
            guard canComplete else { return }
            completeQuest()
        } label: {
            HStack(spacing: 10) {
                if canComplete {
                    Image(systemName: "checkmark.seal.fill")
                }
                Text(canComplete ? "QUEST COMPLETE" : "Complete All Exercises First")
            }
            .font(AFont.heading(16))
            .foregroundStyle(canComplete ? AColor.background : AColor.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(canComplete ? AColor.success : AColor.surfaceRaised)
                    .shadow(color: canComplete ? AColor.success.opacity(0.4) : .clear, radius: 12)
            )
        }
        .disabled(!canComplete)
        .animation(.easeInOut(duration: 0.3), value: canComplete)
    }

    var questClearBanner: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(AColor.success)
                .glowText(AColor.success, radius: 6)
            Text("QUEST CLEARED")
                .font(AFont.heading())
                .foregroundStyle(AColor.success)
                .glowText(AColor.success, radius: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 16).fill(AColor.success.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AColor.success.opacity(0.3), lineWidth: 1))
    }

    var rankColor: Color {
        switch quest.difficulty {
        case .e: return AColor.rankE
        case .d: return AColor.rankD
        case .c: return AColor.rankC
        case .b: return AColor.rankB
        case .a: return AColor.rankA
        case .s: return AColor.rankS
        case .national: return AColor.rankNational
        }
    }

    func completeQuest() {
        stopTimer()
        questVM.completeQuest(id: quest.id)
        hunterVM.completeQuest(quest)
        withAnimation { showComplete = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }

    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerSeconds += 1
        }
    }

    func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct ExerciseCheckRow: View {
    let exercise: ExerciseStep
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? AColor.success : AColor.textMuted, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Circle()
                            .fill(AColor.success)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AColor.background)
                    }
                }
                .animation(.spring(response: 0.3), value: isCompleted)

                Text(exercise.displayText)
                    .font(AFont.subheading(14))
                    .foregroundStyle(isCompleted ? AColor.textMuted : AColor.textPrimary)
                    .strikethrough(isCompleted)

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? AColor.success.opacity(0.06) : AColor.card)
            )
        }
        .buttonStyle(.plain)
    }
}
