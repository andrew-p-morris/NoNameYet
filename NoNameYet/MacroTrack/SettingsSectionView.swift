import SwiftUI

struct SettingsSectionView: View {
    @EnvironmentObject private var onboardingData: OnboardingData
    @Environment(\.dismiss) private var dismiss
    @State private var showEditProfile = false
    @State private var showClearDataAlert = false
    @State private var showRegenerateAlert = false
    
    var body: some View {
        ZStack {
            simpleBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("SETTINGS")
                        .font(SimplePalette.retroFont(size: 28, weight: .bold))
                        .foregroundStyle(SimplePalette.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    // Profile Section
                    settingsSection(title: "Profile") {
                        settingsRow(
                            icon: "person.circle",
                            title: "Edit Profile",
                            subtitle: profileSummary,
                            action: { showEditProfile = true }
                        )
                        
                        Divider().background(SimplePalette.cardBorder)
                        
                        settingsRow(
                            icon: "scalemass",
                            title: "Weight Unit",
                            subtitle: onboardingData.weightUnit.displayName,
                            action: {
                                onboardingData.weightUnit = onboardingData.weightUnit == .pounds ? .kilograms : .pounds
                                if onboardingData.generatedPlan != nil {
                                    onboardingData.generatePlaceholderPlan()
                                }
                            }
                        )
                        
                        Divider().background(SimplePalette.cardBorder)
                        
                        settingsRow(
                            icon: "ruler",
                            title: "Height Unit",
                            subtitle: onboardingData.heightUnit.displayName,
                            action: {
                                onboardingData.heightUnit = onboardingData.heightUnit == .imperial ? .metric : .imperial
                            }
                        )
                    }
                    
                    // Health Plan Section
                    settingsSection(title: "Health Plan") {
                        settingsRow(
                            icon: "arrow.clockwise",
                            title: "Regenerate Plan",
                            subtitle: "Create a new health plan",
                            action: { showRegenerateAlert = true }
                        )
                    }
                    
                    // Device Integration Section
                    settingsSection(title: "Device Integration") {
                        settingsRow(
                            icon: "applewatch",
                            title: "Connect Apple Watch",
                            subtitle: "Sync with Apple Watch",
                            action: {
                                // Logic to be added later
                            }
                        )
                    }
                    
                    // Data Management Section
                    settingsSection(title: "Data") {
                        settingsRow(
                            icon: "trash",
                            title: "Clear All Data",
                            subtitle: "Reset all logs and data",
                            action: { showClearDataAlert = true },
                            isDestructive: true
                        )
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
                .environmentObject(onboardingData)
        }
        .alert("Clear All Data", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will delete all your food logs, workout data, and completion history. This action cannot be undone.")
        }
        .alert("Regenerate Plan", isPresented: $showRegenerateAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Regenerate", role: .destructive) {
                regeneratePlan()
            }
        } message: {
            Text("This will create a new health plan based on your current profile. Your existing logs will be preserved.")
        }
    }
    
    private var profileSummary: String {
        var parts: [String] = []
        if !onboardingData.username.isEmpty {
            parts.append(onboardingData.username)
        }
        if let age = onboardingData.age {
            parts.append("Age \(age)")
        }
        if let weight = onboardingData.weight {
            parts.append("\(weight) \(onboardingData.weightUnit.shortLabel)")
        }
        return parts.isEmpty ? "Tap to edit" : parts.joined(separator: " • ")
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 0) {
                Text(title.uppercased())
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                    .padding(.bottom, 16)
                
                content()
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void,
        isDestructive: Bool = false
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isDestructive ? SimplePalette.retroRed : SimplePalette.retroRed)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(isDestructive ? SimplePalette.retroRed : SimplePalette.cardTextPrimary)
                    
                    Text(subtitle.uppercased())
                        .font(SimplePalette.retroFont(size: 14, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    private func clearAllData() {
        onboardingData.todaysFoodLog = []
        onboardingData.dailyCompletions = [:]
        onboardingData.generatedPlan = nil
    }
    
    private func regeneratePlan() {
        onboardingData.generatePlaceholderPlan()
    }
}

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData
    
    @State private var username: String = ""
    @State private var age: Int = 25
    @State private var weight: Int = 160
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 8
    @State private var heightCentimeters: Int = 173
    @State private var weightUnit: WeightUnit = .pounds
    @State private var heightUnit: HeightUnit = .imperial
    @State private var showAgePicker = false
    @State private var showWeightPicker = false
    @State private var showHeightPicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Username
                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("NAME")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextSecondary)
                                
                                TextField("ENTER YOUR NAME", text: $username)
                                    .textFieldStyle(.plain)
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(SimplePalette.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(SimplePalette.cardBorder, lineWidth: 2)
                                            )
                                    )
                            }
                            .simpleCardPadding()
                        }
                        .padding(.horizontal, 24)
                        
                        // Age
                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("AGE")
                                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextSecondary)
                                
                                Button(action: { showAgePicker = true }) {
                                    HStack {
                                        Text("\(age) YEARS")
                                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .simpleCardPadding()
                        }
                        .padding(.horizontal, 24)
                        
                        // Weight
                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("WEIGHT")
                                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $weightUnit) {
                                        ForEach(WeightUnit.allCases) { unit in
                                            Text(unit.shortLabel.uppercased()).tag(unit)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 120)
                                    .tint(SimplePalette.retroBlack)
                                }
                                
                                Button(action: { showWeightPicker = true }) {
                                    HStack {
                                        Text("\(weight) \(weightUnit.shortLabel.uppercased())")
                                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .simpleCardPadding()
                        }
                        .padding(.horizontal, 24)
                        
                        // Height
                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("HEIGHT")
                                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $heightUnit) {
                                        ForEach(HeightUnit.allCases) { unit in
                                            Text(unit.shortLabel.uppercased()).tag(unit)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 150)
                                    .tint(SimplePalette.retroBlack)
                                }
                                
                                Button(action: { showHeightPicker = true }) {
                                    HStack {
                                        Text(heightDisplay.uppercased())
                                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .simpleCardPadding()
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadCurrentValues()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAgePicker) {
                AgePickerSheet(age: $age)
            }
            .sheet(isPresented: $showWeightPicker) {
                WeightPickerSheet(weight: $weight, unit: $weightUnit)
            }
            .sheet(isPresented: $showHeightPicker) {
                SettingsHeightPickerSheet(
                    unit: heightUnit,
                    feet: $heightFeet,
                    inches: $heightInches,
                    centimeters: $heightCentimeters,
                    onCancel: { showHeightPicker = false },
                    onDone: { newUnit, newFeet, newInches, newCentimeters in
                        heightUnit = newUnit
                        heightFeet = newFeet
                        heightInches = newInches
                        heightCentimeters = newCentimeters
                        showHeightPicker = false
                    }
                )
            }
        }
    }
    
    private var heightDisplay: String {
        if heightUnit == .imperial {
            return "\(heightFeet) ft \(heightInches) in"
        } else {
            return "\(heightCentimeters) cm"
        }
    }
    
    private func loadCurrentValues() {
        username = onboardingData.username
        age = onboardingData.age ?? 25
        weight = onboardingData.weight ?? 160
        weightUnit = onboardingData.weightUnit
        heightUnit = onboardingData.heightUnit
        heightFeet = onboardingData.heightFeet ?? 5
        heightInches = onboardingData.heightInches ?? 8
        heightCentimeters = onboardingData.heightCentimeters ?? 173
    }
    
    private func saveProfile() {
        onboardingData.username = username
        onboardingData.age = age
        onboardingData.weight = weight
        onboardingData.weightUnit = weightUnit
        onboardingData.heightUnit = heightUnit
        onboardingData.heightFeet = heightFeet
        onboardingData.heightInches = heightInches
        onboardingData.heightCentimeters = heightCentimeters
        
        // Regenerate plan if it exists to reflect new weight/age
        if onboardingData.generatedPlan != nil {
            onboardingData.generatePlaceholderPlan()
        }
    }
}

