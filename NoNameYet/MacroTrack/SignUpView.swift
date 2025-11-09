import SwiftUI

private enum SignUpField: Int, CaseIterable {
    case username
    case gender
    case age
    case weight
    case height
}

private enum ActivePicker: Identifiable {
    case height

    var id: Int { hashValue }
}

struct SignUpView: View {

    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var username = ""
    @State private var gender: Gender?
    @State private var visibleFieldCount: Int = 1
    @State private var navigateToFitnessSetup = false

    @State private var ageText: String = ""
    @State private var ageConfirmed = false

    @State private var weightText: String = ""
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
            simpleBackground()

            VStack {
                SimpleCardPane {
                    VStack(alignment: .center, spacing: 32) {
                        Text("SIGN UP")
                            .font(SimplePalette.retroFont(size: 32, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(SimplePalette.cardTextPrimary)

                        VStack(spacing: 24) {
                            capsuleField(
                                placeholder: "USERNAME",
                                text: $username,
                                field: .username,
                                keyboardType: .default
                            )

                            if isFieldVisible(.gender) {
                                genderSelector
                            }

                            if isFieldVisible(.age) {
                                ageInputField
                            }

                            if isFieldVisible(.weight) {
                                weightInputField
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
                    .simpleCardPadding()
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)

                Spacer(minLength: 0)

                if isFormComplete {
                    bottomArrow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear(perform: configureFromOnboardingData)
        .sheet(item: $activePicker) { picker in
            switch picker {
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

    private var isFormComplete: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        gender != nil &&
        ageConfirmed &&
        weightConfirmed &&
        heightConfirmed
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
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(
                            Capsule()
                                .fill(SimplePalette.cardBackground)
                                .overlay(
                                    Capsule()
                                        .stroke(SimplePalette.cardBorder, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
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
        visibleFieldCount = max(visibleFieldCount, SignUpField.gender.rawValue + 1)
        focusedField = nil
    }
    
    private var ageInputField: some View {
        CapsuleTextField(
            placeholder: "AGE",
            text: $ageText,
            focusedField: _focusedField,
            field: .age,
            keyboardType: .numberPad,
            submitAction: { handleAgeSubmit() }
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.25), value: visibleFieldCount)
        .onChange(of: ageText) { newValue in
            // Auto-advance to weight field after 2 digits
            if newValue.count == 2, let ageValue = Int(newValue), ageValue >= 13 && ageValue <= 100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    handleAgeSubmit()
                    focusedField = .weight
                }
            }
        }
    }
    
    private var weightInputField: some View {
        VStack(spacing: 12) {
            CapsuleTextField(
                placeholder: "WEIGHT",
                text: $weightText,
                focusedField: _focusedField,
                field: .weight,
                keyboardType: .decimalPad,
                submitAction: { handleWeightSubmit() }
            )
            
            if !weightText.isEmpty {
                HStack(spacing: 12) {
                    ForEach(WeightUnit.allCases) { unit in
                        Button(action: {
                            weightUnit = unit
                            handleWeightSubmit()
                        }) {
                            Text(unit.shortLabel.uppercased())
                                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                .foregroundStyle(weightUnit == unit ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(weightUnit == unit ? SimplePalette.retroRed : SimplePalette.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(SimplePalette.retroBlack, lineWidth: 3)
                                        )
                                        .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.25), value: visibleFieldCount)
    }
    
    private func handleAgeSubmit() {
        guard let ageValue = Int(ageText.trimmingCharacters(in: .whitespaces)),
              ageValue >= 13 && ageValue <= 100 else {
            return
        }
        ageConfirmed = true
        onboardingData.age = ageValue
        visibleFieldCount = max(visibleFieldCount, SignUpField.weight.rawValue + 1)
        focusedField = nil
    }
    
    private func handleWeightSubmit() {
        guard let weightValue = Double(weightText.trimmingCharacters(in: .whitespaces)),
              weightValue > 0 else {
            return
        }
        let intWeight = Int(weightValue.rounded())
        let clampedWeight = weightUnit == .pounds 
            ? max(80, min(400, intWeight))
            : max(36, min(180, intWeight))
        
        weightConfirmed = true
        onboardingData.weight = clampedWeight
        onboardingData.weightUnit = weightUnit
        visibleFieldCount = max(visibleFieldCount, SignUpField.height.rawValue + 1)
        focusedField = nil
        presentNextIfNeeded(.height)
    }
    
    private var genderSelector: some View {
        HStack(spacing: 12) {
            ForEach(Gender.allCases.filter { $0 != .other }) { genderOption in
                Button(action: {
                    gender = genderOption
                    onboardingData.gender = genderOption
                    visibleFieldCount = max(visibleFieldCount, SignUpField.age.rawValue + 1)
                }) {
                    Text(genderOption.rawValue.uppercased())
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(gender == genderOption ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            Capsule()
                                .fill(gender == genderOption ? SimplePalette.retroRed : SimplePalette.cardBackground)
                                .overlay(
                                    Capsule()
                                        .stroke(SimplePalette.retroBlack, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.25), value: visibleFieldCount)
    }

    private func dismissPicker() {
        activePicker = nil
    }

    private func presentNextIfNeeded(_ picker: ActivePicker) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if case .height = picker, !heightConfirmed {
                activePicker = .height
            }
        }
    }

    private var bottomArrow: some View {
        HStack {
            Spacer()
            Button(action: { navigateToFitnessSetup = true }) {
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
            .opacity(isFormComplete ? 1 : 0.4)
            .disabled(!isFormComplete)
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
                .fill(SimplePalette.cardBackground)
                .frame(height: 72)
                .overlay(
                    Capsule()
                        .stroke(SimplePalette.cardBorder, lineWidth: 1)
                )

            if text.isEmpty {
                Text(placeholder)
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                    .allowsHitTesting(false)
            }

            TextField("", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
                .focused($focusedField, equals: field)
                .submitLabel(.next)
                .multilineTextAlignment(.center)
                .foregroundStyle(SimplePalette.cardTextPrimary)
                .font(SimplePalette.retroFont(size: 18, weight: .bold))
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
            visibleFieldCount = max(visibleFieldCount, SignUpField.gender.rawValue + 1)
        }

        if let storedGender = onboardingData.gender {
            gender = storedGender
            visibleFieldCount = max(visibleFieldCount, SignUpField.age.rawValue + 1)
        }

        if let storedAge = onboardingData.age {
            ageText = "\(storedAge)"
            ageConfirmed = true
            visibleFieldCount = max(visibleFieldCount, SignUpField.weight.rawValue + 1)
        }

        if let storedWeight = onboardingData.weight {
            weightText = "\(storedWeight)"
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

// MARK: - Retro Picker Component

private struct RetroPicker<Value: Hashable & Comparable>: View where Value: Strideable, Value.Stride: SignedInteger {
    @Binding var selection: Value
    let range: ClosedRange<Value>
    let format: (Value) -> String
    
    private let itemHeight: CGFloat = 50
    
    var body: some View {
        GeometryReader { geometry in
            let centerY = geometry.size.height / 2
            let selectedIndex = index(for: selection)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SimplePalette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(SimplePalette.cardBorder, lineWidth: 2)
                    )
                
                // Selection indicator
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SimplePalette.retroRed.opacity(0.3))
                    .frame(height: itemHeight)
                    .offset(y: 0)
                
                // Items
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(range.enumerated()), id: \.element) { index, value in
                                pickerItem(value: value, isSelected: value == selection)
                                    .id(index)
                                    .frame(height: itemHeight)
                            }
                        }
                        .padding(.vertical, centerY - itemHeight / 2)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(selectedIndex, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: selection) { newValue in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            proxy.scrollTo(index(for: newValue), anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    private func pickerItem(value: Value, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selection = value
            }
        }) {
            Text(format(value))
                .font(SimplePalette.retroFont(size: isSelected ? 20 : 16, weight: .bold))
                .foregroundStyle(isSelected ? SimplePalette.retroBlack : SimplePalette.cardTextSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: itemHeight)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isSelected ? SimplePalette.retroRed : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(isSelected ? SimplePalette.retroBlack : Color.clear, lineWidth: 2)
                        )
                        .shadow(color: isSelected ? Color.black.opacity(0.3) : Color.clear, radius: 0, x: 2, y: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func index(for value: Value) -> Int {
        let array = Array(range)
        return array.firstIndex(of: value) ?? 0
    }
}

// MARK: - Picker Sheets

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
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                SimpleCardPane {
                    VStack(spacing: 24) {
                        Text("SELECT AGE")
                            .font(SimplePalette.retroFont(size: 24, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        
                        RetroPicker(
                            selection: $localAge,
                            range: 13...100,
                            format: { "\($0)" }
                        )
                        .frame(height: 200)
                        
                        HStack(spacing: 16) {
                            Button(action: onCancel) {
                                Text("CANCEL")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.retroBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
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
                            
                            Button(action: { onDone(localAge) }) {
                                Text("DONE")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.retroBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(SimplePalette.retroRed)
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
                    .simpleCardPadding()
                }
                .padding(.horizontal, 40)
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
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                SimpleCardPane {
                    VStack(spacing: 24) {
                        Text("SELECT WEIGHT")
                            .font(SimplePalette.retroFont(size: 24, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        
                        // Unit selector
                        HStack(spacing: 12) {
                            ForEach(WeightUnit.allCases) { unit in
                                Button(action: {
                                    let converted = convert(weight: localWeight, from: previousUnit, to: unit)
                                    localWeight = min(max(converted, unit.range.lowerBound), unit.range.upperBound)
                                    previousUnit = localUnit
                                    localUnit = unit
                                }) {
                                    Text(unit.shortLabel.uppercased())
                                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                        .foregroundStyle(localUnit == unit ? SimplePalette.retroWhite : SimplePalette.retroBlack)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(localUnit == unit ? SimplePalette.retroRed : SimplePalette.retroWhite)
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
                        
                        RetroPicker(
                            selection: $localWeight,
                            range: localUnit.range,
                            format: { "\($0) \(localUnit.shortLabel.uppercased())" }
                        )
                        .frame(height: 200)
                        
                        HStack(spacing: 16) {
                            Button(action: onCancel) {
                                Text("CANCEL")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.retroBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
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
                            
                            Button(action: { onDone(localWeight, localUnit) }) {
                                Text("DONE")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.retroBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(SimplePalette.retroRed)
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
                    .simpleCardPadding()
                }
                .padding(.horizontal, 40)
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
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                SimpleCardPane {
                    VStack(spacing: 24) {
                        Text("SELECT HEIGHT")
                            .font(SimplePalette.retroFont(size: 24, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        
                        // Unit selector
                        HStack(spacing: 12) {
                            ForEach(HeightUnit.allCases) { unit in
                                Button(action: {
                                    switch unit {
                                    case .imperial:
                                        let converted = Self.imperialValues(fromCentimeters: localCentimeters)
                                        localFeet = converted.feet
                                        localInches = converted.inches
                                    case .metric:
                                        localCentimeters = Self.centimeters(feet: localFeet, inches: localInches)
                                    }
                                    localUnit = unit
                                }) {
                                    Text(unit.shortLabel.uppercased())
                                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                        .foregroundStyle(localUnit == unit ? SimplePalette.retroWhite : SimplePalette.retroBlack)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(localUnit == unit ? SimplePalette.retroRed : SimplePalette.retroWhite)
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
                        
                        if localUnit == .imperial {
                            HStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    Text("FEET")
                                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                    
                                    RetroPicker(
                                        selection: $localFeet,
                                        range: 4...7,
                                        format: { "\($0) FT" }
                                    )
                                    .frame(height: 150)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("INCHES")
                                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                    
                                    RetroPicker(
                                        selection: $localInches,
                                        range: 0...11,
                                        format: { "\($0) IN" }
                                    )
                                    .frame(height: 150)
                                }
                            }
                        } else {
                            VStack(spacing: 8) {
                                Text("CENTIMETERS")
                                    .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextSecondary)
                                
                                RetroPicker(
                                    selection: $localCentimeters,
                                    range: 120...220,
                                    format: { "\($0) CM" }
                                )
                                .frame(height: 200)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: onCancel) {
                                Text("CANCEL")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.retroBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
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
                            
                            Button(action: {
                                if localUnit == .imperial {
                                    let centimeters = Self.centimeters(feet: localFeet, inches: localInches)
                                    onDone(localUnit, localFeet, localInches, centimeters)
                                } else {
                                    let (feet, inches) = Self.imperialValues(fromCentimeters: localCentimeters)
                                    onDone(localUnit, feet, inches, localCentimeters)
                                }
                            }) {
                                Text("DONE")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.retroBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(SimplePalette.retroRed)
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
                    .simpleCardPadding()
                }
                .padding(.horizontal, 40)
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

