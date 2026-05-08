import Foundation

struct AIConfiguration: Equatable {
    var apiKey: String = ""
    var baseURL: String = "https://api.openai.com/v1/chat/completions"
    var modelID: String = "gpt-4o-mini"

    static let `default` = AIConfiguration()

    var isConfigured: Bool {
        !apiKey.isEmpty && !baseURL.isEmpty && !modelID.isEmpty
    }

    var isValidBaseURL: Bool {
        URL(string: baseURL) != nil
    }

    var providerDisplayName: String {
        if baseURL.contains("api.openai.com") { return "OpenAI" }
        if baseURL.contains("api.deepseek.com") { return "DeepSeek" }
        if baseURL.contains("localhost") || baseURL.contains("127.0.0.1") { return "Local (Ollama)" }
        if baseURL.contains("openai.azure.com") { return "Azure OpenAI" }
        return "Custom"
    }
}

struct AIPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let baseURL: String
    let modelID: String
    let isCustom: Bool

    init(name: String, baseURL: String, modelID: String, isCustom: Bool = false) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.name = name
        self.baseURL = baseURL
        self.modelID = modelID
        self.isCustom = isCustom
    }
}

extension AIConfiguration {
    static let presets: [AIPreset] = [
        AIPreset(name: "OpenAI", baseURL: "https://api.openai.com/v1/chat/completions", modelID: "gpt-4o-mini"),
        AIPreset(name: "DeepSeek", baseURL: "https://api.deepseek.com/chat/completions", modelID: "deepseek-chat"),
        AIPreset(name: "Ollama (Local)", baseURL: "http://localhost:11434/v1/chat/completions", modelID: "llama3"),
        AIPreset(name: "Custom", baseURL: "", modelID: "", isCustom: true)
    ]
}

enum AIConfigurationStorageKey {
    static let apiKey = "openai_api_key"
    static let baseURL = "ai_base_url"
    static let modelID = "ai_model_id"
}

extension AIConfiguration {
    static func loadFromStorage() -> AIConfiguration {
        if let activeProfile = AIProfileManager.shared.getActiveProfile() {
            return AIConfiguration(
                apiKey: activeProfile.apiKey,
                baseURL: activeProfile.baseURL,
                modelID: activeProfile.modelID
            )
        }

        var config = AIConfiguration.default
        config.apiKey = UserDefaults.standard.string(forKey: AIConfigurationStorageKey.apiKey) ?? ""
        config.baseURL = UserDefaults.standard.string(forKey: AIConfigurationStorageKey.baseURL) ?? AIConfiguration.default.baseURL
        config.modelID = UserDefaults.standard.string(forKey: AIConfigurationStorageKey.modelID) ?? AIConfiguration.default.modelID
        return config
    }

    func saveToStorage() {
        UserDefaults.standard.set(apiKey, forKey: AIConfigurationStorageKey.apiKey)
        UserDefaults.standard.set(baseURL, forKey: AIConfigurationStorageKey.baseURL)
        UserDefaults.standard.set(modelID, forKey: AIConfigurationStorageKey.modelID)
    }
}