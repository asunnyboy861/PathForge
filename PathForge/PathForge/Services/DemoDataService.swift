import SwiftData
import Foundation

@MainActor
struct DemoDataService {
    static let hasDemoDataKey = "has_demo_data_loaded"

    static var shouldLoadDemoData: Bool {
        !UserDefaults.standard.bool(forKey: hasDemoDataKey)
    }

    static func loadDemoDataIfNeeded(modelContext: ModelContext) {
        guard shouldLoadDemoData else { return }

        let config = AIConfiguration.loadFromStorage()
        guard config.apiKey.isEmpty else { return }

        let demoPath = createDemoPath()
        modelContext.insert(demoPath)
        try? modelContext.save()

        UserDefaults.standard.set(true, forKey: hasDemoDataKey)
    }

    static func createDemoPath() -> StudyPath {
        let path = StudyPath(
            title: "Master SwiftUI Development",
            goalDescription: "Learn SwiftUI from scratch to building production-ready iOS apps",
            skillCategory: "Programming",
            currentLevel: "Beginner",
            targetLevel: "Advanced",
            weeklyHours: 5,
            totalWeeks: 4
        )
        path.isDemo = true

        let week1 = Milestone(weekNumber: 1, title: "SwiftUI Fundamentals", milestoneDescription: "Master the core concepts of SwiftUI: views, modifiers, and state management")
        week1.tasks = [
            StudyTask(title: "Complete SwiftUI Basics Tutorial", taskDescription: "Follow Apple's official SwiftUI tutorial to understand view hierarchy and modifiers", estimatedMinutes: 45, resourceType: "Article", resourceURL: "https://developer.apple.com/tutorials/swiftui"),
            StudyTask(title: "Build a Simple Card View", taskDescription: "Create a reusable card component using VStack, HStack, and modifiers", estimatedMinutes: 30, resourceType: "Exercise"),
            StudyTask(title: "Watch Stanford CS193p Lecture 1", taskDescription: "Introduction to SwiftUI and declarative UI paradigm", estimatedMinutes: 60, resourceType: "Video", resourceURL: "https://cs193p.sites.stanford.edu"),
            StudyTask(title: "Practice with State and Binding", taskDescription: "Build a counter app using @State and a settings screen using @Binding", estimatedMinutes: 40, resourceType: "Exercise")
        ]
        week1.tasks[0].isCompleted = true
        week1.tasks[0].completedAt = Date().addingTimeInterval(-86400)
        week1.tasks[1].isCompleted = true
        week1.tasks[1].completedAt = Date().addingTimeInterval(-43200)

        let week2 = Milestone(weekNumber: 2, title: "Navigation and Lists", milestoneDescription: "Learn NavigationStack, List views, and data-driven UIs")
        week2.tasks = [
            StudyTask(title: "Implement NavigationStack", taskDescription: "Build a multi-screen app with NavigationStack and navigation destinations", estimatedMinutes: 50, resourceType: "Exercise"),
            StudyTask(title: "Create a Dynamic List View", taskDescription: "Build a list that fetches and displays data with custom row layouts", estimatedMinutes: 45, resourceType: "Exercise"),
            StudyTask(title: "Watch Stanford CS193p Lecture 3", taskDescription: "Navigation and List patterns in SwiftUI", estimatedMinutes: 60, resourceType: "Video"),
            StudyTask(title: "Build a Recipe Browser", taskDescription: "Combine NavigationStack and List to create a recipe browsing app", estimatedMinutes: 60, resourceType: "Project")
        ]

        let week3 = Milestone(weekNumber: 3, title: "Data Flow and Persistence", milestoneDescription: "Master @Observable, SwiftData, and app data architecture")
        week3.tasks = [
            StudyTask(title: "Migrate to @Observable", taskDescription: "Refactor an app from ObservableObject to the new @Observable macro", estimatedMinutes: 40, resourceType: "Exercise"),
            StudyTask(title: "Implement SwiftData Models", taskDescription: "Create SwiftData models with relationships and use them in your app", estimatedMinutes: 50, resourceType: "Exercise"),
            StudyTask(title: "Read SwiftData Documentation", taskDescription: "Study Apple's SwiftData framework documentation and migration guide", estimatedMinutes: 30, resourceType: "Article", resourceURL: "https://developer.apple.com/documentation/swiftdata"),
            StudyTask(title: "Build a Task Manager App", taskDescription: "Create a full CRUD task manager using SwiftData and @Observable", estimatedMinutes: 90, resourceType: "Project")
        ]

        let week4 = Milestone(weekNumber: 4, title: "Polish and Production", milestoneDescription: "Add animations, custom components, and prepare for App Store")
        week4.tasks = [
            StudyTask(title: "Add Animations and Transitions", taskDescription: "Implement smooth animations using withAnimation and matchedGeometryEffect", estimatedMinutes: 45, resourceType: "Exercise"),
            StudyTask(title: "Create Reusable Components", taskDescription: "Extract common UI patterns into reusable ViewModifiers and components", estimatedMinutes: 40, resourceType: "Exercise"),
            StudyTask(title: "Implement Widget Kit", taskDescription: "Add a home screen widget showing today's tasks", estimatedMinutes: 60, resourceType: "Exercise"),
            StudyTask(title: "Final Project: Portfolio App", taskDescription: "Build a complete portfolio app combining all learned concepts", estimatedMinutes: 120, resourceType: "Project")
        ]

        path.milestones = [week1, week2, week3, week4]

        week1.studyPath = path
        week2.studyPath = path
        week3.studyPath = path
        week4.studyPath = path

        path.resources = [
            LearningResource(title: "Apple SwiftUI Tutorials", url: "https://developer.apple.com/tutorials/swiftui", type: "Article", isFree: true, qualityScore: 9.5, source: "Apple"),
            LearningResource(title: "Stanford CS193p", url: "https://cs193p.sites.stanford.edu", type: "Video", isFree: true, qualityScore: 9.0, source: "Stanford"),
            LearningResource(title: "Hacking with Swift", url: "https://www.hackingwithswift.com/100/swiftui", type: "Article", isFree: true, qualityScore: 8.5, source: "Paul Hudson")
        ]

        return path
    }

    static var isDemoMode: Bool {
        let config = AIConfiguration.loadFromStorage()
        return config.apiKey.isEmpty
    }

    static func removeDemoData(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<StudyPath>(predicate: #Predicate { $0.isDemo == true })
        let demoPaths = (try? modelContext.fetch(descriptor)) ?? []
        for path in demoPaths {
            modelContext.delete(path)
        }
        try? modelContext.save()
    }

    static func resetDemoFlag() {
        UserDefaults.standard.set(false, forKey: hasDemoDataKey)
    }
}
