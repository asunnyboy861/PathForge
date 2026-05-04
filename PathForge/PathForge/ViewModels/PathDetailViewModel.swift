import SwiftData
import Observation
import Foundation

@Observable
final class PathDetailViewModel {
    var isAdjusting = false
    var adjustmentFeedback = ""
    var errorMessage: String?

    private let pathService: PathGenerationService

    init(pathService: PathGenerationService) {
        self.pathService = pathService
    }

    func toggleTask(_ task: StudyTask, modelContext: ModelContext) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil

        let milestone = task.milestone
        if let milestone, milestone.tasks.allSatisfy(\.isCompleted) {
            milestone.isCompleted = true
            milestone.completedAt = Date()
        }

        try? modelContext.save()
    }

    func adjustPath(_ studyPath: StudyPath, modelContext: ModelContext) async {
        guard !adjustmentFeedback.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please describe what you'd like to adjust"
            return
        }

        isAdjusting = true
        errorMessage = nil

        let completedWeeks = studyPath.milestones.filter(\.isCompleted).count

        do {
            let adjusted = try await pathService.adjustPath(
                pathTitle: studyPath.title,
                pathDescription: studyPath.goalDescription,
                feedback: adjustmentFeedback,
                completedWeeks: completedWeeks
            )

            studyPath.milestones.removeAll { !$0.isCompleted }

            for milestone in adjusted.milestones {
                let m = Milestone(
                    weekNumber: milestone.weekNumber,
                    title: milestone.title,
                    milestoneDescription: milestone.description
                )
                for task in milestone.tasks {
                    let t = StudyTask(
                        title: task.title,
                        taskDescription: task.description,
                        estimatedMinutes: task.estimatedMinutes,
                        resourceType: task.resourceType,
                        resourceURL: task.resourceURL
                    )
                    m.tasks.append(t)
                }
                studyPath.milestones.append(m)
            }

            studyPath.updatedAt = Date()
            try? modelContext.save()
            adjustmentFeedback = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isAdjusting = false
    }
}
