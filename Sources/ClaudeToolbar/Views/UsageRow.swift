import SwiftUI

struct UsageRow: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .medium).monospacedDigit())
                .foregroundStyle(.primary)
        }
    }
}
