import SwiftUI

struct PaywallView: View {
    let subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: Plan = .yearly
    @State private var isPurchasing = false

    enum Plan {
        case monthly
        case yearly
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    featuresSection

                    planSelector

                    trialInfo

                    purchaseButton

                    restoreButton
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

            Text("Get unlimited paths, AI adjustments, and detailed statistics")
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
        }
    }

    private var planSelector: some View {
        VStack(spacing: 12) {
            Button {
                selectedPlan = .yearly
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Yearly")
                                .font(.headline)
                            Text("SAVE 50%")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.pathGreen, in: Capsule())
                                .foregroundStyle(.white)
                        }
                        Text("$29.99/year ($2.50/month)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: selectedPlan == .yearly ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(selectedPlan == .yearly ? .forgeBlue : .secondary)
                }
                .padding()
                .background(selectedPlan == .yearly ? Color.forgeBlue.opacity(0.1) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedPlan == .yearly ? Color.forgeBlue : Color.secondary.opacity(0.3), lineWidth: selectedPlan == .yearly ? 2 : 1)
                )
            }
            .buttonStyle(.plain)

            Button {
                selectedPlan = .monthly
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly")
                            .font(.headline)
                        Text("$4.99/month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: selectedPlan == .monthly ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(selectedPlan == .monthly ? .forgeBlue : .secondary)
                }
                .padding()
                .background(selectedPlan == .monthly ? Color.forgeBlue.opacity(0.1) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedPlan == .monthly ? Color.forgeBlue : Color.secondary.opacity(0.3), lineWidth: selectedPlan == .monthly ? 2 : 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var trialInfo: some View {
        Text("7-day free trial. Cancel anytime.")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var purchaseButton: some View {
        Button {
            Task {
                isPurchasing = true
                let product = selectedPlan == .yearly ? subscriptionManager.yearlyProduct : subscriptionManager.monthlyProduct
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
                Text("Start Free Trial")
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
