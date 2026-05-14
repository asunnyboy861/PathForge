import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleStudyReminder(hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Time to Study!"
        content.body = "Keep your learning streak alive. Open PathForge to see today's tasks."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "studyReminder", content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func cancelStudyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["studyReminder"])
    }
}
