import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? "" {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
        }
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
