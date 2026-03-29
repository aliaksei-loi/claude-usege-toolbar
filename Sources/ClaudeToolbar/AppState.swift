import SwiftUI
import Foundation

@MainActor
@Observable
final class AppState {
    var usage: UsageData?
    var isLoading = false
    var error: String?
    var apiKey: String = ""
    var apiKeyInput: String = ""
    var showSettings = false
    var refreshInterval: TimeInterval = 300 // 5 minutes

    private var api: AnthropicAPI?
    private var refreshTask: Task<Void, Never>?

    private static let apiKeyKey = "anthropic_api_key"

    init() {
        loadAPIKey()
    }

    func saveAPIKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        apiKey = key
        apiKeyInput = ""

        // Store in UserDefaults (consider Keychain for production)
        UserDefaults.standard.set(key, forKey: Self.apiKeyKey)

        api = AnthropicAPI(apiKey: key)
        Task { await refresh() }
        startAutoRefresh()
    }

    func clearAPIKey() {
        apiKey = ""
        usage = nil
        error = nil
        api = nil
        refreshTask?.cancel()
        UserDefaults.standard.removeObject(forKey: Self.apiKeyKey)
    }

    func refresh() async {
        guard let api else { return }

        isLoading = true
        error = nil

        do {
            usage = try await api.fetchUsage()
        } catch {
            self.error = error.localizedDescription
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

    private func loadAPIKey() {
        if let key = UserDefaults.standard.string(forKey: Self.apiKeyKey), !key.isEmpty {
            apiKey = key
            api = AnthropicAPI(apiKey: key)
            Task {
                await refresh()
                startAutoRefresh()
            }
        }
    }
}
