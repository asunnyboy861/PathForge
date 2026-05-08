import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var showPaywall = false

    private var reminderDate: Binding<Date> {
        Binding(
            get: {
                let calendar = Calendar.current
                var components = DateComponents()
                components.hour = viewModel.reminderHour
                components.minute = viewModel.reminderMinute
                return calendar.date(from: components) ?? Date()
            },
            set: { date in
                let calendar = Calendar.current
                viewModel.reminderHour = calendar.component(.hour, from: date)
                viewModel.reminderMinute = calendar.component(.minute, from: date)
            }
        )
    }

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
            SecureField("API Key", text: $viewModel.apiKey)
                .autocorrectionDisabled()
                .autocapitalization(.none)

            if viewModel.apiKey.isEmpty {
                Text("Required for AI path generation. Get your key at platform.openai.com")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Label("API Key configured", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.pathGreen)
            }

            Toggle("Advanced Settings", isOn: $viewModel.showAdvancedSettings)

            if viewModel.showAdvancedSettings {
                TextField("Base URL", text: $viewModel.baseURL, prompt: Text("Enter your API endpoint URL"))
                    .autocorrectionDisabled()
                    .autocapitalization(.none)

                Text("Default: \(AIConfiguration.default.baseURL)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Model ID", text: $viewModel.modelID, prompt: Text("e.g., gpt-4o, claude-3-5-sonnet"))
                    .autocorrectionDisabled()
                    .autocapitalization(.none)

                Text("Default: \(AIConfiguration.default.modelID)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Presets")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AIConfiguration.presets) { preset in
                                Button {
                                    viewModel.applyPreset(preset)
                                } label: {
                                    Text(preset.name)
                                        .font(.subheadline)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .tint(viewModel.isPresetSelected(preset) ? .forgeBlue : .secondary)
                            }
                        }
                    }

                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
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

                VStack(alignment: .leading, spacing: 4) {
                    Text("Free Plan")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(subscriptionManager.remainingFreePaths) of \(subscriptionManager.maxFreePaths) paths remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                DatePicker("Reminder Time", selection: reminderDate, displayedComponents: .hourAndMinute)
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
        } footer: {
            Text("PathForge v1.0.0")
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}