private struct AgePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var age: Int
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                VStack {
                    Picker("Age", selection: $age) {
                        ForEach(13...100, id: \.self) { ageValue in
                            Text("\(ageValue)").tag(ageValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 200)
                }
                .padding()
            }
            .navigationTitle("Age")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

private struct WeightPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var weight: Int
    @Binding var unit: WeightUnit
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                VStack {
                    Picker("Weight", selection: $weight) {
                        ForEach(Array(unit.range), id: \.self) { weightValue in
                            Text("\(weightValue) \(unit.shortLabel)").tag(weightValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 200)
                }
                .padding()
            }
            .navigationTitle("Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

private struct SettingsHeightPickerSheet: View {
    @State private var localUnit: HeightUnit
    @State private var localFeet: Int
    @State private var localInches: Int
    @State private var localCentimeters: Int
    
    let onCancel: () -> Void
    let onDone: (HeightUnit, Int, Int, Int) -> Void
    
    init(
        unit: HeightUnit,
        feet: Binding<Int>,
        inches: Binding<Int>,
        centimeters: Binding<Int>,
        onCancel: @escaping () -> Void,
        onDone: @escaping (HeightUnit, Int, Int, Int) -> Void
    ) {
        _localUnit = State(initialValue: unit)
        _localFeet = State(initialValue: feet.wrappedValue)
        _localInches = State(initialValue: inches.wrappedValue)
        _localCentimeters = State(initialValue: centimeters.wrappedValue)
        self.onCancel = onCancel
        self.onDone = onDone
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                VStack(spacing: 24) {
                    Picker("Unit", selection: $localUnit) {
                        ForEach(HeightUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
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
            }
            .navigationTitle("Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if localUnit == .imperial {
                            let cm = HeightUnit.centimeters(feet: localFeet, inches: localInches)
                            onDone(localUnit, localFeet, localInches, cm)
                        } else {
                            let (fe, inc) = HeightUnit.imperialValues(fromCentimeters: localCentimeters)
                            onDone(localUnit, fe, inc, localCentimeters)
                        }
                    }
                }
            }
            .onChange(of: localUnit) { newUnit in
                switch newUnit {
                case .imperial:
                    let converted = HeightUnit.imperialValues(fromCentimeters: localCentimeters)
                    localFeet = converted.feet
                    localInches = converted.inches
                case .metric:
                    localCentimeters = HeightUnit.centimeters(feet: localFeet, inches: localInches)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsSectionView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.username = "Drew"
        data.age = 27
        data.weight = 175
        data.generatePlaceholderPlan()
        return data
    }())
}

