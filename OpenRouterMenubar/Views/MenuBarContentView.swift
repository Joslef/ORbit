import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var viewModel: CreditsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.hasAPIKey {
                if let balance = viewModel.balance {
                    LabeledContent("Balance", value: viewModel.formattedCurrency(balance))
                }
                if let credits = viewModel.totalCredits {
                    LabeledContent("Credits", value: viewModel.formattedCurrency(credits))
                }
                if let usage = viewModel.totalUsage {
                    LabeledContent("Usage", value: viewModel.formattedCurrency(usage))
                }

                if let error = viewModel.errorMessage {
                    Divider()
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Divider()

                Button("Refresh Now") {
                    Task { await viewModel.fetchCredits() }
                }
                .keyboardShortcut("r")
                .disabled(viewModel.isLoading)
            } else {
                Text("No API key configured")
                    .foregroundStyle(.secondary)
                Divider()
            }

            SettingsLink {
                Text("API Key Settings...")
            }
            .keyboardShortcut(",")

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(4)
    }
}
