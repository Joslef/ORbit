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
