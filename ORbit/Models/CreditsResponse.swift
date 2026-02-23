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
    let limitRemaining: Double?
    let limitReset: String?
    let isFreeTier: Bool

    enum CodingKeys: String, CodingKey {
        case label
        case usage
        case limit
        case limitRemaining = "limit_remaining"
        case limitReset     = "limit_reset"
        case isFreeTier     = "is_free_tier"
    }
}
