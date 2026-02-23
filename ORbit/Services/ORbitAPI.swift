import Foundation

enum ORbitAPI {
    private static let creditsURL = URL(string: "https://openrouter.ai/api/v1/credits")!
    private static let keyURL     = URL(string: "https://openrouter.ai/api/v1/key")!
    private static let session: URLSession = URLSession(configuration: .ephemeral)

    static func fetchCredits(apiKey: String) async throws -> CreditsData {
        var request = URLRequest(url: creditsURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decoded = try JSONDecoder().decode(CreditsResponse.self, from: data)
            return decoded.data
        case 401, 403:
            throw APIError.unauthorized
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
    static func fetchKey(apiKey: String) async throws -> KeyData {
        var request = URLRequest(url: keyURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decoded = try JSONDecoder().decode(KeyResponse.self, from: data)
            return decoded.data
        case 401, 403:
            throw APIError.unauthorized
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Invalid API key"
        case .httpError(let code):
            return "HTTP error \(code)"
        }
    }
}
