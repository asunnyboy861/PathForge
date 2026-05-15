import SwiftUI
import StoreKit
import SafariServices

struct PaywallView: View {
    let subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: Plan = .lifetime
    @State private var isPurchasing = false
    @State private var isRetryingProducts = false
    @State private var showPurchaseAlert = false
    @State private var purchaseAlertTitle = ""
    @State private var purchaseAlertMessage = ""
    @State private var showSubscriptionStore = false

    private let privacyPolicyURL = URL(string: "https://asunnyboy861.github.io/PathForge/privacy.html")!
    private let termsOfUseURL = URL(string: "https://asunnyboy861.github.io/PathForge/terms.html")!

    enum Plan: CaseIterable, Identifiable {
        case lifetime
        case monthly
        case yearly

        var id: Self { self }

        var title: String {
            switch self {
            case .lifetime: return "Lifetime"
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }

        var subtitle: String {
            switch self {
            case .lifetime: return "One-time purchase"
            case .monthly: return "1 month, auto-renewable"
            case .yearly: return "1 year, auto-renewable"
            }
        }

        var priceText: String {
            switch self {
            case .lifetime: return "$29.99"
            case .monthly: return "$2.99/mo"
            case .yearly: return "$14.99/yr"
            }
        }

        var badge: String? {
            switch self {
            case .lifetime: return "BEST VALUE"
            case .monthly: return nil
            case .yearly: return "SAVE 58%"
            }
        }

        var features: [String] {
            switch self {
            case .lifetime:
                return ["All Pro features forever", "No subscriptions, no renewals", "Use on all your devices", "Pay once, save forever"]
            case .monthly:
                return ["All Pro features", "Cancel anytime", "No long-term commitment"]
            case .yearly:
                return ["All Pro features", "Save 58% vs monthly", "Only $1.25/month"]
            }
        }

        var buttonTitle: String {
            switch self {
            case .lifetime: return "Get Lifetime Access"
            case .monthly: return "Subscribe Monthly"
            case .yearly: return "Subscribe Yearly"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    featuresSection

                    if subscriptionManager.isLoading || isRetryingProducts {
                        productLoadingSection
                    } else if subscriptionManager.productsLoadFailed {
                        productLoadFailedSection
                    } else {
                        planSelector
                        selectedPlanDetails
                        purchaseButton
                    }

                    restoreButton

                    subscriptionStoreButton

                    subscriptionInfoText

                    legalLinks
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("PathForge Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert(purchaseAlertTitle, isPresented: $showPurchaseAlert) {
                Button("OK") {}
            } message: {
                Text(purchaseAlertMessage)
            }
            .task {
                if !subscriptionManager.productsLoaded && !subscriptionManager.isLoading {
                    await subscriptionManager.loadProducts()
                }
            }
            .sheet(isPresented: $showSubscriptionStore) {
                SubscriptionStoreView(groupID: "com.zzoutuo.PathForge.premium")
                    .storeButton(.visible, for: .restorePurchases, .policies, .redeemCode)
                    .subscriptionStorePolicyDestination(url: privacyPolicyURL, for: .privacyPolicy)
                    .subscriptionStorePolicyDestination(url: termsOfUseURL, for: .termsOfService)
                    .onInAppPurchaseCompletion { product, result in
                        if case .success(let purchaseResult) = result {
                            if case .success(let verification) = purchaseResult {
                                if case .verified(let transaction) = verification {
                                    subscriptionManager.isProUser = true
                                    if transaction.productID == "com.zzoutuo.PathForge.pro.lifetime" {
                                        subscriptionManager.isLifetimeUser = true
                                        UserDefaults.standard.set(true, forKey: "has_lifetime_purchase")
                                    }
                                    purchaseAlertTitle = "Success!"
                                    purchaseAlertMessage = "Your purchase was successful. Thank you for supporting PathForge!"
                                    showPurchaseAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("Unlock Pro Features")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("AI path generation is always free with your API key. Pro unlocks powerful extras.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            FeatureRow(icon: "chart.bar", title: "Detailed Statistics", description: "Charts, trends, and learning insights")
            FeatureRow(icon: "square.and.arrow.up", title: "Export Reports", description: "Share your progress as PDF")
            FeatureRow(icon: "paintbrush", title: "Custom Widgets", description: "Personalize your home screen")
            FeatureRow(icon: "folder", title: "Saved AI Profiles", description: "Manage multiple API configurations")
            FeatureRow(icon: "icloud", title: "iCloud Sync", description: "Sync across all your devices")
            FeatureRow(icon: "headset", title: "Priority Support", description: "Get help faster when you need it")
        }
    }

    private var productLoadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading subscription options...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }

    private var productLoadFailedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(.orange)

            Text("Unable to load subscription options")
                .font(.headline)

            Text("This is expected in sandbox/test environments. In production, subscriptions will load normally. You can still explore all free features of PathForge.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    isRetryingProducts = true
                    await subscriptionManager.retryLoadProducts()
                    isRetryingProducts = false
                }
            } label: {
                HStack {
                    if isRetryingProducts {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Try Again")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.forgeBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isRetryingProducts)
        }
        .padding(24)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var planSelector: some View {
        VStack(spacing: 12) {
            ForEach(Plan.allCases) { plan in
                Button {
                    selectedPlan = plan
                } label: {
                    planRow(plan)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func planRow(_ plan: Plan) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(plan.title)
                        .font(.headline)
                    if let badge = plan.badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(plan == .lifetime ? .pathGreen : .forgeBlue, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                Text(plan.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let product = productForPlan(plan) {
                Text(product.displayPrice)
                    .font(.headline)
            } else {
                Text(plan.priceText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: selectedPlan == plan ? "largecircle.fill.circle" : "circle")
                .foregroundStyle(selectedPlan == plan ? .forgeBlue : .secondary)
        }
        .padding()
        .background(selectedPlan == plan ? Color.forgeBlue.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedPlan == plan ? Color.forgeBlue : Color.secondary.opacity(0.3), lineWidth: selectedPlan == plan ? 2 : 1)
        )
    }

    private func productForPlan(_ plan: Plan) -> Product? {
        switch plan {
        case .lifetime:
            return subscriptionManager.lifetimeProduct
        case .monthly:
            return subscriptionManager.monthlyProduct
        case .yearly:
            return subscriptionManager.yearlyProduct
        }
    }

    private var selectedPlanDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's included:")
                .font(.subheadline)
                .fontWeight(.medium)

            ForEach(selectedPlan.features, id: \.self) { feature in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.pathGreen)
                    Text(feature)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var purchaseButton: some View {
        Button {
            Task {
                isPurchasing = true
                let result = await subscriptionManager.purchaseProduct(for: selectedPlan)
                isPurchasing = false

                switch result {
                case .success:
                    purchaseAlertTitle = "Success!"
                    purchaseAlertMessage = "Your purchase was successful. Thank you for supporting PathForge!"
                    showPurchaseAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                case .failure(let error):
                    if case .userCancelled = error {
                    } else {
                        purchaseAlertTitle = "Purchase Failed"
                        purchaseAlertMessage = error.errorDescription ?? "An error occurred during purchase."
                        showPurchaseAlert = true
                    }
                }
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                }
                Text(selectedPlan.buttonTitle)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.forgeBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isPurchasing)
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                let result = await subscriptionManager.restorePurchases()
                switch result {
                case .success(let hasActiveSubscription):
                    if hasActiveSubscription {
                        purchaseAlertTitle = "Restored"
                        purchaseAlertMessage = "Your purchases have been successfully restored."
                    } else {
                        purchaseAlertTitle = "No Purchases Found"
                        purchaseAlertMessage = "No previous purchases were found. If you believe this is an error, please contact support."
                    }
                    showPurchaseAlert = true
                case .failure(let error):
                    purchaseAlertTitle = "Restore Failed"
                    purchaseAlertMessage = error.errorDescription ?? "Failed to restore purchases. Please try again."
                    showPurchaseAlert = true
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.forgeBlue)
    }

    private var subscriptionStoreButton: some View {
        Button {
            showSubscriptionStore = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "app.badge.checkmark")
                Text("View Apple Subscription Options")
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.forgeBlue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var legalLinks: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Link("Terms of Use (EULA)", destination: termsOfUseURL)
                Text("\u{00B7}")
                Link("Privacy Policy", destination: privacyPolicyURL)
            }
            .font(.caption)
            .foregroundStyle(.forgeBlue)
        }
    }

    private var subscriptionInfoText: some View {
        VStack(spacing: 6) {
            Text("Subscription Details")
                .font(.caption)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 4) {
                if let monthly = subscriptionManager.monthlyProduct {
                    HStack(spacing: 4) {
                        Text("\u{2022}")
                        Text("\(monthly.displayName): \(monthly.displayPrice) / 1 month (auto-renewable)")
                    }
                    .font(.caption2)
                } else {
                    HStack(spacing: 4) {
                        Text("\u{2022}")
                        Text("Monthly Premium: $2.99 / 1 month (auto-renewable)")
                    }
                    .font(.caption2)
                }

                if let yearly = subscriptionManager.yearlyProduct {
                    HStack(spacing: 4) {
                        Text("\u{2022}")
                        Text("\(yearly.displayName): \(yearly.displayPrice) / 1 year (auto-renewable)")
                    }
                    .font(.caption2)
                } else {
                    HStack(spacing: 4) {
                        Text("\u{2022}")
                        Text("Yearly Premium: $14.99 / 1 year (auto-renewable)")
                    }
                    .font(.caption2)
                }

                HStack(spacing: 4) {
                    Text("\u{2022}")
                    Text("Lifetime Access: $29.99 one-time purchase (non-subscription)")
                }
                .font(.caption2)
            }

            VStack(spacing: 3) {
                Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                    Text("Manage or cancel your subscriptions in App Store Settings \u{2192}")
                        .font(.caption2)
                        .foregroundStyle(.forgeBlue)
                        .multilineTextAlignment(.center)
                        .underline()
                }
            }
            .padding(.top, 2)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.forgeBlue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}
