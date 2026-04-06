import Foundation

actor UsageLimitsAPI {
    private let endpoint = URL(string: "https://api.anthropic.com/api/oauth/usage")!

    func fetch(token: String) async throws -> UsageLimits {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw UsageLimitsError.invalidResponse
        }

        if http.statusCode == 429 {
            let retryAfter = http.value(forHTTPHeaderField: "Retry-After")
                .flatMap(Int.init) ?? 60
            throw UsageLimitsError.rateLimited(retryAfterSeconds: retryAfter)
        }

        guard http.statusCode == 200 else {
            throw UsageLimitsError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(UsageLimitsResponse.self, from: data)

        return UsageLimits(
            fiveHour: decoded.fiveHour.flatMap { parseBucket($0) },
            sevenDay: decoded.sevenDay.flatMap { parseBucket($0) },
            sevenDaySonnet: decoded.sevenDaySonnet.flatMap { parseBucket($0) },
            fetchedAt: Date()
        )
    }

    private func parseBucket(_ r: BucketResponse) -> UsageBucket? {
        guard let utilization = r.utilization else { return nil }
        let date = r.resetsAt.flatMap { parseISO8601($0) }
        return UsageBucket(utilization: utilization, resetsAt: date)
    }

    private func parseISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}

enum UsageLimitsError: Error, LocalizedError {
    case noCredentials
    case invalidResponse
    case rateLimited(retryAfterSeconds: Int)
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .noCredentials:
            return "No Claude credentials found in Keychain"
        case .invalidResponse:
            return "Invalid API response"
        case .rateLimited(let seconds):
            let minutes = (seconds + 59) / 60
            return "Rate limited — retry in \(minutes) min"
        case .httpError(let code):
            return "HTTP error \(code)"
        }
    }
}
