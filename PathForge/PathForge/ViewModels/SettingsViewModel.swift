import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var apiKey = UserDefaults.standard.string(forKey: AIConfigurationStorageKey.apiKey) ?? "" {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: AIConfigurationStorageKey.apiKey)
        }
    }

    var baseURL = UserDefaults.standard.string(forKey: AIConfigurationStorageKey.baseURL) ?? AIConfiguration.default.baseURL {
        didSet {
            UserDefaults.standard.set(baseURL, forKey: AIConfigurationStorageKey.baseURL)
        }
    }

    var modelID = UserDefaults.standard.string(forKey: AIConfigurationStorageKey.modelID) ?? AIConfiguration.default.modelID {
        didSet {
            UserDefaults.standard.set(modelID, forKey: AIConfigurationStorageKey.modelID)
        }
    }

    var showAdvancedSettings = false

    var aiConfiguration: AIConfiguration {
        AIConfiguration(apiKey: apiKey, baseURL: baseURL, modelID: modelID)
    }

    func applyPreset(_ preset: AIPreset) {
        if preset.isCustom {
            baseURL = ""
            modelID = ""
        } else {
            baseURL = preset.baseURL
            modelID = preset.modelID
        }
    }

    func isPresetSelected(_ preset: AIPreset) -> Bool {
        if preset.isCustom {
            return baseURL.isEmpty && modelID.isEmpty
        }
        return baseURL == preset.baseURL && modelID == preset.modelID
    }

    func resetToDefaults() {
        baseURL = AIConfiguration.default.baseURL
        modelID = AIConfiguration.default.modelID
    }

    var reminderHour = UserDefaults.standard.integer(forKey: "reminder_hour") {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminder_hour")
        }
    }

    var reminderMinute = UserDefaults.standard.integer(forKey: "reminder_minute") {
        didSet {
            UserDefaults.standard.set(reminderMinute, forKey: "reminder_minute")
        }
    }

    var notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled") {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
            if notificationsEnabled {
                Task {
                    let granted = await NotificationManager.shared.requestAuthorization()
                    if granted {
                        await NotificationManager.shared.scheduleStudyReminder(
                            hour: reminderHour, minute: reminderMinute
                        )
                    }
                }
            } else {
                NotificationManager.shared.cancelStudyReminder()
            }
        }
    }

    var useCloudKit = UserDefaults.standard.bool(forKey: "use_cloudkit") {
        didSet {
            UserDefaults.standard.set(useCloudKit, forKey: "use_cloudkit")
        }
    }

    init() {
        if reminderHour == 0 && reminderMinute == 0 {
            reminderHour = 9
            reminderMinute = 0
        }
    }
}