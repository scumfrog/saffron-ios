import SwiftUI

struct SourceBadge: View {
    let type: SourceType
    let label: String

    var body: some View {
        Group {
            if label.isEmpty {
                Image(systemName: type.systemImage)
                    .font(.caption.weight(.medium))
            } else {
                Label(label, systemImage: type.systemImage)
                    .font(.caption.weight(.medium))
            }
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.quaternary, in: Capsule())
    }
}
