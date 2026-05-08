import SwiftUI
import StoreKit

struct PaywallView: View {
    let subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: Plan = .lifetime
    @State private var isPurchasing = false

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
            case .monthly: return "Billed monthly"
            case .yearly: return "Billed annually"
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

                    planSelector

                    selectedPlanDetails

                    purchaseButton

                    restoreButton

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
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("Unlock Your Full Potential")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("You bring the API key. We provide the tools.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            FeatureRow(icon: "infinity", title: "Unlimited Learning Paths", description: "Create as many paths as you want")
            FeatureRow(icon: "arrow.triangle.2.circlepath", title: "AI Path Adjustment", description: "Adapt your plan based on feedback")
            FeatureRow(icon: "chart.bar", title: "Detailed Statistics", description: "Charts, trends, and insights")
            FeatureRow(icon: "square.and.arrow.up", title: "Export Reports", description: "Share your progress as PDF")
            FeatureRow(icon: "paintbrush", title: "Custom Widgets", description: "Personalize your home screen")
            FeatureRow(icon: "folder", title: "Saved AI Profiles", description: "Manage multiple API configurations")
        }
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
            Text(plan.priceText)
                .font(.headline)
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
                let product: Product?
                switch selectedPlan {
                case .lifetime:
                    product = subscriptionManager.lifetimeProduct
                case .monthly:
                    product = subscriptionManager.monthlyProduct
                case .yearly:
                    product = subscriptionManager.yearlyProduct
                }
                if let product {
                    let success = await subscriptionManager.purchase(product)
                    if success {
                        dismiss()
                    }
                }
                isPurchasing = false
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
                await subscriptionManager.restorePurchases()
            }
        }
        .font(.subheadline)
        .foregroundStyle(.forgeBlue)
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Terms", destination: URL(string: "https://asunnyboy861.github.io/PathForge/terms.html")!)
            Text("·")
            Link("Privacy", destination: URL(string: "https://asunnyboy861.github.io/PathForge/privacy.html")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
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
