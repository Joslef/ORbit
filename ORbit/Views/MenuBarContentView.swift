import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var viewModel: CreditsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if viewModel.hasAPIKey {
                CreditCardView(viewModel: viewModel)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)

                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.horizontal, 8)
                }

                Divider()
                    .padding(.horizontal, 8)

                MenuRow(label: "Refresh", shortcut: "R") {
                    Task { await viewModel.fetchCredits() }
                }
                .disabled(viewModel.isLoading)
            } else {
                Text("No API key configured")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                Divider()
                    .padding(.horizontal, 8)
            }

            SettingsMenuRow(label: "Settings...", shortcut: ",")

            Divider()
                .padding(.horizontal, 8)

            MenuRow(label: "Quit", shortcut: "Q") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 4)
        .frame(width: 150)
        .background(.regularMaterial)
        .focusEffectDisabled()
    }
}

private struct SettingsMenuRow: View {
    let label: String
    let shortcut: String
    @State private var isHovered = false

    var body: some View {
        SettingsLink {
            MenuRowLabel(label: label, shortcut: shortcut)
                .background(isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .focusEffectDisabled()
        .simultaneousGesture(TapGesture().onEnded {
            NSApp.activate(ignoringOtherApps: true)
        })
        .onHover { isHovered = $0 }
    }
}

private struct MenuRow: View {
    let label: String
    let shortcut: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            MenuRowLabel(label: label, shortcut: shortcut)
                .background(isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

private struct MenuRowLabel: View {
    let label: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 0) {
                Text("⌘")
                    .frame(width: 13, alignment: .center)
                Text(shortcut)
                    .frame(width: 11, alignment: .center)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

private struct CreditCardView: View {
    @ObservedObject var viewModel: CreditsViewModel

    private var accentColor: Color {
        guard let balance = viewModel.balance else { return .green }
        if balance > 10 { return .green }
        if balance > 2  { return .orange }
        return .red
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Top: balance ──────────────────────────────
            ZStack {
                accentColor.opacity(0.15)

                VStack(spacing: 2) {
                    if viewModel.isLoading && viewModel.balance == nil {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text(viewModel.balance.map { viewModel.formattedCurrency($0) } ?? "--")
                            .font(.title2.bold())
                            .foregroundStyle(accentColor)
                        HStack(spacing: 4) {
                            Text("Balance")
                            if viewModel.keyData?.isFreeTier == true {
                                Text("Free")
                                    .font(.caption2)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.accentColor.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 12)
            }

            Divider()

            // ── Bottom: usage and credits stacked ────────
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Usage")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.totalUsage.map { viewModel.formattedCurrency($0) } ?? "--")
                        .bold()
                }
                HStack {
                    Text("Deposit")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.totalCredits.map { viewModel.formattedCurrency($0) } ?? "--")
                        .bold()
                }
                if let keyData = viewModel.keyData {
                    Divider()
                    usageRow("Today",  value: keyData.usageDaily)
                    usageRow("Week",   value: keyData.usageWeekly)
                    usageRow("Month",  value: keyData.usageMonthly)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private func usageRow(_ label: String, value: Double?) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.map { viewModel.formattedCurrency($0) } ?? "--")
                .bold()
        }
    }
}
