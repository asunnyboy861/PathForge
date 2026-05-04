import SwiftData
import Foundation

@Model
final class Milestone {
    @Attribute(.unique) var id: UUID
    var weekNumber: Int
    var title: String
    var milestoneDescription: String
    var isCompleted: Bool
    var completedAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \StudyTask.milestone)
    var tasks: [StudyTask] = []
    var studyPath: StudyPath?

    init(weekNumber: Int, title: String, milestoneDescription: String) {
        self.id = UUID()
        self.weekNumber = weekNumber
        self.title = title
        self.milestoneDescription = milestoneDescription
        self.isCompleted = false
    }

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter(\.isCompleted).count
        return Double(completed) / Double(tasks.count)
    }
}
