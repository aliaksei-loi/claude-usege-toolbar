import SwiftUI

@main
struct ClaudeToolbarApp: App {
    @State private var appState = AppState()

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
        } label: {
            HStack(spacing: 3) {
                Image("MenuBarIcon", bundle: .module)
                    .renderingMode(.template)
                Text(appState.menuBarTitle)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
