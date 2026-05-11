import SwiftUI

struct CookModeView: View {
    let recipe: Recipe
    @Environment(AppTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    private var totalSteps: Int { recipe.steps.count }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Exit")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.12), in: Capsule())
                    }
                    Spacer()
                    Text("COOK MODE")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(0.4)
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    // Balance spacer
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("Exit")
                    }
                    .opacity(0)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)

                // Progress segments
                HStack(spacing: 4) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= currentStep ? theme.accent : Color.white.opacity(0.18))
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)

                // Step counter
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.system(size: 14, weight: .medium))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 24)

                // Step text
                ScrollView {
                    Text(recipe.steps[currentStep])
                        .font(.system(size: 28, weight: .semibold))
                        .tracking(-0.5)
                        .lineSpacing(4)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.top, 24)
                }
                .frame(maxHeight: .infinity)

                // Hint
                Text("Screen active · Won't lock while cooking")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 8)

                // Navigation buttons
                HStack(spacing: 12) {
                    Button {
                        withAnimation { currentStep = max(0, currentStep - 1) }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(-0.3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white.opacity(currentStep == 0 ? 0.06 : 0.12),
                                    in: RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(currentStep == 0)
                    .opacity(currentStep == 0 ? 0.35 : 1)

                    Button {
                        if currentStep == totalSteps - 1 {
                            dismiss()
                        } else {
                            withAnimation { currentStep += 1 }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(currentStep == totalSteps - 1 ? "Done!" : "Next")
                            if currentStep < totalSteps - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(-0.3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accent, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .frame(maxWidth: .infinity * 1.5)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear  { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .preferredColorScheme(.dark)
    }
}
