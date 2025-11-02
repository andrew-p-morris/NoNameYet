import SwiftUI

struct DietaryRestrictionsView: View {

    private enum Option: String {
        case restrictions
        case none
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var selectedOption: Option?
    @State private var dietaryInput: String = ""
    @State private var typingIndicator = false
    @FocusState private var isTextFocused: Bool
    @State private var navigateToPlan = false

    var body: some View {
        ZStack {
            liquidGlassBackground()

            VStack(alignment: .leading, spacing: 32) {
                header

                LiquidGlassPane {
                    VStack(alignment: .leading, spacing: 24) {
                        optionButtons

                        if selectedOption == .restrictions {
                            chatPanel
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.vertical, 32)
                    .liquidGlassPanePadding()
                }

                Spacer(minLength: 0)

                bottomArrow
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .onAppear(perform: configureFromData)
        .navigationDestination(isPresented: $navigateToPlan) {
            HealthPlanView()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LiquidGlassPalette.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(LiquidGlassPalette.glassBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)

            Text("Dietary Restrictions")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(LiquidGlassPalette.textPrimary)
        }
    }

    private var optionButtons: some View {
        HStack(spacing: 16) {
            capsuleButton(label: "Dietary Restrictions", isSelected: selectedOption == .some(.restrictions)) {
                select(.restrictions)
            }

            capsuleButton(label: "None", isSelected: selectedOption == .some(.none)) {
                select(.none)
            }
        }
    }

    private var chatPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Circle()
                    .fill(LiquidGlassPalette.accentBright.opacity(0.35))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(LiquidGlassPalette.textPrimary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Coach Assistant")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(LiquidGlassPalette.textPrimary)

                    Text("Enter dietary restrictions separated by commas (e.g., dairy, gluten, shellfish).")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(LiquidGlassPalette.textSecondary)
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(LiquidGlassPalette.glassBorder.opacity(0.8), lineWidth: 1.4)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )

                TextEditor(text: $dietaryInput)
                    .focused($isTextFocused)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(LiquidGlassPalette.textPrimary)
                    .padding(16)
                    .frame(minHeight: 140, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }

            if typingIndicator {
                HStack(spacing: 6) {
                    Text("Analyzing details…")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(LiquidGlassPalette.textSecondary)

                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(LiquidGlassPalette.accentBright)
                        .scaleEffect(0.8)
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82, blendDuration: 0.1), value: typingIndicator)
        .onChange(of: dietaryInput) { newValue in
            onboardingData.dietaryInputRaw = newValue
            onboardingData.dietaryRestrictions = newValue.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        .onAppear {
            triggerTypingIndicator()
        }
    }

    private var bottomArrow: some View {
        HStack {
            Spacer()

            Button(action: proceed) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(LiquidGlassPalette.textPrimary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(LiquidGlassPalette.glassBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .opacity(selectedOption == nil ? 0.4 : 1)
            .disabled(selectedOption == nil)
        }
    }

    @ViewBuilder
    private func capsuleButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? LiquidGlassPalette.textPrimary : LiquidGlassPalette.textPrimary.opacity(0.85))
                .padding(.horizontal, 24)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isSelected
                                ? [LiquidGlassPalette.accentSoft.opacity(0.6), LiquidGlassPalette.accentBright.opacity(0.55)]
                                : [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? LiquidGlassPalette.accentBright.opacity(0.6) : LiquidGlassPalette.glassBorder, lineWidth: 1.2)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func select(_ option: Option) {
        selectedOption = option

        switch option {
        case .restrictions:
            triggerTypingIndicator()
        case .none:
            dietaryInput = ""
            onboardingData.dietaryInputRaw = ""
            onboardingData.dietaryRestrictions = []
            typingIndicator = false
        }
    }

    private func triggerTypingIndicator() {
        typingIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            typingIndicator = false
        }
    }

    private func proceed() {
        if case .some(.none) = selectedOption {
            onboardingData.dietaryInputRaw = ""
            onboardingData.dietaryRestrictions = []
        } else {
            onboardingData.dietaryInputRaw = dietaryInput
            onboardingData.dietaryRestrictions = dietaryInput.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        onboardingData.generatePlaceholderPlan()
        navigateToPlan = true
    }

    private func configureFromData() {
        dietaryInput = onboardingData.dietaryInputRaw

        if !onboardingData.dietaryRestrictions.isEmpty || !dietaryInput.isEmpty {
            selectedOption = .restrictions
        }
    }
}

#Preview {
    NavigationStack {
        DietaryRestrictionsView()
    }
    .environmentObject(OnboardingData())
}


