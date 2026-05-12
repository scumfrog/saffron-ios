import SwiftUI

/// A wrapper that adds a trailing swipe-to-delete gesture to any row view.
struct SwipeToDeleteRow<Content: View>: View {
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    private let deleteWidth: CGFloat = 72

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button revealed on swipe
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.3)) { offset = 0 }
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: deleteWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
            }

            content()
                .background(Color(.secondarySystemGroupedBackground))
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            let x = value.translation.width
                            guard x < 0 else { return }
                            offset = max(x, -deleteWidth)
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                offset = value.translation.width < -(deleteWidth / 2) ? -deleteWidth : 0
                            }
                        }
                )
        }
        .clipped()
    }
}
