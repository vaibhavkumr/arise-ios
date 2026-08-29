import Foundation
import StoreKit

@MainActor
class StoreViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false

    // Product IDs — configure in App Store Connect
    static let shadowPassMonthly = "com.arise.fitness.shadow.monthly"
    static let shadowPassYearly  = "com.arise.fitness.shadow.yearly"
    static let monarchPassMonthly = "com.arise.fitness.monarch.monthly"
    static let monarchPassYearly  = "com.arise.fitness.monarch.yearly"

    var isShadow: Bool  { purchasedProductIDs.contains(Self.shadowPassMonthly) || purchasedProductIDs.contains(Self.shadowPassYearly) }
    var isMonarch: Bool { purchasedProductIDs.contains(Self.monarchPassMonthly) || purchasedProductIDs.contains(Self.monarchPassYearly) }

    init() {
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    func loadProducts() async {
        isLoading = true
        let ids: Set<String> = [
            Self.shadowPassMonthly, Self.shadowPassYearly,
            Self.monarchPassMonthly, Self.monarchPassYearly,
        ]
        do {
            products = try await Product.products(for: ids)
        } catch {
            print("StoreKit: Failed to load products: \(error)")
        }
        isLoading = false
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
}
