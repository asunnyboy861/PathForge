import SwiftData
import Observation
import Foundation

@Observable
final class PathGenerationViewModel {
    var currentStep: GenerationStep = .goalInput
    var goalText = ""
    var selectedCategory = ""
    var currentLevel: StudyPath.SkillLevel = .beginner
    var targetLevel: StudyPath.SkillLevel = .intermediate
    var weeklyHours = 5
    var timelineWeeks = 8
    var learningStyle: LearningStyle = .mixed
    var isGenerating = false
    var generatedPath: PathGenerationService.GeneratedPath?
    var errorMessage: String?

    var canGenerate: Bool {
        let config = AIConfiguration.loadFromStorage()
        return config.isConfigured
    }

    enum GenerationStep: Int, CaseIterable {
        case goalInput = 0
        case levelAssessment = 1
        case timePreferences = 2
        case generating = 3
        case pathPreview = 4
    }

    enum LearningStyle: String, CaseIterable {
        case visual = "Visual (videos, diagrams)"
        case reading = "Reading (articles, books)"
        case handsOn = "Hands-on (projects, exercises)"
        case mixed = "Mixed (variety of formats)"
    }

    let popularGoals = ["Python", "React", "Swift", "Data Science", "UI/UX Design", "Photography",
                        "Public Speaking", "Machine Learning", "Guitar", "Spanish"]

    private var _pathService: PathGenerationService
    var pathService: PathGenerationService {
        get { _pathService }
        set { _pathService = newValue }
    }
    private var modelContext: ModelContext?

    init(pathService: PathGenerationService) {
        self._pathService = pathService
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var canProceed: Bool {
        switch currentStep {
        case .goalInput: return !goalText.trimmingCharacters(in: .whitespaces).isEmpty
        case .levelAssessment: return true
        case .timePreferences: return true
        default: return false
        }
    }

    func nextStep() {
        guard let next = GenerationStep(rawValue: currentStep.rawValue + 1) else { return }
        if next == .generating {
            currentStep = next
            Task { await generatePath() }
        } else {
            currentStep = next
        }
    }

    func previousStep() {
        guard let prev = GenerationStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prev
    }

    func generatePath() async {
        guard !goalText.isEmpty else {
            errorMessage = "Please describe your learning goal"
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            let path = try await pathService.generatePath(
                goal: goalText,
                currentLevel: currentLevel.rawValue,
                targetLevel: targetLevel.rawValue,
                weeklyHours: weeklyHours,
                timelineWeeks: timelineWeeks,
                learningStyle: learningStyle.rawValue,
                preferences: []
            )
            generatedPath = path
            currentStep = .pathPreview
        } catch {
            if error.localizedDescription.contains("status code 401") {
                errorMessage = "Invalid API key. Please check your API key in Settings."
            } else if error.localizedDescription.contains("status code 429") {
                errorMessage = "API rate limit reached. Please wait a moment and try again."
            } else if error.localizedDescription.contains("timed out") || error.localizedDescription.contains("timeout") {
                errorMessage = "Request timed out. Please check your network connection."
            } else {
                errorMessage = error.localizedDescription
            }
            currentStep = .timePreferences
        }

        isGenerating = false
    }

    func savePath() {
        guard let generatedPath, let modelContext else { return }

        let studyPath = StudyPath(
            title: generatedPath.title,
            goalDescription: generatedPath.description,
            skillCategory: selectedCategory,
            currentLevel: currentLevel.rawValue,
            targetLevel: targetLevel.rawValue,
            weeklyHours: weeklyHours,
            totalWeeks: timelineWeeks
        )

        for milestone in generatedPath.milestones {
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

        for resource in generatedPath.resources {
            let r = LearningResource(
                title: resource.title,
                url: resource.url,
                type: resource.type,
                isFree: resource.isFree,
                qualityScore: resource.qualityScore,
                source: "AI Generated"
            )
            studyPath.resources.append(r)
        }

        modelContext.insert(studyPath)
        try? modelContext.save()
    }
}
