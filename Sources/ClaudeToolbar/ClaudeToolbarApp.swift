import SwiftUI

@main
struct ClaudeToolbarApp: App {
    @State private var appState = AppState()

    init() {
        // Hide from dock — menu bar only
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("Claude", systemImage: "sparkle") {
            MenuBarView()
                .environment(appState)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
