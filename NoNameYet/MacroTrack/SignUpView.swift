import SwiftUI

private enum SignUpField: Int, CaseIterable {
    case username
    case age
    case weight
    case height
}

private enum ActivePicker: Identifiable {
    case age
    case weight
    case height

    var id: Int { hashValue }
}

struct SignUpView: View {

    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var username = ""
    @State private var visibleFieldCount: Int = 1
    @State private var navigateToFitnessSetup = false

    @State private var age: Int = 25
    @State private var ageConfirmed = false

    @State private var weight: Int = 160
    @State private var weightUnit: WeightUnit = .pounds
    @State private var weightConfirmed = false

    @State private var heightUnit: HeightUnit = .imperial
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 8
    @State private var heightCentimeters: Int = 173
    @State private var heightConfirmed = false

    @State private var activePicker: ActivePicker?

    @FocusState private var focusedField: SignUpField?

    var body: some View {
        ZStack {
            liquidGlassBackground()

            VStack {
                LiquidGlassPane {
                    VStack(alignment: .center, spacing: 32) {
                        Text("Sign Up")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(LiquidGlassPalette.textPrimary)

                        VStack(spacing: 24) {
                            capsuleField(
                                placeholder: "USERNAME",
                                text: $username,
                                field: .username,
                                keyboardType: .default
                            )

                            if isFieldVisible(.age) {
                                capsuleSelector(
                                    label: ageConfirmed ? "Age: \(age)" : "AGE",
                                    action: { activePicker = .age }
                                )
                            }

                            if isFieldVisible(.weight) {
                                let valueText = weightConfirmed ? "Weight: \(weight) \(weightUnit.shortLabel.uppercased())" : "Weight"
                                capsuleSelector(
                                    label: valueText,
                                    action: { activePicker = .weight }
                                )
                            }

                            if isFieldVisible(.height) {
                                let heightText: String = {
                                    guard heightConfirmed else { return "Height" }
                                    switch heightUnit {
                                    case .imperial:
                                        return "Height: \(heightFeet)'\(heightInches)\""
                                    case .metric:
                                        return "Height: \(heightCentimeters) CM"
                                    }
                                }()

                                capsuleSelector(
                                    label: heightText,
                                    action: { activePicker = .height }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 40)
                    .liquidGlassPanePadding()
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)

                Spacer(minLength: 0)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear(perform: configureFromOnboardingData)
        .sheet(item: $activePicker) { picker in
            switch picker {
            case .age:
                AgePickerSheet(age: age, onCancel: dismissPicker, onDone: { newAge in
                    age = newAge
                    ageConfirmed = true
                    onboardingData.age = newAge
                    visibleFieldCount = max(visibleFieldCount, SignUpField.weight.rawValue + 1)
                    dismissPicker()
                    presentNextIfNeeded(.weight)
                })
            case .weight:
                WeightPickerSheet(weight: weight, unit: weightUnit, onCancel: dismissPicker, onDone: { newWeight, newUnit in
                    weight = newWeight
                    weightUnit = newUnit
                    weightConfirmed = true
                    onboardingData.weight = newWeight
                    onboardingData.weightUnit = newUnit
                    visibleFieldCount = max(visibleFieldCount, SignUpField.height.rawValue + 1)
                    dismissPicker()
                    presentNextIfNeeded(.height)
                })
            case .height:
                HeightPickerSheet(
                    unit: heightUnit,
                    feet: heightFeet,
                    inches: heightInches,
                    centimeters: heightCentimeters,
                    onCancel: dismissPicker,
                    onDone: { newUnit, newFeet, newInches, newCentimeters in
                        heightUnit = newUnit
                        heightFeet = newFeet
                        heightInches = newInches
                        heightCentimeters = newCentimeters
                        heightConfirmed = true
                        onboardingData.heightUnit = newUnit
                        onboardingData.heightFeet = newFeet
                        onboardingData.heightInches = newInches
                        onboardingData.heightCentimeters = newCentimeters
                        visibleFieldCount = max(visibleFieldCount, SignUpField.height.rawValue + 1)
                        dismissPicker()
                        navigateToFitnessSetup = true
                    }
                )
            }
        }
        .navigationDestination(isPresented: $navigateToFitnessSetup) {
            FitnessGoalsView()
        }
    }

    private func isFieldVisible(_ field: SignUpField) -> Bool {
        field.rawValue < visibleFieldCount
    }

    @ViewBuilder
    private func capsuleField(
        placeholder: String,
        text: Binding<String>,
        field: SignUpField,
        keyboardType: UIKeyboardType
    ) -> some View {
        CapsuleTextField(
            placeholder: placeholder,
            text: text,
            focusedField: _focusedField,
            field: field,
            keyboardType: keyboardType,
            submitAction: { handleSubmit(for: field) }
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.25), value: visibleFieldCount)
    }

    private func capsuleSelector(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label.uppercased())
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(LiquidGlassPalette.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(LiquidGlassPalette.glassBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.25), value: visibleFieldCount)
    }

    private func handleSubmit(for field: SignUpField) {
        guard field == .username else { return }

        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            focusedField = .username
            return
        }

        onboardingData.username = trimmed
        visibleFieldCount = max(visibleFieldCount, SignUpField.age.rawValue + 1)
        focusedField = nil
        presentNextIfNeeded(.age)
    }

    private func dismissPicker() {
        activePicker = nil
    }

    private func presentNextIfNeeded(_ picker: ActivePicker) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            switch picker {
            case .age:
                if !ageConfirmed {
                    activePicker = .age
                }
            case .weight:
                if !weightConfirmed {
                    activePicker = .weight
                }
            case .height:
                if !heightConfirmed {
                    activePicker = .height
                }
            }
        }
    }
}

