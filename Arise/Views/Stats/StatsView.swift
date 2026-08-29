import SwiftUI

struct StatsView: View {
    @EnvironmentObject var hunterVM: HunterViewModel

    var hunter: Hunter { hunterVM.hunter }
    var stats: HunterStats { hunter.stats }

    var body: some View {
        NavigationStack {
            ZStack {
                AColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Stat overview
                        StatOverviewCard(stats: stats)
                            .padding(.horizontal)

                        // Individual stats
                        VStack(spacing: 12) {
                            StatDetailRow(label: "Strength", abbr: "STR", value: stats.strength, maxValue: 999, color: AColor.strColor, icon: "dumbbell.fill", description: "From strength training, push, pull")
                            StatDetailRow(label: "Agility", abbr: "AGI", value: stats.agility, maxValue: 999, color: AColor.agiColor, icon: "figure.run", description: "From cardio and speed workouts")
                            StatDetailRow(label: "Vitality", abbr: "VIT", value: stats.vitality, maxValue: 999, color: AColor.vitColor, icon: "heart.fill", description: "From consistency and daily training")
                            StatDetailRow(label: "Endurance", abbr: "END", value: stats.endurance, maxValue: 999, color: AColor.endColor, icon: "bolt.fill", description: "From HIIT and long-duration workouts")
                            StatDetailRow(label: "Intelligence", abbr: "INT", value: stats.intelligence, maxValue: 999, color: AColor.intColor, icon: "brain.head.profile", description: "From flexibility, mobility, and mindfulness")
                        }
                        .padding(.horizontal)

                        // Achievements
                        AchievementsSection()
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Stat Overview Card (Pentagon/Radar)

struct StatOverviewCard: View {
    let stats: HunterStats

    var total: Int { stats.total }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Power")
                        .font(AFont.caption())
                        .foregroundStyle(AColor.textMuted)
                    Text("\(total)")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(AColor.textPrimary)
                        .glowText(AColor.electricBlue, radius: 6)
                }
                Spacer()
                StatRadar(stats: stats)
                    .frame(width: 130, height: 130)
            }

            // Mini stat bars
            HStack(spacing: 0) {
                ForEach([
                    ("STR", stats.strength, AColor.strColor),
                    ("AGI", stats.agility, AColor.agiColor),
                    ("VIT", stats.vitality, AColor.vitColor),
                    ("END", stats.endurance, AColor.endColor),
                    ("INT", stats.intelligence, AColor.intColor),
                ], id: \.0) { (abbr, val, color) in
                    VStack(spacing: 4) {
                        Text("\(val)")
                            .font(AFont.mono(13))
                            .foregroundStyle(color)
                        Text(abbr)
                            .font(AFont.caption(10))
                            .foregroundStyle(AColor.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AColor.card)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AColor.electricBlue.opacity(0.2), lineWidth: 1))
        )
    }
}

// MARK: - Radar Chart

struct StatRadar: View {
    let stats: HunterStats
    private let maxStat: CGFloat = 100

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let r = min(cx, cy) * 0.85
            let n = 5
            let values: [CGFloat] = [
                min(CGFloat(stats.strength), 100),
                min(CGFloat(stats.agility), 100),
                min(CGFloat(stats.vitality), 100),
                min(CGFloat(stats.endurance), 100),
                min(CGFloat(stats.intelligence), 100),
            ]
            let colors: [Color] = [AColor.strColor, AColor.agiColor, AColor.vitColor, AColor.endColor, AColor.intColor]

            // Background rings
            for ring in 1...4 {
                var path = Path()
                let rf = r * CGFloat(ring) / 4
                for i in 0..<n {
                    let angle = CGFloat(i) / CGFloat(n) * 2 * .pi - .pi / 2
                    let x = cx + rf * cos(angle)
                    let y = cy + rf * sin(angle)
                    i == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                }
                path.closeSubpath()
                ctx.stroke(path, with: .color(AColor.surfaceRaised), lineWidth: 1)
            }

