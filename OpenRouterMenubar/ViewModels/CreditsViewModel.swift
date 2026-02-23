import Combine
import Foundation
import SwiftUI

@MainActor
final class CreditsViewModel: ObservableObject {
    @Published var balance: Double?
    @Published var totalCredits: Double?
    @Published var totalUsage: Double?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasAPIKey = false

    @Published var apiKeyInput = ""

    private var timerCancellable: AnyCancellable?

    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.locale = Locale(identifier: "en_US")
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    var menuBarTitle: String {
        if !hasAPIKey { return "ORb: --" }
        if isLoading && balance == nil { return "ORb: ..." }
        if let balance {
            return Self.formatter.string(from: NSNumber(value: balance)) ?? "ORb: ?"
        }
        if errorMessage != nil { return "ORb: ?" }
        return "ORb: --"
    }

    init() {
        hasAPIKey = KeychainHelper.retrieve() != nil
        if hasAPIKey {
            startTimer()
            Task { await fetchCredits() }
        }
    }

    func fetchCredits() async {
        guard let apiKey = KeychainHelper.retrieve() else {
            hasAPIKey = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let data = try await ORbitAPI.fetchCredits(apiKey: apiKey)
            balance = data.balance
            totalCredits = data.totalCredits
            totalUsage = data.totalUsage
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to fetch credits"
        }

        isLoading = false
    }

    func saveAPIKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        guard key.hasPrefix("sk-or-") else {
            errorMessage = "Invalid API key format"
            return
        }

        do {
            try KeychainHelper.save(apiKey: key)
            hasAPIKey = true
            apiKeyInput = ""
            errorMessage = nil
            startTimer()
            Task { await fetchCredits() }
        } catch let error as KeychainError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to save API key"
        }
    }

    func clearAPIKey() {
        KeychainHelper.delete()
        timerCancellable = nil
        hasAPIKey = false
        balance = nil
        totalCredits = nil
        totalUsage = nil
        errorMessage = nil
        apiKeyInput = ""
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.fetchCredits() }
            }
    }

    func formattedCurrency(_ value: Double) -> String {
        Self.formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
