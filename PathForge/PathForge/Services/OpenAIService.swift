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

        let (data, response) = try await URLSession.shared.data(for: request)

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

    enum OpenAIError: LocalizedError {
        case invalidBaseURL
        case invalidResponse(statusCode: Int)
        case noContent

        var errorDescription: String? {
            switch self {
            case .invalidBaseURL: "Invalid API URL. Please check your configuration in Settings."
            case .invalidResponse(let statusCode): "API request failed with status code \(statusCode). Please verify your API key and configuration."
            case .noContent: "No content in AI response. Please try again."
            }
        }
    }
}