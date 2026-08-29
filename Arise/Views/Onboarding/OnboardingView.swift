import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var hunterVM: HunterViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var page = 0
    @State private var hunterName = ""
    @State private var selectedTrade: TradeType = .warrior
    @State private var animateTitle = false

    enum TradeType: String, CaseIterable {
        case warrior  = "Warrior"     // Strength focus
        case assassin = "Assassin"    // Agility/speed focus
        case tank     = "Tank"        // Endurance focus
        case mage     = "Mage"        // Balanced/flexibility
        case healer   = "Healer"      // Vitality/recovery focus

        var description: String {
            switch self {
            case .warrior:  return "Strength training, powerlifting"
            case .assassin: return "Cardio, speed, agility drills"
            case .tank:     return "Endurance, HIIT, long runs"
            case .mage:     return "Balanced training, yoga, mobility"
            case .healer:   return "Recovery, flexibility, consistency"
            }
        }

        var icon: String {
            switch self {
            case .warrior:  return "dumbbell.fill"
            case .assassin: return "figure.run"
            case .tank:     return "shield.fill"
            case .mage:     return "sparkles"
            case .healer:   return "heart.fill"
            }
        }

        var primaryStat: String {
            switch self {
            case .warrior:  return "Strength"
            case .assassin: return "Agility"
            case .tank:     return "Endurance"
            case .mage:     return "Intelligence"
            case .healer:   return "Vitality"
            }
        }
    }

    var body: some View {
        ZStack {
            AColor.background.ignoresSafeArea()

            // Background particles
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(AColor.electricBlue.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat(i * 27 % Int(UIScreen.main.bounds.width)),
                        y: CGFloat(i * 57 % Int(UIScreen.main.bounds.height))
                    )
            }

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<4) { i in
                        Capsule()
                            .fill(i <= page ? AColor.electricBlue : AColor.surfaceRaised)
                            .frame(width: i == page ? 24 : 8, height: 6)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                Group {
                    switch page {
                    case 0: IntroPage(animate: $animateTitle)
                    case 1: NamePage(name: $hunterName)
                    case 2: TradeSelectionPage(selected: $selectedTrade)
                    case 3: ReadyPage(name: hunterName, trade: selectedTrade)
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 28)

                // Navigation
                HStack(spacing: 16) {
                    if page > 0 {
                        Button {
                            withAnimation(.spring(response: 0.4)) { page -= 1 }
                        } label: {
                            Text("Back")
                                .font(AFont.subheading())
                                .foregroundStyle(AColor.textMuted)
                                .frame(width: 80)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 14).fill(AColor.surfaceRaised))
                        }
                    }

                    Button {
                        if page < 3 {
                            withAnimation(.spring(response: 0.4)) { page += 1 }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(page == 3 ? "ARISE" : "Continue")
                            .font(AFont.heading(page == 3 ? 20 : 16))
                            .foregroundStyle(AColor.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, page == 3 ? 20 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(page == 3 ?
                                        LinearGradient(colors: [AColor.electricBlue, AColor.royalPurple], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [AColor.electricBlue], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .shadow(color: AColor.electricBlue.opacity(0.5), radius: page == 3 ? 16 : 8)
                            )
                    }
                    .disabled(page == 1 && hunterName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                animateTitle = true
            }
        }
    }

    func completeOnboarding() {
        let name = hunterName.trimmingCharacters(in: .whitespaces).isEmpty ? "Hunter" : hunterName
        hunterVM.setName(name)

        // Apply trade bonuses
        switch selectedTrade {
        case .warrior:  hunterVM.hunter.stats.strength += 5
        case .assassin: hunterVM.hunter.stats.agility += 5
        case .tank:     hunterVM.hunter.stats.endurance += 5
        case .mage:     hunterVM.hunter.stats.intelligence += 5; hunterVM.hunter.stats.agility += 2
        case .healer:   hunterVM.hunter.stats.vitality += 5; hunterVM.hunter.stats.endurance += 2
        }

        hunterVM.save()
        hasCompletedOnboarding = true
    }
}

// MARK: - Onboarding Pages

struct IntroPage: View {
    @Binding var animate: Bool

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AColor.electricBlue.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                Circle()
                    .fill(AColor.royalPurple.opacity(0.12))
                    .frame(width: 120, height: 120)
                Text("⚡")
                    .font(.system(size: 60))
            }

            VStack(spacing: 12) {
                Text("ARISE")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(AColor.electricBlue)
                    .glowText(AColor.electricBlue, radius: 12)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)
                    .animation(.spring(response: 0.6).delay(0.2), value: animate)

                Text("Fitness RPG")
                    .font(AFont.heading(20))
                    .foregroundStyle(AColor.textSecondary)

                Text("You have been detected by the System.\nYour journey as a Hunter begins now.")
                    .font(AFont.system(15))
                    .foregroundStyle(AColor.electricBlue)
                    .multilineTextAlignment(.center)
                    .italic()
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.5), value: animate)
            }

            Spacer()
        }
    }
}

