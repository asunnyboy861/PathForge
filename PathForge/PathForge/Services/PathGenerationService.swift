import Foundation

@MainActor
final class PathGenerationService {
    private let openAIService: OpenAIService
    private let promptBuilder = PromptBuilder()

    struct GeneratedPath: Codable {
        let title: String
        let description: String
        let milestones: [GeneratedMilestone]
        let resources: [GeneratedResource]
    }

    struct GeneratedMilestone: Codable {
        let weekNumber: Int
        let title: String
        let description: String
        let tasks: [GeneratedTask]
    }

    struct GeneratedTask: Codable {
        let title: String
        let description: String
        let estimatedMinutes: Int
        let resourceType: String
        let resourceURL: String?
    }

    struct GeneratedResource: Codable {
        let title: String
        let url: String
        let type: String
        let isFree: Bool
        let qualityScore: Double
    }

    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
    }

    func generatePath(goal: String, currentLevel: String, targetLevel: String,
                      weeklyHours: Int, timelineWeeks: Int, learningStyle: String,
                      preferences: Set<String>) async throws -> GeneratedPath {
        let prompt = promptBuilder.buildPathPrompt(
            goal: goal, currentLevel: currentLevel, targetLevel: targetLevel,
            weeklyHours: weeklyHours, timelineWeeks: timelineWeeks,
            learningStyle: learningStyle, preferences: preferences
        )
        let response = try await openAIService.complete(prompt: prompt)
        return try parseGeneratedPath(response)
    }

    func adjustPath(pathTitle: String, pathDescription: String,
                    feedback: String, completedWeeks: Int) async throws -> GeneratedPath {
        let prompt = promptBuilder.buildAdjustmentPrompt(
            pathTitle: pathTitle, pathDescription: pathDescription,
            feedback: feedback, completedWeeks: completedWeeks
        )
        let response = try await openAIService.complete(prompt: prompt)
        return try parseGeneratedPath(response)
    }

    private func parseGeneratedPath(_ response: String) throws -> GeneratedPath {
        let cleaned = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw PathGenerationError.parsingFailed
        }

        do {
            let decoded = try JSONDecoder().decode(GeneratedPath.self, from: data)
            return decoded
        } catch {
            throw PathGenerationError.parsingFailed
        }
    }

    enum PathGenerationError: LocalizedError {
        case parsingFailed

        var errorDescription: String? {
            switch self {
            case .parsingFailed: "Failed to parse AI response. Please try again."
            }
        }
    }
}
