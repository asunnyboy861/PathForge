import Foundation
import StoreKit

@Observable
final class SubscriptionManager {
    var isProUser = false
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

    private var productIDs: [String] {
        ["com.zzoutuo.PathForge.monthly", "com.zzoutuo.PathForge.yearly"]
    }

    init() {
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
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
            let products = try await Product.products(for: productIDs)
            for product in products {
                switch product.id {
                case "com.zzoutuo.PathForge.monthly":
                    monthlyProduct = product
                case "com.zzoutuo.PathForge.yearly":
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
            await checkSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    private func checkSubscriptionStatus() async {
        for productID in productIDs {
            guard let result = await Transaction.currentEntitlement(for: productID) else { continue }
            switch result {
            case .verified(let transaction):
                if transaction.expirationDate ?? .distantFuture > Date() {
                    isProUser = true
                }
            case .unverified:
                continue
            }
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                isProUser = true
                await transaction.finish()
            case .unverified:
                break
            }
        }
    }
}
