import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        Form {
            Section("API Key") {
                if appState.apiKey.isEmpty {
                    SecureField("sk-ant-...", text: $state.apiKeyInput)
                    Button("Save") {
                        appState.saveAPIKey()
                    }
                    .disabled(appState.apiKeyInput.isEmpty)
                } else {
                    HStack {
                        Text(maskedKey)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Remove", role: .destructive) {
                            appState.clearAPIKey()
                        }
                    }
                }
            }

            Section("Refresh") {
                Picker("Auto-refresh interval", selection: $state.refreshInterval) {
                    Text("1 minute").tag(TimeInterval(60))
                    Text("5 minutes").tag(TimeInterval(300))
                    Text("15 minutes").tag(TimeInterval(900))
                    Text("30 minutes").tag(TimeInterval(1800))
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 200)
    }

    private var maskedKey: String {
        let key = appState.apiKey
        if key.count > 12 {
            return String(key.prefix(7)) + "..." + String(key.suffix(4))
        }
        return "••••••••"
    }
}
