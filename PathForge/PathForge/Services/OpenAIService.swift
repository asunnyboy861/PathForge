import Foundation

final class OpenAIService {
    private let configuration: AIConfiguration

    init(configuration: AIConfiguration) {
        self.configuration = configuration
    }

    struct CompletionResponse: Codable {
        let choices: [Choice]
        struct Choice: Codable {
            let message: Message
        }
        struct Message: Codable {
            let content: String
        }
    }

    func complete(prompt: String) async throws -> String {
        if configuration.apiKey.hasPrefix("sk-demo") || configuration.apiKey.isEmpty {
            return try await generateDemoResponse(prompt: prompt)
        }

        guard configuration.isValidBaseURL,
              let url = URL(string: configuration.baseURL) else {
            throw OpenAIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": configuration.modelID,
            "messages": [
                ["role": "system", "content": "You are an expert learning path designer. Always respond with valid JSON only."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 4096
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 60
        session.configuration.timeoutIntervalForResource = 120

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw OpenAIError.invalidResponse(statusCode: statusCode)
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        return content
    }

    func testConnection() async throws -> String {
        if configuration.apiKey.hasPrefix("sk-demo") || configuration.apiKey.isEmpty {
            return "OK"
        }

        guard configuration.isValidBaseURL,
              let url = URL(string: configuration.baseURL) else {
            throw OpenAIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": configuration.modelID,
            "messages": [
                ["role": "user", "content": "Reply with exactly: OK"]
            ],
            "max_tokens": 10
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 15
        session.configuration.timeoutIntervalForResource = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw OpenAIError.invalidResponse(statusCode: statusCode)
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func generateDemoResponse(prompt: String) async throws -> String {
        try await Task.sleep(for: .seconds(2))

        let demoPath: [String: Any] = [
            "title": "Demo: Introduction to Programming",
            "description": "A beginner-friendly learning path to get started with programming fundamentals.",
            "milestones": [
                [
                    "weekNumber": 1,
                    "title": "Getting Started",
                    "description": "Set up your development environment and learn basic concepts.",
                    "tasks": [
                        [
                            "title": "Install a Code Editor",
                            "description": "Download and install VS Code or your preferred editor.",
                            "estimatedMinutes": 30,
                            "resourceType": "tool",
                            "resourceURL": "https://code.visualstudio.com/"
                        ],
                        [
                            "title": "Hello World Program",
                            "description": "Write your first program that prints 'Hello, World!'.",
                            "estimatedMinutes": 20,
                            "resourceType": "tutorial",
                            "resourceURL": "https://www.freecodecamp.org/"
                        ]
                    ]
                ],
                [
                    "weekNumber": 2,
                    "title": "Variables and Data Types",
                    "description": "Learn about variables, strings, numbers, and booleans.",
                    "tasks": [
                        [
                            "title": "Learn Variable Basics",
                            "description": "Understand how to declare and use variables.",
                            "estimatedMinutes": 45,
                            "resourceType": "article",
                            "resourceURL": "https://developer.mozilla.org/"
                        ],
                        [
                            "title": "Practice Exercises",
                            "description": "Complete exercises on variables and data types.",
                            "estimatedMinutes": 60,
                            "resourceType": "exercise",
                            "resourceURL": "https://www.freecodecamp.org/"
                        ]
                    ]
                ]
            ],
            "resources": [
                [
                    "title": "freeCodeCamp",
                    "url": "https://www.freecodecamp.org/",
                    "type": "course",
                    "isFree": true,
                    "qualityScore": 5
                ],
                [
                    "title": "MDN Web Docs",
                    "url": "https://developer.mozilla.org/",
                    "type": "documentation",
                    "isFree": true,
                    "qualityScore": 5
                ]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: demoPath, options: [])
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    enum OpenAIError: LocalizedError {
        case invalidBaseURL
        case invalidResponse(statusCode: Int)
        case noContent
        case timeout

        var errorDescription: String? {
            switch self {
            case .invalidBaseURL: "Invalid API URL. Please check your configuration in Settings."
            case .invalidResponse(let statusCode): "API request failed with status code \(statusCode). Please verify your API key and configuration."
            case .noContent: "No content in AI response. Please try again."
            case .timeout: "Request timed out. Please check your network connection and API endpoint."
            }
        }
    }
}