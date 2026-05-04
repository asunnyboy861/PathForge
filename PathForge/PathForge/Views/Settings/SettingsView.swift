import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                apiSection

                subscriptionSection

                notificationsSection

                syncSection

                aboutSection
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Settings")
        }
    }

    private var apiSection: some View {
        Section {
            SecureField("OpenAI API Key", text: $viewModel.apiKey)
                .autocorrectionDisabled()
                .autocapitalization(.none)

            if viewModel.apiKey.isEmpty {
                Text("Required for AI path generation. Get your key at platform.openai.com")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("AI Configuration")
        }
    }

    private var subscriptionSection: some View {
        Section {
            if subscriptionManager.isProUser {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("PathForge Pro")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.pathGreen)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Pro")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
        } header: {
            Text("Subscription")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Study Reminders", isOn: $viewModel.notificationsEnabled)

            if viewModel.notificationsEnabled {
                HStack {
                    Text("Reminder Time")
                    Spacer()
                    Text("\(String(format: "%02d", viewModel.reminderHour)):\(String(format: "%02d", viewModel.reminderMinute))")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Notifications")
        }
    }

    private var syncSection: some View {
        Section {
            Toggle("iCloud Sync", isOn: $viewModel.useCloudKit)

            if viewModel.useCloudKit {
                Text("Your learning paths will sync across all your devices via iCloud")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Sync")
        }
    }

    private var aboutSection: some View {
        Section {
            Link(destination: URL(string: "https://asunnyboy861.github.io/PathForge/support.html")!) {
                HStack {
                    Text("Support")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/PathForge/privacy.html")!) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/PathForge/terms.html")!) {
                HStack {
                    Text("Terms of Use")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }

            NavigationLink {
                ContactSupportView()
            } label: {
                Text("Contact Support")
            }
        } header: {
            Text("About")
        }
    }
}
