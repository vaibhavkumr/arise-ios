import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeVM: StoreViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionTier = .shadow
    @State private var purchasing = false
    @State private var error: String?

    var body: some View {
        ZStack {
            AColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Text("👑")
                            .font(.system(size: 56))
                        Text("Unlock Your Full Power")
                            .font(AFont.title(28))
                            .foregroundStyle(AColor.textPrimary)
                            .multilineTextAlignment(.center)
                        Text("The System has detected your potential.\nUpgrade to unleash it.")
                            .font(AFont.system(15))
                            .foregroundStyle(AColor.electricBlue)
                            .multilineTextAlignment(.center)
                            .italic()
                    }
                    .padding(.top, 40)

                    // Plans
                    VStack(spacing: 12) {
                        PlanCard(
                            tier: .shadow,
                            title: "Shadow Pass",
                            price: "$4.99/month",
                            yearlyPrice: "$39.99/year",
                            emoji: "🌑",
                            features: [
                                "Advanced dungeon raids",
                                "Party mode — train with friends",
                                "Global leaderboards",
                                "Custom quest builder",
                                "Workout history & analytics",
                            ],
                            color: AColor.lightPurple,
                            isSelected: selectedPlan == .shadow
                        ) { selectedPlan = .shadow }

                        PlanCard(
                            tier: .monarch,
                            title: "Monarch Pass",
                            price: "$9.99/month",
                            yearlyPrice: "$79.99/year",
                            emoji: "👑",
                            features: [
                                "Everything in Shadow Pass",
                                "AI workout programming",
                                "Exclusive Monarch dungeons",
                                "Shadow Army evolution",
                                "Priority support",
                                "Exclusive Monarch cosmetics",
                            ],
                            color: AColor.rankS,
                            isSelected: selectedPlan == .monarch,
                            badge: "BEST VALUE"
                        ) { selectedPlan = .monarch }
                    }
                    .padding(.horizontal)

                    // CTA
                    VStack(spacing: 12) {
                        Button {
                            Task { await purchase() }
                        } label: {
                            HStack {
                                if purchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Start Free Trial")
                                        .font(AFont.heading(17))
                                        .foregroundStyle(AColor.background)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [AColor.electricBlue, AColor.royalPurple], startPoint: .leading, endPoint: .trailing))
                                    .shadow(color: AColor.electricBlue.opacity(0.4), radius: 12)
                            )
                        }
                        .disabled(purchasing)

                        Text("7-day free trial · Cancel anytime · No commitment")
                            .font(AFont.caption(11))
                            .foregroundStyle(AColor.textMuted)
                            .multilineTextAlignment(.center)

                        Button("Restore Purchases") {
                            Task { await storeVM.restore() }
                        }
                        .font(AFont.caption(12))
                        .foregroundStyle(AColor.electricBlue)
                    }
                    .padding(.horizontal)

                    if let error {
                        Text(error)
                            .font(AFont.body(12))
                            .foregroundStyle(AColor.danger)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Legal
                    Text("Payment charged to Apple ID. Subscription auto-renews unless cancelled at least 24h before the end of the current period.")
                        .font(AFont.caption(10))
                        .foregroundStyle(AColor.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AColor.textMuted)
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
    }

    func purchase() async {
        purchasing = true
        error = nil

        let productId = selectedPlan == .shadow
            ? StoreViewModel.shadowPassMonthly
            : StoreViewModel.monarchPassMonthly

        guard let product = storeVM.products.first(where: { $0.id == productId }) else {
            error = "Product not available. Please try again."
            purchasing = false
            return
        }

        do {
            try await storeVM.purchase(product)
            dismiss()
        } catch {
            self.error = "Purchase failed: \(error.localizedDescription)"
        }

        purchasing = false
    }
}

struct PlanCard: View {
    let tier: SubscriptionTier
    let title: String
    let price: String
    let yearlyPrice: String
    let emoji: String
    let features: [String]
    let color: Color
    let isSelected: Bool
    var badge: String? = nil
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Text(emoji).font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(AFont.heading(16))
                                .foregroundStyle(AColor.textPrimary)
                            HStack(spacing: 6) {
                                Text(price)
                                    .font(AFont.subheading(13))
                                    .foregroundStyle(color)
                                Text("or \(yearlyPrice)")
                                    .font(AFont.caption(11))
                                    .foregroundStyle(AColor.textMuted)
                            }
                        }
                    }
                    Spacer()
                    if let badge {
                        Text(badge)
                            .font(AFont.caption(10))
                            .foregroundStyle(AColor.background)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color)
                            .clipShape(Capsule())
                    }
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? color : AColor.textMuted)
                }

                ForEach(features, id: \.self) { f in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(color)
                        Text(f)
                            .font(AFont.body(13))
                            .foregroundStyle(AColor.textSecondary)
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.08) : AColor.card)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? color.opacity(0.5) : AColor.surfaceRaised, lineWidth: 1.5))
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
