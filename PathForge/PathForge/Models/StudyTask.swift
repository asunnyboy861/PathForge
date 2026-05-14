import SwiftData
import Foundation

@Model
final class StudyTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var estimatedMinutes: Int
    var resourceURL: String?
    var resourceType: String
    var isCompleted: Bool
    var completedAt: Date?
    var milestone: Milestone?

    enum ResourceType: String, Codable, CaseIterable {
        case video = "Video"
        case article = "Article"
        case exercise = "Exercise"
        case project = "Project"
        case book = "Book"
        case podcast = "Podcast"
    }

    init(title: String, taskDescription: String, estimatedMinutes: Int,
         resourceType: String, resourceURL: String? = nil) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.estimatedMinutes = estimatedMinutes
        self.resourceType = resourceType
        self.resourceURL = resourceURL
        self.isCompleted = false
    }
}
