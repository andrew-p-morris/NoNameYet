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
    @State private var restrictionsConfirmed = false
    @FocusState private var isTextFocused: Bool
    @State private var navigateToPlan = false
    @State private var selectedDietType: DietType?

    var body: some View {
        ZStack {
            simpleBackground()

            VStack(alignment: .leading, spacing: 32) {
                header

                SimpleCardPane {
                    VStack(alignment: .leading, spacing: 24) {
                        optionButtons

                        if selectedOption == .restrictions && !restrictionsConfirmed {
                            chatPanel
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        if (selectedOption == .restrictions && restrictionsConfirmed) || selectedOption == .none {
                            dietTypeSelection
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.vertical, 32)
                    .simpleCardPadding()
                }

                Spacer(minLength: 0)

                bottomArrow
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .onAppear(perform: configureFromData)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToPlan) {
            ActivityLevelView()
        }
    }

    private var canProceed: Bool {
        guard selectedOption != nil, selectedDietType != nil else {
            return false
        }
        
        // If YES selected, must be confirmed first
        if selectedOption == .restrictions && !restrictionsConfirmed {
            return false
        }
        
        return true
    }
    
    private var header: some View {
        Text("DIETARY RESTRICTIONS")
            .font(SimplePalette.retroFont(size: 26, weight: .bold))
            .foregroundStyle(SimplePalette.textPrimary)
    }

    private var optionButtons: some View {
        HStack(spacing: 16) {
            capsuleButton(label: "YES", isSelected: selectedOption == Option.restrictions) {
                select(.restrictions)
            }

            capsuleButton(label: "NO", isSelected: selectedOption == .none) {
                select(.none)
            }
        }
    }
    
    private var dietTypeSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SELECT DIET TYPE")
                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(DietType.allCases) { dietType in
                    Button(action: {
                        selectedDietType = dietType
                        onboardingData.dietType = dietType
                    }) {
                        Text(dietType.rawValue.uppercased())
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(selectedDietType == dietType ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(selectedDietType == dietType ? SimplePalette.retroRed : SimplePalette.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(SimplePalette.retroBlack, lineWidth: 3)
                                    )
                                    .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var chatPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SimplePalette.retroRed.opacity(0.2))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("COACH ASSISTANT")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)

                    Text("ENTER DIETARY RESTRICTIONS SEPARATED BY COMMAS (E.G., DAIRY, GLUTEN, SHELLFISH).")
                        .font(SimplePalette.retroFont(size: 14, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(SimplePalette.cardBorder, lineWidth: 3)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SimplePalette.cardBackground)
                    )

                TextEditor(text: $dietaryInput)
                    .focused($isTextFocused)
                    .font(SimplePalette.retroFont(size: 16, weight: .medium))
                    .foregroundColor(SimplePalette.cardTextPrimary)
                    .padding(16)
                    .frame(minHeight: 140, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }

            if typingIndicator {
                HStack(spacing: 6) {
                    Text("ANALYZING DETAILS…")
                        .font(SimplePalette.retroFont(size: 13, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)

                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(SimplePalette.retroRed)
                        .scaleEffect(0.8)
                }
                .transition(.opacity)
            }
            
            // Confirm button
            Button(action: {
                restrictionsConfirmed = true
                isTextFocused = false
            }) {
                Text("CONFIRM")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(SimplePalette.retroWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(SimplePalette.retroBlack, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                    )
            }
            .buttonStyle(.plain)
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
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SimplePalette.retroWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(SimplePalette.retroBlack, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                    )
            }
            .buttonStyle(.plain)
            .opacity(canProceed ? 1 : 0.4)
            .disabled(!canProceed)
        }
    }

    @ViewBuilder
    private func capsuleButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(isSelected ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                .padding(.horizontal, 24)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? SimplePalette.retroRed : SimplePalette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(SimplePalette.retroBlack, lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                )
        }
        .buttonStyle(.plain)
    }

    private func select(_ option: Option) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            selectedOption = option
        }

        switch option {
        case .restrictions:
            triggerTypingIndicator()
            restrictionsConfirmed = false
        case .none:
            dietaryInput = ""
            onboardingData.dietaryInputRaw = ""
            onboardingData.dietaryRestrictions = []
            typingIndicator = false
            restrictionsConfirmed = false
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
        
        if let dietType = selectedDietType {
            onboardingData.dietType = dietType
        }
        
        // Don't generate plan here - wait for PlanGenerationView
        navigateToPlan = true
    }

    private func configureFromData() {
        dietaryInput = onboardingData.dietaryInputRaw
        
        // Only pre-load diet type if returning to edit existing restrictions
        if !onboardingData.dietaryRestrictions.isEmpty || !dietaryInput.isEmpty {
            selectedOption = .restrictions
            restrictionsConfirmed = true
            selectedDietType = onboardingData.dietType
        } else {
            // Fresh start - nothing pre-selected
            selectedOption = nil
            selectedDietType = nil
        }
    }
}

#Preview {
    NavigationStack {
        DietaryRestrictionsView()
    }
    .environmentObject(OnboardingData())
}


