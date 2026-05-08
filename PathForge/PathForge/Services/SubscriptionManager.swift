import Foundation
import StoreKit

@Observable
final class SubscriptionManager {
    var isProUser = false
    var isLifetimeUser = false
    var lifetimeProduct: Product?
    var monthlyProduct: Product?
    var yearlyProduct: Product?
    var isLoading = false
    var freePathsCreated: Int {
        get { UserDefaults.standard.integer(forKey: "free_paths_created") }
        set { UserDefaults.standard.set(newValue, forKey: "free_paths_created") }
    }

    var freeAdjustmentsUsed: Int {
        get { UserDefaults.standard.integer(forKey: "free_adjustments_used") }
        set { UserDefaults.standard.set(newValue, forKey: "free_adjustments_used") }
    }

    let maxFreePaths = 1
    let maxFreeAdjustments = 0

    private var subscriptionProductIDs: [String] {
        ["com.zzoutuo.PathForge.pro.monthly", "com.zzoutuo.PathForge.pro.yearly"]
    }

    private var lifetimeProductID: String {
        "com.zzoutuo.PathForge.pro.lifetime"
    }

    private var allProductIDs: [String] {
        [lifetimeProductID] + subscriptionProductIDs
    }

    init() {
        Task {
            await loadProducts()
            await checkPurchaseStatus()
            await listenForTransactions()
        }
    }

    var canCreatePath: Bool {
        isProUser || freePathsCreated < maxFreePaths
    }

    var canAdjustPath: Bool {
        isProUser || freeAdjustmentsUsed < maxFreeAdjustments
    }

    var remainingFreePaths: Int {
        max(0, maxFreePaths - freePathsCreated)
    }

    func incrementFreePathsCreated() {
        if !isProUser {
            freePathsCreated += 1
        }
    }

    func incrementFreeAdjustmentsUsed() {
        if !isProUser {
            freeAdjustmentsUsed += 1
        }
    }

    func loadProducts() async {
        isLoading = true
        do {
            let products = try await Product.products(for: allProductIDs)
            for product in products {
                switch product.id {
                case lifetimeProductID:
                    lifetimeProduct = product
                case "com.zzoutuo.PathForge.pro.monthly":
                    monthlyProduct = product
                case "com.zzoutuo.PathForge.pro.yearly":
                    yearlyProduct = product
                default: break
                }
            }
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    if product.id == lifetimeProductID {
                        isLifetimeUser = true
                        UserDefaults.standard.set(true, forKey: "has_lifetime_purchase")
                    }
                    isProUser = true
                    await transaction.finish()
                    return true
                case .unverified:
                    return false
                }
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    private func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == lifetimeProductID {
                    isLifetimeUser = true
                    isProUser = true
                    UserDefaults.standard.set(true, forKey: "has_lifetime_purchase")
                } else if subscriptionProductIDs.contains(transaction.productID) {
                    if transaction.expirationDate ?? .distantFuture > Date() {
                        isProUser = true
                    }
                }
            case .unverified:
                break
            }
        }

        if UserDefaults.standard.bool(forKey: "has_lifetime_purchase") {
            isLifetimeUser = true
            isProUser = true
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                if transaction.productID == lifetimeProductID {
                    isLifetimeUser = true
                    isProUser = true
                    UserDefaults.standard.set(true, forKey: "has_lifetime_purchase")
                } else if subscriptionProductIDs.contains(transaction.productID) {
                    if transaction.expirationDate ?? .distantFuture > Date() {
                        isProUser = true
                    }
                }
                await transaction.finish()
            case .unverified:
                break
            }
        }
    }
}
