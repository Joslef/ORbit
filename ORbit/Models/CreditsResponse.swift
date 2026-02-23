import Foundation

struct CreditsResponse: Codable {
    let data: CreditsData
}

struct CreditsData: Codable {
    let totalCredits: Double
    let totalUsage: Double

    var balance: Double {
        totalCredits - totalUsage
    }

    enum CodingKeys: String, CodingKey {
        case totalCredits = "total_credits"
        case totalUsage = "total_usage"
    }
}

struct KeyResponse: Codable {
    let data: KeyData
}

struct KeyData: Codable {
    let label: String
    let usage: Double
    let limit: Double?
    let isFreeTier: Bool
    let usageDaily: Double?
    let usageWeekly: Double?
    let usageMonthly: Double?

    enum CodingKeys: String, CodingKey {
        case label
        case usage
        case limit
        case isFreeTier   = "is_free_tier"
        case usageDaily   = "usage_daily"
        case usageWeekly  = "usage_weekly"
        case usageMonthly = "usage_monthly"
    }
}
