import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().padding(.vertical, 4)

            if appState.apiKey.isEmpty {
                apiKeyPrompt
            } else if appState.isLoading {
                loadingView
            } else if let error = appState.error {
                errorView(error)
            } else if let usage = appState.usage {
                usageDetails(usage)
            }

            Divider().padding(.vertical, 4)
            footer
        }
        .padding(12)
        .frame(width: 280)
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.purple)
            Text("Claude Usage")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            if !appState.apiKey.isEmpty {
                Button(action: { Task { await appState.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderless)
                .disabled(appState.isLoading)
            }
        }
    }

    private var apiKeyPrompt: some View {
        @Bindable var state = appState
        return VStack(spacing: 8) {
            Text("Enter your Anthropic API key to view usage stats.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            SecureField("sk-ant-...", text: $state.apiKeyInput)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))

            Button("Save Key") {
                appState.saveAPIKey()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(appState.apiKeyInput.isEmpty)
        }
        .padding(.vertical, 4)
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.7)
            Text("Loading...")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Button("Retry") {
                Task { await appState.refresh() }
            }
            .buttonStyle(.bordered)
            .controlSize(.mini)
        }
        .padding(.vertical, 4)
    }

    private func usageDetails(_ usage: UsageData) -> some View {
        VStack(spacing: 6) {
            UsageRow(
                label: "Input tokens",
                value: formatTokens(usage.inputTokens),
                icon: "arrow.up.circle",
                color: .blue
            )
            UsageRow(
                label: "Output tokens",
                value: formatTokens(usage.outputTokens),
                icon: "arrow.down.circle",
                color: .green
            )
            UsageRow(
                label: "Total tokens",
                value: formatTokens(usage.totalTokens),
                icon: "sum",
                color: .purple
            )
            UsageRow(
                label: "Requests",
                value: "\(usage.requestCount)",
                icon: "number",
                color: .orange
            )
            UsageRow(
                label: "Cost",
                value: String(format: "$%.2f", usage.totalCost),
                icon: "dollarsign.circle",
                color: .pink
            )
        }
    }

    private var footer: some View {
        HStack {
            Button("Settings...") {
                appState.showSettings = true
            }
            .buttonStyle(.borderless)
            .font(.system(size: 11))

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

    private func formatTokens(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}
