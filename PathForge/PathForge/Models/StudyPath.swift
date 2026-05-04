import SwiftData
import Foundation

@Model
final class StudyPath {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String
    var skillCategory: String
    var currentLevel: String
    var targetLevel: String
    var weeklyHours: Int
    var totalWeeks: Int
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool
    @Relationship(deleteRule: .cascade, inverse: \Milestone.studyPath)
    var milestones: [Milestone] = []
    @Relationship(deleteRule: .cascade, inverse: \LearningResource.studyPath)
    var resources: [LearningResource] = []

    enum SkillLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }

    init(title: String, goalDescription: String, skillCategory: String,
         currentLevel: String, targetLevel: String,
         weeklyHours: Int, totalWeeks: Int) {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.skillCategory = skillCategory
        self.currentLevel = currentLevel
        self.targetLevel = targetLevel
        self.weeklyHours = weeklyHours
        self.totalWeeks = totalWeeks
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = true
    }

    var overallProgress: Double {
        guard !milestones.isEmpty else { return 0 }
        let completed = milestones.filter(\.isCompleted).count
        return Double(completed) / Double(milestones.count)
    }

    var currentWeekNumber: Int {
        let completedWeeks = milestones.filter(\.isCompleted).count
        return min(completedWeeks + 1, totalWeeks)
    }

    var todayTasks: [StudyTask] {
        let currentMilestone = milestones.first(where: { !$0.isCompleted })
        return currentMilestone?.tasks.filter { !$0.isCompleted } ?? []
    }
}
