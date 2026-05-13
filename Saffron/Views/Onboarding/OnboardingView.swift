import SwiftUI

struct OnboardingView: View {
    let onDone: () -> Void
    @Environment(AppTheme.self) private var theme
    @State private var currentSlide = 0
    @AppStorage("iCloudEnabled") private var iCloudEnabled = true

    private struct Slide: Identifiable {
        let id: Int
        let icon: String
        let title: String
        let subtitle: String
        var hasICloud = false
    }

    private let slides: [Slide] = [
        .init(
            id: 0,
            icon: "archivebox.fill",
            title: "Recipes that never disappear",
            subtitle: "Paste a link from any recipe website or blog. We save a complete local copy — ingredients, steps, and all."
        ),
        .init(
            id: 1,
            icon: "square.grid.2x2.fill",
            title: "Organized your way",
            subtitle: "Vegetarian, desserts, New Year's Eve… Create lists and tag recipes so you find them in seconds."
        ),
        .init(
            id: 2,
            icon: "icloud.fill",
            title: "iCloud sync",
            subtitle: "Your recipes, on all your devices. No accounts, no passwords. Just iCloud.",
            hasICloud: true
        ),
    ]

    private func iconColor(for slide: Slide) -> Color {
        switch slide.id {
        case 0: return .orange
        case 1: return theme.accent
        case 2: return .blue
        default: return theme.accent
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Slide content
            let slide = slides[currentSlide]
            let slideColor = iconColor(for: slide)
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(slideColor.opacity(0.12))
                        .frame(width: 140, height: 140)
                    Image(systemName: slide.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(slideColor)
                }
                .animation(.spring(duration: 0.4), value: currentSlide)

                VStack(spacing: 14) {
                    Text(slide.title)
                        .font(.system(size: 28, weight: .bold))
                        .tracking(-0.4)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(slide.subtitle)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if slide.hasICloud {
                    Button {
                        iCloudEnabled.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(iCloudEnabled ? theme.accent : Color(.tertiarySystemFill))
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(iCloudEnabled ? theme.accent : Color.secondary.opacity(0.4), lineWidth: 1.5)
                                    )
                                if iCloudEnabled {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            Text("Enable iCloud")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            iCloudEnabled
                                ? theme.accent.opacity(0.08)
                                : Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(iCloudEnabled ? theme.accent : .clear, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.horizontal, 32)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(currentSlide) // force re-render on slide change for transition

            Spacer()

            // Dots
            HStack(spacing: 6) {
                ForEach(slides) { slide in
                    Capsule()
                        .fill(slide.id == currentSlide ? theme.accent : Color.secondary.opacity(0.3))
                        .frame(width: slide.id == currentSlide ? 24 : 6, height: 6)
                        .animation(.spring(duration: 0.3), value: currentSlide)
                }
            }
            .padding(.bottom, 28)

            // CTA button
            VStack(spacing: 6) {
                Button {
                    if currentSlide < slides.count - 1 {
                        withAnimation { currentSlide += 1 }
                    } else {
                        onDone()
                    }
                } label: {
                    Text(currentSlide < slides.count - 1 ? "Continue" : "Get started")
                        .font(.system(size: 17, weight: .semibold))
                        .tracking(-0.3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accent, in: RoundedRectangle(cornerRadius: 14))
                        .shadow(color: theme.accent.opacity(0.4), radius: 10, x: 0, y: 4)
                }

                if currentSlide < slides.count - 1 {
                    Button("Skip") { onDone() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