            // Stat polygon
            var statPath = Path()
            for i in 0..<n {
                let angle = CGFloat(i) / CGFloat(n) * 2 * .pi - .pi / 2
                let factor = values[i] / maxStat
                let x = cx + r * factor * cos(angle)
                let y = cy + r * factor * sin(angle)
                i == 0 ? statPath.move(to: CGPoint(x: x, y: y)) : statPath.addLine(to: CGPoint(x: x, y: y))
            }
            statPath.closeSubpath()
            ctx.fill(statPath, with: .color(AColor.electricBlue.opacity(0.2)))
            ctx.stroke(statPath, with: .color(AColor.electricBlue), lineWidth: 1.5)

            // Dots
            for i in 0..<n {
                let angle = CGFloat(i) / CGFloat(n) * 2 * .pi - .pi / 2
                let factor = values[i] / maxStat
                let x = cx + r * factor * cos(angle)
                let y = cy + r * factor * sin(angle)
                ctx.fill(Path(ellipseIn: CGRect(x: x-4, y: y-4, width: 8, height: 8)), with: .color(colors[i]))
            }
        }
    }
}

// MARK: - Stat Detail Row

struct StatDetailRow: View {
    let label: String
    let abbr: String
    let value: Int
    let maxValue: Int
    let color: Color
    let icon: String
    let description: String

    var progress: Double { min(Double(value) / Double(maxValue), 1.0) }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(label)
                            .font(AFont.subheading(14))
                            .foregroundStyle(AColor.textPrimary)
                        Text("(\(abbr))")
                            .font(AFont.mono(11))
                            .foregroundStyle(color)
                        Spacer()
                        Text("\(value)")
                            .font(AFont.mono(18))
                            .foregroundStyle(color)
                    }

                    Text(description)
                        .font(AFont.body(11))
                        .foregroundStyle(AColor.textMuted)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AColor.surfaceRaised).frame(height: 6)
                            Capsule()
                                .fill(color)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .animation(.easeInOut(duration: 0.8), value: progress)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AColor.card))
    }
}

// MARK: - Achievements

struct AchievementsSection: View {
    @EnvironmentObject var hunterVM: HunterViewModel

    var unlocked: [Achievement] { hunterVM.achievements.filter { $0.isUnlocked } }
    var locked: [Achievement] { hunterVM.achievements.filter { !$0.isUnlocked } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Achievements (\(unlocked.count)/\(hunterVM.achievements.count))", icon: "trophy.fill", color: AColor.rankS)

            if unlocked.isEmpty {
                Text("No achievements yet. Complete quests and dungeons.")
                    .font(AFont.body(13))
                    .foregroundStyle(AColor.textMuted)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(AColor.card))
            } else {
                ForEach(unlocked) { a in
                    AchievementRow(achievement: a)
                }
            }

            if !locked.isEmpty {
                Text("LOCKED (\(locked.count))")
                    .font(AFont.caption(11))
                    .foregroundStyle(AColor.textMuted)
                    .padding(.top, 4)

                ForEach(locked.prefix(3)) { a in
                    AchievementRow(achievement: a)
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AColor.rankS.opacity(0.2) : AColor.surfaceRaised)
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(achievement.isUnlocked ? AColor.rankS : AColor.textMuted)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.isUnlocked ? achievement.title : "???")
                    .font(AFont.subheading(13))
                    .foregroundStyle(achievement.isUnlocked ? AColor.textPrimary : AColor.textMuted)
                Text(achievement.isUnlocked ? achievement.description : "Complete conditions to unlock")
                    .font(AFont.body(11))
                    .foregroundStyle(AColor.textMuted)
            }

            Spacer()

            if achievement.isUnlocked {
                Text("+\(achievement.xpReward) XP")
                    .font(AFont.mono(11))
                    .foregroundStyle(AColor.xpColor)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(AColor.textMuted)
                    .font(.system(size: 12))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.isUnlocked ? AColor.rankS.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        )
    }
}
