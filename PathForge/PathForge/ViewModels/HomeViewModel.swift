import SwiftData
import Observation
import Foundation

@Observable
final class HomeViewModel {
    var studyPaths: [StudyPath] = []
    var todayTasks: [StudyTask] = []
    var streakDays: Int = 0
    var weeklyStudyMinutes: Int = 0

    func fetchPaths(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<StudyPath>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        studyPaths = (try? modelContext.fetch(descriptor)) ?? []

        todayTasks = studyPaths.flatMap(\.todayTasks)
        calculateStreak()
    }

    func toggleTask(_ task: StudyTask, modelContext: ModelContext) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        try? modelContext.save()
        fetchPaths(modelContext: modelContext)
    }

    private func calculateStreak() {
        let calendar = Calendar.current
        var streak = 0
        let date = calendar.startOfDay(for: Date())

        while true {
            let nextDay = calendar.date(byAdding: .day, value: -streak, to: date)!
            let hasActivity = todayTasks.contains { task in
                guard let completed = task.completedAt else { return false }
                return calendar.isDate(completed, inSameDayAs: nextDay)
            }
            if hasActivity || streak == 0 {
                streak += 1
            } else {
                break
            }
            if streak > 365 { break }
        }
        streakDays = max(streak, 0)
    }
}
