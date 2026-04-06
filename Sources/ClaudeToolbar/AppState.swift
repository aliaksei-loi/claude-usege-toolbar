import SwiftUI
import Foundation

@MainActor
@Observable
final class AppState {
    var usage: UsageLimits?
    var isLoading = false
    var error: String?
    var refreshInterval: TimeInterval = 300 // 5 minutes

    /// Shown in the menu bar (e.g. "10%")
    var menuBarTitle: String = "…"

    private let api = UsageLimitsAPI()
    @ObservationIgnored private var initTask: Task<Void, Never>?
    @ObservationIgnored private var refreshTask: Task<Void, Never>?

    init() {
        initTask = Task {
            await refresh()
            startAutoRefresh()
        }
    }

    func shutdown() {
        initTask?.cancel()
        refreshTask?.cancel()
        initTask = nil
        refreshTask = nil
    }

    func refresh() async {
        isLoading = true
        error = nil

        guard let creds = KeychainReader.readClaudeCredentials() else {
            error = UsageLimitsError.noCredentials.localizedDescription
            menuBarTitle = "!"
            isLoading = false
            return
        }

        do {
            let limits = try await api.fetch(token: creds.accessToken)
            usage = limits

            // Show current session % used in menu bar
            if let session = limits.fiveHour {
                menuBarTitle = "\(Int(session.utilization))%"
            } else {
                menuBarTitle = "0%"
            }
        } catch let limitsError as UsageLimitsError {
            if case .rateLimited(let seconds) = limitsError {
                // Schedule retry after the rate limit expires
                scheduleRetry(after: seconds)
            }
            if usage == nil {
                self.error = limitsError.localizedDescription
                menuBarTitle = "!"
            }
        } catch {
            if usage == nil {
                self.error = error.localizedDescription
                menuBarTitle = "!"
            }
        }

        isLoading = false
    }

    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                guard !Task.isCancelled else { break }
                await refresh()
            }
        }
    }

    private func scheduleRetry(after seconds: Int) {
        refreshTask?.cancel()
        let delay = max(seconds + 5, 60) // wait slightly past the limit
        refreshTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            await refresh()
            startAutoRefresh()
        }
    }
}
