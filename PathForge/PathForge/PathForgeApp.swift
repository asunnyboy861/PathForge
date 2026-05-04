import SwiftUI
import SwiftData

@main
struct PathForgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [StudyPath.self, Milestone.self, StudyTask.self, LearningResource.self])
    }
}
