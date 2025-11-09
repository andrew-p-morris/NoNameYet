import SwiftUI

struct PlanGenerationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var bmr: Double = 0
    @State private var tdee: Double = 0
    @State private var adjustedCalories: Int = 0
    @State private var protein: Int = 0
    @State private var carbs: Int = 0
    @State private var fat: Int = 0
    @State private var sugar: Int = 0
    @State private var water: Int = 0
    @State private var navigateToHealthPlan = false
    @State private var isCalculating = false
    @State private var isEditing = false
    @State private var editableCalories: String = ""
    @State private var editableProtein: String = ""
    @State private var editableCarbs: String = ""
    @State private var editableFat: String = ""
    @State private var editableSugar: String = ""
    @State private var editableWater: String = ""

    var body: some View {
        ZStack {
            simpleBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    SimpleCardPane {
                        VStack(alignment: .leading, spacing: 24) {
                            if isCalculating {
                                calculatingView
                            } else if bmr > 0 {
                                planDetailsView
                            } else {
                                emptyStateView
                            }
                        }
                        .padding(.vertical, 24)
                        .simpleCardPadding()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            calculatePlan()
        }
        .navigationDestination(isPresented: $navigateToHealthPlan) {
            HealthPlanView()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(width: 44, height: 44)
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

            Text("RECOMMENDED HEALTH PLAN")
                .font(SimplePalette.retroFont(size: 26, weight: .bold))
                .foregroundStyle(SimplePalette.textPrimary)
        }
    }

    private var calculatingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(SimplePalette.retroRed)
                .scaleEffect(1.5)

            Text("CALCULATING YOUR PERSONALIZED PLAN…")
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(SimplePalette.retroRed)

            Text("READY TO GENERATE YOUR PLAN")
                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            Text("TAP BELOW TO CALCULATE YOUR PERSONALIZED NUTRITION AND WORKOUT TARGETS")
                .font(SimplePalette.retroFont(size: 14, weight: .medium))
                .foregroundStyle(SimplePalette.cardTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func metricRow(label: String, value: String, unit: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 16)

            HStack(spacing: 4) {
                Text(value)
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(unit.uppercased())
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
    }
    
    private func editableMetricRow(label: String, value: Binding<String>, unit: String, isReadOnly: Bool = false) -> some View {
        HStack {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 16)

            HStack(spacing: 4) {
                if isReadOnly {
                    Text(value.wrappedValue)
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                    TextField("", text: value)
                        .keyboardType(.numberPad)
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(SimplePalette.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(SimplePalette.cardBorder, lineWidth: 2)
                                )
                        )
                }

                Text(unit.uppercased())
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
    }

    private var planDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // BMR and TDEE
            VStack(alignment: .leading, spacing: 12) {
                Text("METABOLISM")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                    .padding(.bottom, 4)

                metricRow(label: "BMR", value: "\(Int(bmr.rounded()))", unit: "kcal/day")
                metricRow(label: "TDEE", value: "\(Int(tdee.rounded()))", unit: "kcal/day")
            }

            Divider()
                .background(SimplePalette.cardBorder)
                .padding(.vertical, 8)

            // Calories
            VStack(alignment: .leading, spacing: 12) {
                Text("DAILY CALORIES")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                    .padding(.bottom, 4)

                if isEditing {
                    editableMetricRow(label: "Target", value: $editableCalories, unit: "kcal")
                } else {
                    metricRow(label: "Target", value: "\(adjustedCalories)", unit: "kcal")
                }
            }

            Divider()
                .background(SimplePalette.cardBorder)
                .padding(.vertical, 8)

            // Macros
            VStack(alignment: .leading, spacing: 12) {
                Text("MACRONUTRIENTS")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                    .padding(.bottom, 4)

                if isEditing {
                    editableMetricRow(label: "Protein", value: $editableProtein, unit: "g")
                    editableMetricRow(label: "Carbs", value: $editableCarbs, unit: "g")
                    editableMetricRow(label: "Fat", value: $editableFat, unit: "g")
                    editableMetricRow(label: "Sugar", value: $editableSugar, unit: "g")
                } else {
                    metricRow(label: "Protein", value: "\(protein)", unit: "g")
                    metricRow(label: "Carbs", value: "\(carbs)", unit: "g")
                    metricRow(label: "Fat", value: "\(fat)", unit: "g")
                    metricRow(label: "Sugar", value: "\(sugar)", unit: "g")
                }
            }

            Divider()
                .background(SimplePalette.cardBorder)
                .padding(.vertical, 8)

            // Water
            VStack(alignment: .leading, spacing: 12) {
                Text("HYDRATION")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                    .padding(.bottom, 4)

                if isEditing {
                    editableMetricRow(label: "Water", value: $editableWater, unit: "oz/day")
                } else {
                    metricRow(label: "Water", value: "\(water)", unit: "oz/day")
                }
            }
            
            // Generate Plan Button
            Divider()
                .background(SimplePalette.cardBorder)
                .padding(.vertical, 8)
            
            if isEditing {
                editModeButtons
            } else {
                actionButtons
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { startEditing() }) {
                Text("EDIT PLAN")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
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
            
            Button(action: generateAndNavigate) {
                Text("GENERATE PLAN")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
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
        .padding(.top, 8)
    }
    
    private var editModeButtons: some View {
        HStack(spacing: 16) {
            Button(action: { cancelEditing() }) {
                Text("CANCEL")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
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
            
            Button(action: { saveEdits() }) {
                Text("SAVE")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
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
        .padding(.top, 8)
    }

    private func calculatePlan() {
        guard let age = onboardingData.age,
              let weight = onboardingData.weight,
              let gender = onboardingData.gender,
              let activityLevel = onboardingData.activityLevel else {
            return
        }

        isCalculating = true

        // Convert weight to kg
        let weightKg: Double = {
            if onboardingData.weightUnit == .kilograms {
                return Double(weight)
            } else {
                return Double(weight) / 2.20462
            }
        }()

        // Convert height to cm
        let heightCm: Double = {
            if onboardingData.heightUnit == .metric {
                return Double(onboardingData.heightCentimeters ?? 173)
            } else {
                let feet = onboardingData.heightFeet ?? 5
                let inches = onboardingData.heightInches ?? 8
                return Double(HeightUnit.centimeters(feet: feet, inches: inches))
            }
        }()

        // Calculate BMR
        let calculatedBMR = onboardingData.calculateBMR(weightKg: weightKg, heightCm: heightCm, age: age, gender: gender)

        // Calculate TDEE
        let calculatedTDEE = calculatedBMR * activityLevel.multiplier

        // Adjust calories based on goals
        var adjusted = calculatedTDEE
        let goalLabels = onboardingData.goals.map { onboardingData.goalDescription(for: $0) }
        let hasWeightLoss = goalLabels.contains { $0.contains("Lose Weight") || $0.contains("Burn Fat") }
        let hasMuscleGain = goalLabels.contains { $0.contains("Build Muscle") || $0.contains("Gain Strength") }

        if hasWeightLoss {
            // Use 15-20% deficit, but cap at 500 calories max
            let deficitPercent = 0.17 // ~17% average
            let maxDeficit = 500.0
            let calculatedDeficit = min(calculatedTDEE * deficitPercent, maxDeficit)
            adjusted = calculatedTDEE - calculatedDeficit
            
            // Ensure minimum is BMR + 100 (for basic metabolic function)
            let minCalories = calculatedBMR + 100
            adjusted = max(adjusted, minCalories)
        } else if hasMuscleGain {
            // Use 10-15% surplus, capped at 400 calories max
            let surplusPercent = 0.12 // ~12% average
            let maxSurplus = 400.0
            let calculatedSurplus = min(calculatedTDEE * surplusPercent, maxSurplus)
            adjusted = calculatedTDEE + calculatedSurplus
            
            // Ensure minimum is BMR + 100 (for basic metabolic function)
            adjusted = max(adjusted, calculatedBMR + 100)
        } else {
            // Maintenance: ensure minimum is BMR + 100
            adjusted = max(calculatedTDEE, calculatedBMR + 100)
        }

        // Universal minimum: BMR + 100, with 1200 as absolute hard floor
        let universalMin = max(Int((calculatedBMR + 100).rounded()), 1200)
        let calories = clamp(Int(adjusted.rounded()), lower: universalMin, upper: 4000)

        // Calculate macros using diet type ratios
        let diet = onboardingData.dietType ?? .balanced
        
        // Convert percentages to calories
        let proteinCalories = Double(calories) * diet.proteinRatio
        let fatCalories = Double(calories) * diet.fatRatio
        let carbCalories = Double(calories) * diet.carbRatio
        
        // Convert calories to grams (protein/carbs: 4 cal/g, fat: 9 cal/g)
        let calculatedProtein = clamp(Int(proteinCalories / 4.0), lower: 60, upper: 250)
        let calculatedFat = clamp(Int(fatCalories / 9.0), lower: 40, upper: 150)
        let calculatedCarbs = max(0, Int(carbCalories / 4.0))

        let calculatedSugar = max(20, min(100, Int(Double(calories) * 0.10 / 4.0)))

        let waterMl = weightKg * 33
        let waterOz = Int((waterMl / 29.5735).rounded())
        let calculatedWater = max(50, min(150, waterOz))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.bmr = calculatedBMR
            self.tdee = calculatedTDEE
            self.adjustedCalories = calories
            self.protein = calculatedProtein
            self.carbs = calculatedCarbs
            self.fat = calculatedFat
            self.sugar = calculatedSugar
            self.water = calculatedWater
            self.isCalculating = false
            
            // Initialize editable values
            self.editableCalories = "\(calories)"
            self.editableProtein = "\(calculatedProtein)"
            self.editableCarbs = "\(calculatedCarbs)"
            self.editableFat = "\(calculatedFat)"
            self.editableSugar = "\(calculatedSugar)"
            self.editableWater = "\(calculatedWater)"
        }
    }
    
    private func startEditing() {
        isEditing = true
    }
    
    private func cancelEditing() {
        isEditing = false
        // Reset to original values
        editableCalories = "\(adjustedCalories)"
        editableProtein = "\(protein)"
        editableCarbs = "\(carbs)"
        editableFat = "\(fat)"
        editableSugar = "\(sugar)"
        editableWater = "\(water)"
    }
    
    private func saveEdits() {
        // Update values from editable strings
        if let caloriesValue = Int(editableCalories), caloriesValue > 0 {
            adjustedCalories = caloriesValue
        }
        if let proteinValue = Int(editableProtein), proteinValue > 0 {
            protein = proteinValue
        }
        if let carbsValue = Int(editableCarbs), carbsValue >= 0 {
            carbs = carbsValue
        }
        if let fatValue = Int(editableFat), fatValue > 0 {
            fat = fatValue
        }
        if let sugarValue = Int(editableSugar), sugarValue >= 0 {
            sugar = sugarValue
        }
        if let waterValue = Int(editableWater), waterValue > 0 {
            water = waterValue
        }
        
        isEditing = false
    }

    private func generateAndNavigate() {
        // Use edited values if available, otherwise generate from scratch
        if adjustedCalories > 0 && protein > 0 {
            // Create plan with current (potentially edited) values
            let goalLabels = onboardingData.goals.map { onboardingData.goalDescription(for: $0) }
            let cardio = onboardingData.generateCardioWorkout(for: goalLabels)
            let strength = onboardingData.generateStrengthWorkout(for: goalLabels)
            
            let focusNotes: String = {
                if goalLabels.isEmpty {
                    return "Balance cardio capacity and total-body strength for sustainable progress."
                } else {
                    return "Emphasis on \(goalLabels.joined(separator: ", ")) while maintaining overall conditioning."
                }
            }()
            
            onboardingData.generatedPlan = HealthPlan(
                cardio: cardio,
                strength: strength,
                macroTargets: MacroBreakdown(calories: adjustedCalories, protein: protein, carbs: carbs, sugar: sugar, fat: fat),
                waterIntakeOz: water,
                focusNotes: focusNotes,
                goalHighlights: goalLabels,
                dietaryHighlights: onboardingData.dietaryRestrictions
            )
        } else {
            // Fallback to generating from scratch
            onboardingData.generatePlanWithMifflinStJeor()
        }
        navigateToHealthPlan = true
    }
    
    private func clamp(_ value: Int, lower: Int, upper: Int) -> Int {
        max(lower, min(upper, value))
    }
}

#Preview {
    NavigationStack {
        PlanGenerationView()
    }
    .environmentObject(OnboardingData())
}

