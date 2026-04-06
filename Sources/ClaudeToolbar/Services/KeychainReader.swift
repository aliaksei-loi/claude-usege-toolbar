import Foundation
import Security

struct ClaudeCredentials: Sendable {
    let accessToken: String
    let subscriptionType: String
    let rateLimitTier: String
}

enum KeychainReader {
    static func readClaudeCredentials() -> ClaudeCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauth = json["claudeAiOauth"] as? [String: Any],
              let token = oauth["accessToken"] as? String,
              !token.isEmpty else {
            return nil
        }

        return ClaudeCredentials(
            accessToken: token,
            subscriptionType: oauth["subscriptionType"] as? String ?? "unknown",
            rateLimitTier: oauth["rateLimitTier"] as? String ?? "unknown"
        )
    }
}
