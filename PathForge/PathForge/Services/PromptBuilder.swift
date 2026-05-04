import Foundation

final class PromptBuilder {
    func buildPathPrompt(goal: String, currentLevel: String, targetLevel: String,
                         weeklyHours: Int, timelineWeeks: Int, learningStyle: String,
                         preferences: Set<String>) -> String {
        """
        You are an expert learning path designer. Create a detailed, personalized learning plan.

        GOAL: \(goal)
        CURRENT LEVEL: \(currentLevel)
        TARGET LEVEL: \(targetLevel)
        WEEKLY STUDY HOURS: \(weeklyHours)
        TIMELINE: \(timelineWeeks) weeks
        LEARNING STYLE: \(learningStyle)
        PREFERENCES: \(preferences.joined(separator: ", "))

        Return a JSON object with this exact structure:
        {
          "title": "string",
          "description": "string (2-3 sentences)",
          "milestones": [
            {
              "weekNumber": number,
              "title": "string",
              "description": "string",
              "tasks": [
                {
                  "title": "string",
                  "description": "string",
                  "estimatedMinutes": number,
                  "resourceType": "Video|Article|Exercise|Project|Book|Podcast",
                  "resourceURL": "string or null"
                }
              ]
            }
          ],
          "resources": [
            {
              "title": "string",
              "url": "string",
              "type": "Video|Article|Exercise|Project|Book|Podcast",
              "isFree": boolean,
              "qualityScore": number (1-10)
            }
          ]
        }

        RULES:
        - Each week should have 3-5 tasks totaling \(weeklyHours * 60) minutes
        - Progress from fundamentals to advanced topics
        - Include at least 1 hands-on project per milestone
        - Prioritize free resources when possible
        - Include specific, real URLs when available
        - Make tasks actionable and measurable
        """
    }

    func buildAdjustmentPrompt(pathTitle: String, pathDescription: String,
                                feedback: String, completedWeeks: Int) -> String {
        """
        The user has completed \(completedWeeks) weeks of their learning path.

        ORIGINAL GOAL: \(pathTitle)
        \(pathDescription)

        USER FEEDBACK: \(feedback)

        Adjust the remaining weeks of the learning plan based on this feedback.
        Keep completed milestones unchanged. Only modify future weeks.

        Return the same JSON structure as the original path generation,
        but only include milestones from week \(completedWeeks + 1) onwards.
        """
    }
}
