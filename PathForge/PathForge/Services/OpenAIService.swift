import Foundation

final class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini"

    init(apiKey: String) {
        self.apiKey = apiKey
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
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
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
            throw OpenAIError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        return content
    }

    enum OpenAIError: LocalizedError {
        case invalidResponse
        case noContent

        var errorDescription: String? {
            switch self {
            case .invalidResponse: "Invalid response from AI service"
            case .noContent: "No content in AI response"
            }
        }
    }
}
