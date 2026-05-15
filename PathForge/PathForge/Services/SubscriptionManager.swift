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
            return "Subscription options are not available in this environment. This is expected in sandbox/testing. In production, subscriptions will load normally."
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

    var canAccessDetailedStats: Bool {
        isProUser
    }

    var canExportReports: Bool {
        isProUser
    }

    var canUseCustomWidgets: Bool {
        isProUser
    }

    var canSaveAIProfiles: Bool {
        isProUser
    }

    var canUseCloudSync: Bool {
        isProUser
    }

    func loadProducts() async {
        isLoading = true
        productsLoadFailed = false
        print("[SubscriptionManager] Loading products: \(allProductIDs)")

        do {
            let products = try await Product.products(for: allProductIDs)
            print("[SubscriptionManager] Loaded \(products.count) products from App Store")

            for product in products {
                print("[SubscriptionManager] Found product: \(product.id) - \(product.displayName) - \(product.displayPrice)")
                switch product.id {
                case lifetimeProductID:
                    lifetimeProduct = product
                case "com.zzoutuo.PathForge.pro.monthly":
                    monthlyProduct = product
                case "com.zzoutuo.PathForge.pro.yearly":
                    yearlyProduct = product
                default:
                    print("[SubscriptionManager] Unknown product ID: \(product.id)")
                    break
                }
            }

            if products.isEmpty {
                print("[SubscriptionManager] WARNING: No products returned from App Store")
                print("[SubscriptionManager] This may indicate IAP products are not configured in App Store Connect")
            } else {
                productsLoaded = true
                loadRetryCount = 0
            }
        } catch {
            print("[SubscriptionManager] Failed to load products: \(error.localizedDescription)")
            productsLoadFailed = true
            productsLoaded = false
        }

        isLoading = false
    }

    func retryLoadProducts() async -> Bool {
        guard loadRetryCount < maxLoadRetries else {
            print("[SubscriptionManager] Max retry count reached (\(maxLoadRetries))")
            return false
        }
        loadRetryCount += 1
        print("[SubscriptionManager] Retrying product load (attempt \(loadRetryCount)/\(maxLoadRetries))")
        await loadProducts()
        return productsLoaded
    }

    func purchase(_ product: Product) async -> Result<Bool, PurchaseError> {
        print("[SubscriptionManager] Attempting purchase of: \(product.id)")

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("[SubscriptionManager] Purchase verified successfully: \(transaction.productID)")
                    handleSuccessfulPurchase(transaction)
                    return .success(true)
                case .unverified(let transaction, _):
                    print("[SubscriptionManager] Purchase unverified: \(transaction.productID)")
                    return .failure(.unverified)
                }
            case .pending:
                print("[SubscriptionManager] Purchase pending")
                return .failure(.pending)
            case .userCancelled:
                print("[SubscriptionManager] User cancelled purchase")
                return .failure(.userCancelled)
            @unknown default:
                print("[SubscriptionManager] Unknown purchase result")
                return .failure(.unknown)
            }
        } catch let error as StoreKitError {
            print("[SubscriptionManager] StoreKit error: \(error)")
            switch error {
            case .notAvailableInStorefront:
                return .failure(.notAllowed)
            case .networkError:
                return .failure(.networkError)
            case .notEntitled:
                return .failure(.notAllowed)
            case .userCancelled:
                return .failure(.userCancelled)
            default:
                return .failure(.purchaseFailed(error.localizedDescription))
            }
        } catch {
            print("[SubscriptionManager] Unknown error: \(error)")
            return .failure(.purchaseFailed(error.localizedDescription))
        }
    }

    func purchaseProduct(for plan: PaywallView.Plan) async -> Result<Bool, PurchaseError> {
        let productID: String
        let product: Product?

        switch plan {
        case .lifetime:
            productID = lifetimeProductID
            product = lifetimeProduct
        case .monthly:
            productID = subscriptionProductIDs[0]
            product = monthlyProduct
        case .yearly:
            productID = subscriptionProductIDs[1]
            product = yearlyProduct
        }

        if let product {
            return await purchase(product)
        }

        print("[SubscriptionManager] Product not cached for plan \(plan), attempting direct lookup: \(productID)")

        do {
            let products = try await Product.products(for: [productID])
            if let directProduct = products.first {
                print("[SubscriptionManager] Found product via direct lookup: \(directProduct.id)")

                switch plan {
                case .lifetime:
                    lifetimeProduct = directProduct
                case .monthly:
                    monthlyProduct = directProduct
                case .yearly:
                    yearlyProduct = directProduct
                }

                return await purchase(directProduct)
            }
        } catch {
            print("[SubscriptionManager] Direct lookup failed: \(error)")
        }

        if !productsLoaded && loadRetryCount < maxLoadRetries {
            print("[SubscriptionManager] Retrying full product load...")
            let loaded = await retryLoadProducts()
            if loaded {
                return await purchaseProduct(for: plan)
            }
        }

        print("[SubscriptionManager] All attempts failed for product: \(productID)")
        return .failure(.productNotFound)
    }

    func restorePurchases() async -> Result<Bool, PurchaseError> {
        print("[SubscriptionManager] Restoring purchases...")

        do {
            try await AppStore.sync()
            print("[SubscriptionManager] AppStore.sync completed")
            await checkPurchaseStatus()
            return .success(isProUser)
        } catch {
            print("[SubscriptionManager] Restore purchases failed: \(error)")
            return .failure(.purchaseFailed(error.localizedDescription))
        }
    }

    private func handleSuccessfulPurchase(_ transaction: Transaction) {
        if transaction.productID == lifetimeProductID {
            isLifetimeUser = true
            UserDefaults.standard.set(true, forKey: "has_lifetime_purchase")
        }
        isProUser = true

        Task {
            await transaction.finish()
        }
    }

    private func checkPurchaseStatus() async {
        print("[SubscriptionManager] Checking purchase status...")

        var foundActiveEntitlement = false

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                print("[SubscriptionManager] Found entitlement: \(transaction.productID), expires: \(transaction.expirationDate ?? .distantFuture)")

                if transaction.productID == lifetimeProductID {
                    isLifetimeUser = true
                    isProUser = true
                    UserDefaults.standard.set(true, forKey: "has_lifetime_purchase")
                    foundActiveEntitlement = true
                } else if subscriptionProductIDs.contains(transaction.productID) {
                    let expirationDate = transaction.expirationDate ?? .distantFuture
                    if expirationDate > Date() {
                        isProUser = true
                        foundActiveEntitlement = true
                        print("[SubscriptionManager] Active subscription found, expires: \(expirationDate)")
                    } else {
                        print("[SubscriptionManager] Expired subscription: \(transaction.productID)")
                    }
                }
            case .unverified(let transaction, _):
                print("[SubscriptionManager] Unverified entitlement: \(transaction.productID)")
            }
        }

        if UserDefaults.standard.bool(forKey: "has_lifetime_purchase") {
            isLifetimeUser = true
            isProUser = true
        }

        print("[SubscriptionManager] Check complete - isProUser: \(isProUser), isLifetimeUser: \(isLifetimeUser)")
    }

    private func listenForTransactions() async {
        print("[SubscriptionManager] Starting transaction listener...")

        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                print("[SubscriptionManager] Transaction update received: \(transaction.productID)")
                handleSuccessfulPurchase(transaction)
            case .unverified(let transaction, _):
                print("[SubscriptionManager] Unverified transaction update: \(transaction.productID)")
            }
        }
    }
}
