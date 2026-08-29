import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var hunterVM: HunterViewModel
    @State private var selectedTab = 0
    @State private var showLevelUp = false
    @State private var newLevel = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                QuestsView()
                    .tag(1)
                DungeonsView()
                    .tag(2)
                StatsView()
                    .tag(3)
                ProfileView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay {
            if showLevelUp {
                LevelUpOverlay(level: newLevel) {
                    withAnimation { showLevelUp = false }
                }
            }
        }
        .onReceive(hunterVM.$justLeveledUp) { leveledUp in
            if leveledUp {
                newLevel = hunterVM.hunter.level
                withAnimation { showLevelUp = true }
                hunterVM.justLeveledUp = false
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("scroll.fill", "Quests"),
        ("shield.lefthalf.filled", "Gates"),
        ("chart.bar.fill", "Stats"),
        ("person.fill", "Hunter"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 22, weight: selectedTab == index ? .bold : .regular))
                            .foregroundStyle(selectedTab == index ? AColor.electricBlue : AColor.textMuted)
                            .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                        Text(tabs[index].label)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? AColor.electricBlue : AColor.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            ZStack {
                Color.black
                AColor.surface.opacity(0.95)
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(AColor.electricBlue.opacity(0.3)),
                alignment: .top
            )
        )
    }
}
