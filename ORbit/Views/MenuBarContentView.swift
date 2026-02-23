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
        .frame(width: 180)
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
        .keyboardShortcut(KeyEquivalent(shortcut.lowercased().first!), modifiers: .command)
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
        .keyboardShortcut(KeyEquivalent(shortcut.lowercased().first!), modifiers: .command)
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

private struct BudgetView: View {
    let limit: Double
    let remaining: Double
    let reset: String?
    let viewModel: CreditsViewModel

    private var used: Double     { limit - remaining }
    private var fraction: Double { limit > 0 ? min(used / limit, 1.0) : 0 }

    private var barColor: Color {
        if fraction < 0.7 { return .green }
        if fraction < 0.9 { return .orange }
        return .red
    }

    private var nextResetDate: Date? {
        guard let reset else { return nil }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let now = Date()
        switch reset {
        case "daily":
            return cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)
        case "weekly":
            return cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: 2), matchingPolicy: .nextTime)
        case "monthly":
            return cal.nextDate(after: now, matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)
        default:
            return nil
        }
    }

    private var timeUntilReset: String? {
        guard let target = nextResetDate else { return nil }
        let seconds = Int(target.timeIntervalSinceNow)
        guard seconds > 0 else { return nil }
        let days    = seconds / 86400
        let hours   = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        if days > 0    { return "in \(days)d \(hours)h" }
        if hours > 0   { return "in \(hours)h \(minutes)m" }
        return "in \(minutes)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("API Key")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text("Limit")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.formattedCurrency(remaining))
                    .bold()
                    .foregroundStyle(barColor)
                Text("/ \(viewModel.formattedCurrency(limit))")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor)
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 4)
            if let reset {
                HStack {
                    Text("Resets \(reset)")
                    Spacer()
                    if let countdown = timeUntilReset {
                        Text(countdown)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
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
                if let keyData = viewModel.keyData,
                   let limit = keyData.limit,
                   let remaining = keyData.limitRemaining {
                    Divider()
                    BudgetView(limit: limit, remaining: remaining,
                               reset: keyData.limitReset, viewModel: viewModel)
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

}
