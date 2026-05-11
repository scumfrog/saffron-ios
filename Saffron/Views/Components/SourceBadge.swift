import SwiftUI

struct SourceBadge: View {
    let type: SourceType
    let label: String

    var body: some View {
        Label(label, systemImage: type.systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.quaternary, in: Capsule())
    }
}