private struct CapsuleTextField: View {
    let placeholder: String
    @Binding var text: String

    @FocusState var focusedField: SignUpField?
    var field: SignUpField
    var keyboardType: UIKeyboardType
    var submitAction: () -> Void

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 72)
                .overlay(
                    Capsule()
                        .stroke(LiquidGlassPalette.glassBorder, lineWidth: 1)
                )

            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(LiquidGlassPalette.textSecondary)
                    .allowsHitTesting(false)
            }

            TextField("", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
                .focused($focusedField, equals: field)
                .submitLabel(.next)
                .multilineTextAlignment(.center)
                .foregroundStyle(LiquidGlassPalette.textPrimary)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .padding(.horizontal, 24)
                .onSubmit(submitAction)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers

extension SignUpView {
    private func configureFromOnboardingData() {
        if !onboardingData.username.isEmpty {
            username = onboardingData.username
            visibleFieldCount = max(visibleFieldCount, SignUpField.age.rawValue + 1)
        }

        if let storedAge = onboardingData.age {
            age = storedAge
            ageConfirmed = true
            visibleFieldCount = max(visibleFieldCount, SignUpField.weight.rawValue + 1)
        }

        if let storedWeight = onboardingData.weight {
            weight = storedWeight
            weightUnit = onboardingData.weightUnit
            weightConfirmed = true
            visibleFieldCount = max(visibleFieldCount, SignUpField.height.rawValue + 1)
        }

        if let storedFeet = onboardingData.heightFeet,
           let storedInches = onboardingData.heightInches,
           let storedCentimeters = onboardingData.heightCentimeters {
            heightFeet = storedFeet
            heightInches = storedInches
            heightCentimeters = storedCentimeters
            heightUnit = onboardingData.heightUnit
            heightConfirmed = true
        }

        focusedField = .username
    }
}

private struct AgePickerSheet: View {
    @State private var localAge: Int

    let onCancel: () -> Void
    let onDone: (Int) -> Void

    init(age: Int, onCancel: @escaping () -> Void, onDone: @escaping (Int) -> Void) {
        _localAge = State(initialValue: age)
        self.onCancel = onCancel
        self.onDone = onDone
    }

    var body: some View {
        NavigationStack {
            Picker("Age", selection: $localAge) {
                ForEach(13...100, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Select Age")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onDone(localAge) }
                }
            }
        }
    }
}

private struct WeightPickerSheet: View {
    @State private var localWeight: Int
    @State private var localUnit: WeightUnit
    @State private var previousUnit: WeightUnit

    let onCancel: () -> Void
    let onDone: (Int, WeightUnit) -> Void

    init(weight: Int, unit: WeightUnit, onCancel: @escaping () -> Void, onDone: @escaping (Int, WeightUnit) -> Void) {
        _localWeight = State(initialValue: weight)
        _localUnit = State(initialValue: unit)
        _previousUnit = State(initialValue: unit)
        self.onCancel = onCancel
        self.onDone = onDone
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Unit", selection: $localUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Weight", selection: $localWeight) {
                    ForEach(localUnit.range, id: \.self) { value in
                        Text("\(value) \(localUnit.shortLabel)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
            }
            .padding()
            .navigationTitle("Select Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onDone(localWeight, localUnit) }
                }
            }
            .onChange(of: localUnit) { newUnit in
                let converted = convert(weight: localWeight, from: previousUnit, to: newUnit)
                localWeight = min(max(converted, newUnit.range.lowerBound), newUnit.range.upperBound)
                previousUnit = newUnit
            }
        }
    }

    private func convert(weight: Int, from: WeightUnit, to: WeightUnit) -> Int {
        guard from != to else { return weight }

        let poundsValue: Double
        switch from {
        case .pounds:
            poundsValue = Double(weight)
        case .kilograms:
            poundsValue = Double(weight) * 2.20462
        }

        let converted: Double
        switch to {
        case .pounds:
            converted = poundsValue
        case .kilograms:
            converted = poundsValue / 2.20462
        }

        return Int(converted.rounded())
    }
}

