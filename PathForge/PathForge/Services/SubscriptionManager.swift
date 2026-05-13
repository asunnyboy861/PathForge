import Foundation
import StoreKit

enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed(String)
    case pending
    case userCancelled
    case notAllowed
    case networkError
    case unverified
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not available. Please try again later."
        case .purchaseFailed(let message):
            return message
        case .pending:
            return "Purchase is pending approval. You will be notified once it is complete."
        case .userCancelled:
            return "Purchase was cancelled."
        case .notAllowed:
            return "Purchases are not allowed on this device."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .unverified:
            return "Purchase verification failed. Please contact support."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

@Observable
final class SubscriptionManager {
    var isProUser = false
    var isLifetimeUser = false
    var lifetimeProduct: Product?
    var monthlyProduct: Product?
    var yearlyProduct: Product?
    var isLoading = false
    var productsLoaded = false
    var productsLoadFailed = false
    private var loadRetryCount = 0
    private let maxLoadRetries = 3

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
        productsLoadFailed = false
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
            productsLoaded = true
            loadRetryCount = 0
            print("[SubscriptionManager] Products loaded successfully: \(products.count) products")
        } catch {
            print("[SubscriptionManager] Failed to load products: \(error)")
            productsLoadFailed = true
            productsLoaded = false
        }
        isLoading = false
    }

    func retryLoadProducts() async -> Bool {
        guard loadRetryCount < maxLoadRetries else {
            print("[SubscriptionManager] Max retry count reached")
            return false
        }
        loadRetryCount += 1
        print("[SubscriptionManager] Retrying product load (attempt \(loadRetryCount)/\(maxLoadRetries))")
        await loadProducts()
        return productsLoaded
    }

    func purchase(_ product: Product) async -> Result<Bool, PurchaseError> {
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
                    return .success(true)
                case .unverified:
                    return .failure(.unverified)
                }
            case .pending:
                return .failure(.pending)
            case .userCancelled:
                return .failure(.userCancelled)
            @unknown default:
                return .failure(.unknown)
            }
        } catch let error as StoreKitError {
            switch error {
            case .notAvailableInStorefront:
                return .failure(.notAllowed)
            case .networkError:
                return .failure(.networkError)
            case .notEntitled:
                return .failure(.notAllowed)
            default:
                return .failure(.purchaseFailed(error.localizedDescription))
            }
        } catch {
            return .failure(.purchaseFailed(error.localizedDescription))
        }
    }

    func purchaseProduct(for plan: PaywallView.Plan) async -> Result<Bool, PurchaseError> {
        let product: Product?
        switch plan {
        case .lifetime:
            product = lifetimeProduct
        case .monthly:
            product = monthlyProduct
        case .yearly:
            product = yearlyProduct
        }

        guard let product else {
            print("[SubscriptionManager] Product not found for plan: \(plan)")
            if !productsLoaded && loadRetryCount < maxLoadRetries {
                let loaded = await retryLoadProducts()
                if loaded {
                    return await purchaseProduct(for: plan)
                }
            }
            return .failure(.productNotFound)
        }

        return await purchase(product)
    }

    func restorePurchases() async -> Result<Bool, PurchaseError> {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
            return .success(isProUser)
        } catch {
            print("[SubscriptionManager] Failed to restore purchases: \(error)")
            return .failure(.purchaseFailed(error.localizedDescription))
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
