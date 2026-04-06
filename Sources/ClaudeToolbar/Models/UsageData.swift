import Foundation

struct UsageLimits: Sendable {
    let fiveHour: UsageBucket?
    let sevenDay: UsageBucket?
    let sevenDaySonnet: UsageBucket?
    let fetchedAt: Date
}

struct UsageBucket: Sendable {
    let utilization: Double // 0–100 percent used
    let resetsAt: Date?

    var remainingPercent: Double { max(100 - utilization, 0) }
}

// MARK: - API Response

struct UsageLimitsResponse: Codable, Sendable {
    let fiveHour: BucketResponse?
    let sevenDay: BucketResponse?
    let sevenDaySonnet: BucketResponse?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDaySonnet = "seven_day_sonnet"
    }
}

struct BucketResponse: Codable, Sendable {
    let utilization: Double?
    let resetsAt: String?

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}