private struct HeightPickerSheet: View {
    @State private var localUnit: HeightUnit
    @State private var localFeet: Int
    @State private var localInches: Int
    @State private var localCentimeters: Int

    let onCancel: () -> Void
    let onDone: (HeightUnit, Int, Int, Int) -> Void

    init(
        unit: HeightUnit,
        feet: Int,
        inches: Int,
        centimeters: Int,
        onCancel: @escaping () -> Void,
        onDone: @escaping (HeightUnit, Int, Int, Int) -> Void
    ) {
        _localUnit = State(initialValue: unit)
        _localFeet = State(initialValue: feet)
        _localInches = State(initialValue: inches)
        _localCentimeters = State(initialValue: centimeters)
        self.onCancel = onCancel
        self.onDone = onDone
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Unit", selection: $localUnit) {
                    ForEach(HeightUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)

                if localUnit == .imperial {
                    HStack(spacing: 16) {
                        Picker("Feet", selection: $localFeet) {
                            ForEach(4...7, id: \.self) { value in
                                Text("\(value) ft").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Inches", selection: $localInches) {
                            ForEach(0...11, id: \.self) { value in
                                Text("\(value) in").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                } else {
                    Picker("Centimeters", selection: $localCentimeters) {
                        ForEach(120...220, id: \.self) { value in
                            Text("\(value) cm").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .padding()
            .navigationTitle("Select Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if localUnit == .imperial {
                            let centimeters = Self.centimeters(feet: localFeet, inches: localInches)
                            onDone(localUnit, localFeet, localInches, centimeters)
                        } else {
                            let (feet, inches) = Self.imperialValues(fromCentimeters: localCentimeters)
                            onDone(localUnit, feet, inches, localCentimeters)
                        }
                    }
                }
            }
            .onChange(of: localUnit) { newUnit in
                switch newUnit {
                case .imperial:
                    let converted = Self.imperialValues(fromCentimeters: localCentimeters)
                    localFeet = converted.feet
                    localInches = converted.inches
                case .metric:
                    localCentimeters = Self.centimeters(feet: localFeet, inches: localInches)
                }
            }
        }
    }

    private static func centimeters(feet: Int, inches: Int) -> Int {
        let totalInches = feet * 12 + inches
        return Int((Double(totalInches) * 2.54).rounded())
    }

    private static func imperialValues(fromCentimeters cm: Int) -> (feet: Int, inches: Int) {
        let totalInches = Int((Double(cm) / 2.54).rounded())
        let feet = totalInches / 12
        let inches = totalInches % 12
        return (max(4, min(7, feet)), max(0, min(11, inches)))
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
    .environmentObject(OnboardingData())
}