struct NamePage: View {
    @Binding var name: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("What is your name, Hunter?")
                .font(AFont.title(26))
                .foregroundStyle(AColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("This is how the System will address you.")
                .font(AFont.body())
                .foregroundStyle(AColor.textSecondary)
                .multilineTextAlignment(.center)

            TextField("", text: $name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AColor.textPrimary)
                .tint(AColor.electricBlue)
                .multilineTextAlignment(.center)
                .focused($focused)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AColor.surfaceRaised)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(focused ? AColor.electricBlue : AColor.card, lineWidth: 1.5))
                )
                .placeholder(when: name.isEmpty) {
                    Text("Enter name...")
                        .foregroundStyle(AColor.textMuted)
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }

            Spacer()
        }
        .onAppear { focused = true }
    }
}

struct TradeSelectionPage: View {
    @Binding var selected: OnboardingView.TradeType

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Choose Your Class")
                    .font(AFont.title(26))
                    .foregroundStyle(AColor.textPrimary)
                Text("Your primary training focus. You can change this later.")
                    .font(AFont.body(13))
                    .foregroundStyle(AColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            VStack(spacing: 10) {
                ForEach(OnboardingView.TradeType.allCases, id: \.self) { trade in
                    TradeOptionRow(trade: trade, isSelected: selected == trade) {
                        withAnimation(.spring(response: 0.3)) { selected = trade }
                    }
                }
            }
        }
    }
}

struct TradeOptionRow: View {
    let trade: OnboardingView.TradeType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AColor.electricBlue.opacity(0.2) : AColor.surfaceRaised)
                        .frame(width: 44, height: 44)
                    Image(systemName: trade.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(isSelected ? AColor.electricBlue : AColor.textMuted)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(trade.rawValue)
                        .font(AFont.subheading(14))
                        .foregroundStyle(isSelected ? AColor.textPrimary : AColor.textSecondary)
                    Text(trade.description)
                        .font(AFont.body(12))
                        .foregroundStyle(AColor.textMuted)
                }

                Spacer()

                Text("+5 \(trade.primaryStat)")
                    .font(AFont.mono(11))
                    .foregroundStyle(isSelected ? AColor.electricBlue : AColor.textMuted)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AColor.electricBlue.opacity(0.08) : AColor.card)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? AColor.electricBlue.opacity(0.4) : Color.clear, lineWidth: 1.5))
            )
        }
        .buttonStyle(.plain)
    }
}

struct ReadyPage: View {
    let name: String
    let trade: OnboardingView.TradeType
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AColor.electricBlue.opacity(0.05))
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulse ? 1.3 : 1.0)
                    .opacity(pulse ? 0 : 0.8)
                    .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulse)
                Circle()
                    .fill(AColor.royalPurple.opacity(0.15))
                    .frame(width: 130, height: 130)
                Text("⚡")
                    .font(.system(size: 64))
            }
            .onAppear { pulse = true }

            VStack(spacing: 12) {
                Text("Welcome, \(name.isEmpty ? "Hunter" : name)")
                    .font(AFont.title(28))
                    .foregroundStyle(AColor.textPrimary)

                Text("Class: \(trade.rawValue)")
                    .font(AFont.subheading())
                    .foregroundStyle(AColor.electricBlue)

                Text("\"The System will guide you.\nTrain. Grow. Rise.\"\n\nYou are E-Rank. For now.")
                    .font(AFont.system(15))
                    .foregroundStyle(AColor.electricBlue)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.top, 4)
            }

            Spacer()
        }
    }
}

// MARK: - Placeholder modifier

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .center) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
