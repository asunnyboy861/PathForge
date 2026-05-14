import SwiftData
import Observation
import Foundation

@Observable
final class StatsViewModel {
    var totalStudyMinutes: Int = 0
    var completedTasks: Int = 0
    var totalTasks: Int = 0
    var completedMilestones: Int = 0
    var totalMilestones: Int = 0
    var activePaths: Int = 0
    var weeklyData: [DayData] = []

    struct DayData: Identifiable {
        let id = UUID()
        let day: String
        let minutes: Int
    }

    func fetchStats(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<StudyPath>()
        let paths = (try? modelContext.fetch(descriptor)) ?? []

        activePaths = paths.filter(\.isActive).count
        completedMilestones = paths.flatMap(\.milestones).filter(\.isCompleted).count
        totalMilestones = paths.flatMap(\.milestones).count
        completedTasks = paths.flatMap(\.milestones).flatMap(\.tasks).filter(\.isCompleted).count
        totalTasks = paths.flatMap(\.milestones).flatMap(\.tasks).count

        let calendar = Calendar.current
        let now = Date()
        let completedTasksList = paths.flatMap(\.milestones).flatMap(\.tasks).filter(\.isCompleted)
        totalStudyMinutes = completedTasksList.reduce(0) { $0 + $1.estimatedMinutes }

        var dayData: [DayData] = []
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i - 6, to: now) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let minutes = completedTasksList
                .filter { task in
                    guard let completed = task.completedAt else { return false }
                    return completed >= dayStart && completed < dayEnd
                }
                .reduce(0) { $0 + $1.estimatedMinutes }

            let dayIndex = calendar.component(.weekday, from: date) - 1
            let dayName = dayNames[dayIndex == 0 ? 6 : dayIndex - 1]
            dayData.append(DayData(day: dayName, minutes: minutes))
        }
        weeklyData = dayData
    }
}
