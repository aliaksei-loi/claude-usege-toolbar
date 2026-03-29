import Foundation

struct UsageData: Sendable {
    var inputTokens: Int
    var outputTokens: Int
    var totalCost: Double
    var requestCount: Int
    var periodStart: Date
    var periodEnd: Date

    var totalTokens: Int { inputTokens + outputTokens }
}

struct DailyUsage: Sendable, Identifiable {
    let id = UUID()
    let date: Date
    let inputTokens: Int
    let outputTokens: Int
    let cost: Double
    let requestCount: Int
}

// MARK: - API Response Types

struct OrganizationUsageResponse: Codable, Sendable {
    let id: String
    let name: String
    let totalTokens: Int?
    let totalCost: Double?

    enum CodingKeys: String, CodingKey {
        case id, name
        case totalTokens = "total_tokens"
        case totalCost = "total_cost"
    }
}
