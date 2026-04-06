import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if appState.isLoading && appState.usage == nil {
                loadingView
            } else if let error = appState.error, appState.usage == nil {
                errorView(error)
            } else if let usage = appState.usage {
                usageLimitsView(usage)
            }

            Divider().padding(.vertical, 6)
            footer(usage: appState.usage)
        }
        .padding(12)
        .frame(width: 300)
    }

    // MARK: - Usage Limits

    private func usageLimitsView(_ usage: UsageLimits) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your usage limits")
                .font(.system(size: 13, weight: .semibold))
                .padding(.bottom, 2)

            if let session = usage.fiveHour {
                limitRow(
                    title: "Current session",
                    resetLabel: formatReset(session.resetsAt),
                    utilization: session.utilization
                )
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Weekly limits")
                    .font(.system(size: 13, weight: .semibold))

                if let allModels = usage.sevenDay {
                    limitRow(
                        title: "All models",
                        resetLabel: formatWeeklyReset(allModels.resetsAt),
                        utilization: allModels.utilization
                    )
                }

                if let sonnet = usage.sevenDaySonnet {
                    limitRow(
                        title: "Sonnet only",
                        resetLabel: formatReset(sonnet.resetsAt),
                        utilization: sonnet.utilization,
                    )
                }
            }
        }
    }

    // MARK: - Limit Row

    private func limitRow(
        title: String,
        resetLabel: String,
        utilization: Double,
        showInfoIcon: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                    if showInfoIcon {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(resetLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 110, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor(utilization))
                        .frame(
                            width: max(geo.size.width * utilization / 100, utilization > 0 ? 6 : 0))
                }
            }
            .frame(height: 8)

            Text("\(Int(utilization))% used")
                .font(.system(size: 11).monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.7)
            Text("Loading usage limits...")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 12)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Button("Retry") {
                Task { await appState.refresh() }
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Footer

    private func footer(usage: UsageLimits?) -> some View {
        HStack {
            if let usage {
                Text("Last updated: \(relativeTime(usage.fetchedAt))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            Button(action: { Task { await appState.refresh() } }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .disabled(appState.isLoading)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func relativeTime(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        return "\(hours)h ago"
    }

    private func barColor(_ utilization: Double) -> Color {
        if utilization < 50 { return .blue }
        if utilization < 80 { return .yellow }
        return .red
    }

    private func formatReset(_ date: Date?) -> String {
        guard let date else { return "" }
        let diff = date.timeIntervalSinceNow
        guard diff > 0 else { return "Resetting..." }

        let totalMinutes = Int(diff) / 60
        let days = totalMinutes / 1440
        let hours = (totalMinutes % 1440) / 60
        let minutes = totalMinutes % 60

        if days > 0 {
            return "Resets in \(days)d \(hours)h"
        }
        if hours > 0 {
            return "Resets in \(hours)h \(minutes)m"
        }
        return "Resets in \(minutes)m"
    }

    private func formatWeeklyReset(_ date: Date?) -> String {
        guard let date else { return "" }
        let diff = date.timeIntervalSinceNow
        guard diff > 0 else { return "Resetting..." }

        // If more than 24h away, show day + time
        if diff > 86400 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEE h:mm a"
            return "Resets \(formatter.string(from: date))"
        }

        return formatReset(date)
    }
}
