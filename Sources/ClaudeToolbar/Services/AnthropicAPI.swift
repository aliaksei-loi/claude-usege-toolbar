import Foundation

actor AnthropicAPI {
    private let baseURL = "https://api.anthropic.com/v1"
    private var apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func updateAPIKey(_ key: String) {
        self.apiKey = key
    }

    func fetchUsage() async throws -> UsageData {
        // TODO: Replace with actual Anthropic usage API when available
        // For now, return placeholder data
        // The Anthropic Admin API endpoint would be:
        // GET https://api.anthropic.com/v1/organizations/{org_id}/usage
        return UsageData(
            inputTokens: 0,
            outputTokens: 0,
            totalCost: 0,
            requestCount: 0,
            periodStart: Calendar.current.startOfDay(for: Date()),
            periodEnd: Date()
        )
    }

    func validateKey() async throws -> Bool {
        var request = URLRequest(url: URL(string: "\(baseURL)/messages")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        // Minimal request to check key validity
        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 1,
            "messages": [["role": "user", "content": "hi"]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return false }

        // 200 = valid key, 401 = invalid
        return httpResponse.statusCode == 200
    }
}
