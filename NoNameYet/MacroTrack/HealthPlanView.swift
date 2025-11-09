import SwiftUI

struct HealthPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    private var plan: HealthPlan? { onboardingData.generatedPlan }
    @State private var aiInput: String = ""
    @FocusState private var isTextFocused: Bool
    @State private var showConfirmation: Bool = false
    @State private var showAchievementNotification: Bool = false
    @State private var newlyUnlockedAchievements: [Int] = []
    @State private var isMenuOpen: Bool = false
    @State private var selectedDestination: MenuDestination?
    @State private var cardioComplete: Bool = false
    @State private var strengthComplete: Bool = false
    @State private var confirmationMessage: String = "Coach received your update"
    @State private var parsedPreview: OnboardingData.ParsedPreview?
    @State private var pendingInput: String = ""
    @State private var waterConsumedSlider: Int = 0
    @State private var showCoachInfoSheet: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            simpleBackground()

            SideMenuView(isOpen: $isMenuOpen) { destination in
                selectedDestination = destination
            }
            .offset(x: isMenuOpen ? 0 : -280)

            mainContent
                .offset(x: isMenuOpen ? 280 : 0)
                .onTapGesture {
                    if isMenuOpen {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isMenuOpen = false
                        }
                    }
                }

            alertToast
            
            achievementNotification
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isMenuOpen)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showConfirmation)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAchievementNotification)
        .sheet(item: $selectedDestination) { destination in
            NavigationStack {
                destinationView(for: destination)
            }
        }
        .sheet(item: $parsedPreview) { preview in
            confirmationSheet(preview: preview)
        }
        .sheet(isPresented: $showCoachInfoSheet) {
            CoachInfoSheet()
        }
        .navigationBarBackButtonHidden(true)
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 20) {
                header

                topUtilities
                    .padding(.top, 8)

                ScrollView {
                    if let plan {
                        planContentBody(plan)
                    } else {
                        missingPlanPlaceholder
                    }
                }
                .onAppear {
                    loadCompletionStatus()
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: MenuDestination) -> some View {
        switch destination {
        case .workout:
            WorkoutSectionView()
        case .nutrition:
            NutritionSectionView()
        case .calendar:
            CalendarSectionView()
        case .data:
            DataSectionView()
        case .achievements:
            AchievementsSectionView()
        case .weight:
            WeightSectionView()
        case .settings:
            SettingsSectionView()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isMenuOpen.toggle()
                }
            }) {
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

            VStack(alignment: .leading, spacing: 4) {
                Text("YOUR HEALTH PLAN")
                    .font(SimplePalette.retroFont(size: 28, weight: .bold))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text(tagline.uppercased())
                    .font(SimplePalette.retroFont(size: 15, weight: .medium))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
        }
    }

    private func planContentBody(_ plan: HealthPlan) -> some View {
        VStack(alignment: .leading, spacing: 26) {
            coachNotesSection

            summarySection(plan: plan)
            
            weeklyAchievementsSection
        }
    }

    private var coachNotesSection: some View {
        VStack(spacing: 16) {
            SimpleCardPane {
                VStack(alignment: .leading, spacing: 18) {
                    Text("COACH NOTES")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)

                    loggingBox
                }
                .simpleCardPadding()
            }

            Button(action: submitInput) {
                HStack(spacing: 10) {
                    Text("SUBMIT TO COACH")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.retroWhite)

                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.retroWhite)
                }
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
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
    }

    private var topUtilities: some View {
        HStack(alignment: .center, spacing: 16) {
            Button(action: {
                showCoachInfoSheet = true
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(width: 58, height: 58)
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

            Spacer()

            Button(action: {
                // Barcode scanner - API to be added later
            }) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .frame(width: 48, height: 48)
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
        }
        .padding(.horizontal, 4)
    }

    private var loggingBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                TextEditor(text: $aiInput)
                    .focused($isTextFocused)
                    .font(SimplePalette.retroFont(size: 16, weight: .medium))
                    .foregroundColor(SimplePalette.cardTextPrimary)
                    .padding(18)
                    .frame(minHeight: 160, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .autocorrectionDisabled(false)
            }

        }
    }

    private func summarySection(plan: HealthPlan) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            sectionPane(title: "Today's Workout", trailingButton: {
                    Button(action: {
                        selectedDestination = .workout
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
            }) {
                VStack(alignment: .leading, spacing: 16) {
                    let workouts = onboardingData.workoutsArray(for: Date())
                    
                    if workouts.isEmpty {
                        // Fallback to old system if no workouts
                        workoutRowWithCompletion(
                            icon: "figure.run",
                            title: "Cardio",
                            detail: cardioSummary(for: plan),
                            isComplete: $cardioComplete
                        )
                        Divider().background(SimplePalette.cardBorder)
                        workoutRowWithCompletion(
                            icon: "dumbbell",
                            title: "Strength",
                            detail: strengthSummary(for: plan),
                            isComplete: $strengthComplete
                        )
                    } else {
                        ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
                            if index > 0 {
                                Divider().background(SimplePalette.cardBorder)
                            }
                            
                            switch workout.type {
                            case .cardio:
                                if let cardio = workout.cardio {
                                    workoutRowWithCompletion(
                                        icon: "figure.run",
                                        title: "Cardio",
                                        detail: cardioWorkoutDetail(cardio),
                                        isComplete: Binding(
                                            get: { workout.isComplete },
                                            set: { newValue in
                                                var updatedWorkout = workout
                                                updatedWorkout.isComplete = newValue
                                                onboardingData.updateWorkout(at: index, workout: updatedWorkout, for: Date())
                                            }
                                        )
                                    )
                                }
                            case .strength:
                                if let strength = workout.strength {
                                    workoutRowWithCompletion(
                                        icon: "dumbbell",
                                        title: "Strength",
                                        detail: strengthWorkoutDetail(strength),
                                        isComplete: Binding(
                                            get: { workout.isComplete },
                                            set: { newValue in
                                                var updatedWorkout = workout
                                                updatedWorkout.isComplete = newValue
                                                onboardingData.updateWorkout(at: index, workout: updatedWorkout, for: Date())
                                            }
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }
        

            sectionPane(title: "Daily Nutrition Targets") {
                nutritionTotalsGrid(plan.macroTargets)
            }

            sectionPane(title: "Hydration") {
                hydrationSection(plan: plan)
            }
        }
    }
    
    private var weeklyAchievementsSection: some View {
        let earnedAchievements = Array(onboardingData.earnedAchievements).sorted(by: >).prefix(4)
        
        return sectionPane(title: "Weekly Achievements") {
            if earnedAchievements.isEmpty {
                Text("NO ACHIEVEMENTS EARNED YET")
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                HStack(spacing: 16) {
                    ForEach(earnedAchievements, id: \.self) { achievementId in
                        VStack(spacing: 8) {
                            SpinningCoinView(isLocked: false, icon: achievementIcon(for: achievementId))
                            Text(achievementName(for: achievementId))
                                .font(SimplePalette.retroFont(size: 10, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func sectionPane<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 18) {
                Text(title)
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                content()
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 28)
        }
    }
    
    private func sectionPane<Trailing: View, Content: View>(title: String, @ViewBuilder trailingButton: () -> Trailing, @ViewBuilder content: () -> Content) -> some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text(title)
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                    
                    Spacer()
                    
                    trailingButton()
                }
                .padding(.bottom, 4)

                content()
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 28)
        }
    }

    private var missingPlanPlaceholder: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                Text("Plan Not Ready")
                    .font(SimplePalette.retroFont(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                Text("Return to the previous step to finalize dietary preferences so we can generate your plan.")
                    .font(SimplePalette.retroFont(size: 15, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
            .simpleCardPadding()
        }
    }

    private func workoutRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(SimplePalette.accentLight)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle().stroke(SimplePalette.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SimplePalette.accentBlue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text(detail)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
        }
    }

    private func workoutRowWithCompletion(icon: String, title: String, detail: String, isComplete: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(SimplePalette.accentLight)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle().stroke(SimplePalette.cardBorder, lineWidth: 2)
                )
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(SimplePalette.retroFont(size: 15, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                Text(detail)
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }

            Spacer()

            AnimatedCheckmarkButton(isChecked: isComplete) {
                saveCompletionStatus()
            }
        }
    }

    private func cardioSummary(for plan: HealthPlan) -> String {
        let workouts = onboardingData.workouts(for: Date())
        let cardio = workouts.cardio
        let distanceText = cardio.distance.map { String(format: "%.1f mi", $0) } ?? ""
        let parts = [cardio.type.rawValue, "\(cardio.duration) min", distanceText].filter { !$0.isEmpty }
        return parts.joined(separator: " • ")
    }

    private func strengthSummary(for plan: HealthPlan) -> String {
        let workouts = onboardingData.workouts(for: Date())
        let strength = workouts.strength
        return "\(strength.exercise.rawValue) • \(strength.sets) sets × \(strength.reps) reps"
    }
    
    private func cardioWorkoutDetail(_ cardio: CardioWorkout) -> String {
        let distanceText = cardio.distance.map { String(format: "%.1f mi", $0) } ?? ""
        let parts = [cardio.type.rawValue, "\(cardio.duration) min", distanceText].filter { !$0.isEmpty }
        return parts.joined(separator: " • ")
    }
    
    private func strengthWorkoutDetail(_ strength: StrengthWorkout) -> String {
        return "\(strength.exercise.rawValue) • \(strength.sets) sets × \(strength.reps) reps"
    }

    private func loadCompletionStatus() {
        let today = Date()
        if let completion = onboardingData.completion(for: today) {
            cardioComplete = completion.cardioComplete
            strengthComplete = completion.strengthComplete
        } else {
            cardioComplete = false
            strengthComplete = false
        }
    }

    private func saveCompletionStatus() {
        guard let plan = onboardingData.generatedPlan else { return }
        let today = Date()
        
        let foodLog = onboardingData.completion(for: today)?.foodLog ?? []
        let consumed = foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        let existing = onboardingData.completion(for: today)
        let workouts = onboardingData.workouts(for: today)
        
        let completion = DayCompletion(
            cardioComplete: cardioComplete,
            strengthComplete: strengthComplete,
            caloriesConsumed: consumed.calories,
            proteinConsumed: consumed.protein,
            caloriesTarget: plan.macroTargets.calories,
            proteinTarget: plan.macroTargets.protein,
            foodLog: foodLog,
            otherLiquids: existing?.otherLiquids ?? [],
            plannedCardio: existing?.plannedCardio ?? workouts.cardio,
            plannedStrength: existing?.plannedStrength ?? workouts.strength,
            plannedWorkouts: existing?.plannedWorkouts ?? [],
            waterConsumed: existing?.waterConsumed ?? 0,
            waterTarget: plan.waterIntakeOz
        )
        
        onboardingData.updateCompletion(for: today, completion: completion)
    }

    private func nutritionTotalsGrid(_ macros: MacroBreakdown) -> some View {
        let todayFoodLog = onboardingData.foodLog(for: Date())
        let consumed = todayFoodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                macroChip(label: "Calories", consumed: consumed.calories, target: macros.calories, unit: "kcal")
                macroChip(label: "Protein", consumed: consumed.protein, target: macros.protein, unit: "g")
            }

            HStack(spacing: 12) {
                macroChip(label: "Carbs", consumed: consumed.carbs, target: macros.carbs, unit: "g")
                macroChip(label: "Fat", consumed: consumed.fat, target: macros.fat, unit: "g")
            }
            
            HStack(spacing: 12) {
                macroChip(label: "Sugar", consumed: consumed.sugar, target: macros.sugar, unit: "g")
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func macroChip(label: String, consumed: Int, target: Int, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 12, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)

            HStack(spacing: 4) {
                Text("\(consumed)")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(consumed > target ? SimplePalette.retroRed : SimplePalette.cardTextPrimary)

                Text("/")
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)

                Text("\(target) \(unit)")
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(SimplePalette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(SimplePalette.cardBorder, lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
        )
    }

    private func hydrationSection(plan: HealthPlan) -> some View {
        let today = Date()
        let waterConsumed = onboardingData.waterIntake(for: today)
        let waterTarget = plan.waterIntakeOz
        let currentWater = waterConsumedSlider > 0 ? waterConsumedSlider : waterConsumed

        return VStack(alignment: .leading, spacing: 16) {
            // Progress display with slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("WATER INTAKE")
                        .font(SimplePalette.retroFont(size: 15, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)

                    Spacer()

                    Text("\(currentWater) / \(waterTarget) OZ")
                        .font(SimplePalette.retroFont(size: 15, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)

                    if currentWater >= waterTarget {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(SimplePalette.completionGreen)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(SimplePalette.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(SimplePalette.cardBorder, lineWidth: 2)
                            )

                        let progress = min(Double(currentWater) / Double(max(waterTarget, 1)), 1.0)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(currentWater >= waterTarget ? SimplePalette.completionGreen : SimplePalette.waterBlue)
                            .frame(width: geo.size.width * progress)
                        
                        // Slidable water droplet
                        HStack {
                            Spacer()
                            Image(systemName: "drop.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(SimplePalette.waterBlue)
                                .offset(x: -geo.size.width * (1.0 - progress))
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let progress = max(0, min(1, value.location.x / geo.size.width))
                                let newWater = Int(Double(waterTarget) * progress)
                                waterConsumedSlider = newWater
                                onboardingData.setWaterIntake(newWater, for: today)
                            }
                            .onEnded { _ in
                                // Keep the value synced
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    waterConsumedSlider = onboardingData.waterIntake(for: today)
                                }
                            }
                    )
                }
                .frame(height: 24)
            }

            Divider().background(SimplePalette.cardBorder)

            // Quick add buttons
            VStack(alignment: .leading, spacing: 8) {
                Text("QUICK ADD")
                    .font(SimplePalette.retroFont(size: 13, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)

                HStack(spacing: 10) {
                    waterQuickAddButton(amount: 8, label: "8OZ")
                    waterQuickAddButton(amount: 16, label: "16OZ")
                    waterQuickAddButton(amount: 24, label: "24OZ")
                    waterQuickAddButton(amount: 32, label: "32OZ")
                }
            }
        }
        .onAppear {
            waterConsumedSlider = onboardingData.waterIntake(for: today)
        }
    }
    
    private func waterQuickAddButton(amount: Int, label: String) -> some View {
        Button(action: {
            let today = Date()
            onboardingData.addWaterIntake(amount, for: today)
            waterConsumedSlider = onboardingData.waterIntake(for: today)
        }) {
            Text(label)
                .font(SimplePalette.retroFont(size: 14, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
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
    }

    private var tagline: String {
        let name = onboardingData.username.isEmpty ? "Client" : onboardingData.username
        var components: [String] = []
        
        components.append("Built for \(name)")
        
        if let age = onboardingData.age {
            components.append("Age \(age)")
        }
        
        if let weight = onboardingData.weight {
            let weightStr = onboardingData.weightUnit == .pounds ? "\(weight) lbs" : "\(weight) kg"
            components.append(weightStr)
        }
        
        let heightStr = formatHeight()
        if !heightStr.isEmpty {
            components.append(heightStr)
        }
        
        return components.joined(separator: " • ")
    }
    
    private func formatHeight() -> String {
        let data = onboardingData
        if data.heightUnit == .imperial {
            if let feet = data.heightFeet, let inches = data.heightInches {
                return "\(feet)'\(inches)\""
            }
        } else {
            if let cm = data.heightCentimeters {
                return "\(cm) cm"
            }
        }
        return ""
    }


    private func submitInput() {
        let input = aiInput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !input.isEmpty else {
            isTextFocused = true
            return
        }

        // Parse first to show preview
        onboardingData.parseCoachInputPreview(input) { preview in
            if preview.hasContent {
                // Show confirmation sheet
                pendingInput = input
                parsedPreview = preview
                aiInput = ""
                isTextFocused = false
            } else {
                // No content parsed, show error
                confirmationMessage = "Could not parse any food, water, or workouts from your input."
                showConfirmation = true
                aiInput = ""
                isTextFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showConfirmation = false
                }
            }
        }
    }

    private var alertToast: some View {
        Group {
            if showConfirmation {
                Text(confirmationMessage)
                    .font(SimplePalette.retroFont(size: 14, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(SimplePalette.retroWhite)
                            .overlay(
                                Capsule().stroke(SimplePalette.retroBlack, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                    )
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var achievementNotification: some View {
        Group {
            if showAchievementNotification, let firstAchievement = newlyUnlockedAchievements.first {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        StaticAchievementIcon(icon: achievementIcon(for: firstAchievement), isLocked: false)
                            .scaleEffect(0.8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ACHIEVEMENT UNLOCKED!")
                                .font(SimplePalette.retroFont(size: 12, weight: .bold))
                                .foregroundStyle(SimplePalette.retroRed)
                            
                            Text(achievementName(for: firstAchievement))
                                .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                .foregroundStyle(SimplePalette.retroBlack)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(SimplePalette.retroWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(SimplePalette.retroBlack, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.5), radius: 0, x: 5, y: 5)
                    )
                }
                .padding(.bottom, 100)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func achievementIcon(for id: Int) -> String {
        switch id {
        case 1...10: return "ruler"
        case 11...20: return "calendar.badge.checkmark"
        case 21...30: return "scalemass"
        case 31...40: return "flame"
        case 41...50: return "figure.run"
        case 51...60: return "drop.fill"
        default: return "star.fill"
        }
    }
    
    private func achievementName(for id: Int) -> String {
        return AchievementsSectionView.achievements.first(where: { $0.id == id })?.name ?? "ACHIEVEMENT \(id)"
    }
    
    private func confirmationSheet(preview: OnboardingData.ParsedPreview) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Confirm Entry")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)
                Spacer()
                Button(action: {
                    parsedPreview = nil
                    pendingInput = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(SimplePalette.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
                .background(SimplePalette.cardBorder)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date
                    Text("Date: \(preview.dateString)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)
                    
                    // Foods
                    if !preview.foods.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Foods:")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(SimplePalette.textPrimary)
                            
                            ForEach(Array(preview.foods.enumerated()), id: \.offset) { _, item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextPrimary)
                                        Text("\(item.macros.calories) CAL • \(item.macros.protein)G PROTEIN • \(item.macros.carbs)G CARBS")
                                            .font(SimplePalette.retroFont(size: 13, weight: .medium))
                                            .foregroundStyle(SimplePalette.cardTextSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(SimplePalette.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(SimplePalette.cardBorder, lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    
                    // Water
                    if let water = preview.water {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Water:")
                                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextPrimary)
                            Text("\(water) OZ")
                                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextSecondary)
                        }
                    }
                    
                    // Workouts
                    if !preview.workouts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Workouts:")
                                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextPrimary)
                            
                            ForEach(Array(preview.workouts.enumerated()), id: \.offset) { _, workout in
                                HStack {
                                    Text(workout.description)
                                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextPrimary)
                                    Spacer()
                                    Text(workout.type.uppercased())
                                        .font(SimplePalette.retroFont(size: 14, weight: .medium))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(SimplePalette.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(SimplePalette.cardBorder, lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            
            Divider()
                .background(SimplePalette.cardBorder)
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    parsedPreview = nil
                    pendingInput = ""
                }) {
                    Text("Cancel")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(SimplePalette.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(SimplePalette.cardBorder, lineWidth: 1)
                                )
                        )
                }
                
                Button(action: {
                    // Actually log the items
                    onboardingData.parseAndLogCoachInput(pendingInput) { success, message, foodsLogged, waterLogged, newAchievements in
                        confirmationMessage = message
                        showConfirmation = true
                        
                        parsedPreview = nil
                        pendingInput = ""
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showConfirmation = false
                        }
                        
                        // Show achievement unlock notification if any new achievements
                        if !newAchievements.isEmpty {
                            newlyUnlockedAchievements = newAchievements
                            showAchievementNotification = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                showAchievementNotification = false
                                newlyUnlockedAchievements = []
                            }
                        }
                    }
                }) {
                    Text("Confirm")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.retroBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(SimplePalette.retroRed)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(SimplePalette.retroBlack, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(SimplePalette.background)
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Animated Checkmark Button

private struct AnimatedCheckmarkButton: View {
    @Binding var isChecked: Bool
    let onTap: () -> Void
    @State private var scale: CGFloat = 1.0
    
    init(isChecked: Binding<Bool>, onTap: @escaping () -> Void) {
        self._isChecked = isChecked
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isChecked.toggle()
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            onTap()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(isChecked ? SimplePalette.retroRed : Color.clear)
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(SimplePalette.retroBlack, lineWidth: 3)
                    )
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroBlack)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
        .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
    }
}

// MARK: - Coach Info Sheet

private struct CoachInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("COACH NOTES EXPLAINED")
                                    .font(SimplePalette.retroFont(size: 20, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextPrimary)
                                
                                Text("The Coach Notes box allows you to log food, water intake, and workouts using natural language. Simply type what you ate, drank, or did, and the coach will parse and log it automatically.")
                                    .font(SimplePalette.retroFont(size: 16, weight: .medium))
                                    .foregroundStyle(SimplePalette.cardTextSecondary)
                                
                                Text("EXAMPLES:")
                                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextPrimary)
                                    .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    exampleText("• Ate grilled chicken breast and rice")
                                    exampleText("• Drank 16 oz of water")
                                    exampleText("• Ran 3 miles in 30 minutes")
                                    exampleText("• Did 3 sets of 12 squats")
                                }
                            }
                            .simpleCardPadding()
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Coach Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.retroRed)
                }
            }
        }
    }
    
    private func exampleText(_ text: String) -> some View {
        Text(text)
            .font(SimplePalette.retroFont(size: 14, weight: .medium))
            .foregroundStyle(SimplePalette.cardTextSecondary)
    }
}

#Preview {
    NavigationStack {
        HealthPlanView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.username = "Jordan"
        data.age = 31
        data.goals = [1, 3]
        data.dietaryRestrictions = ["gluten", "shellfish"]
        data.generatePlaceholderPlan()
        return data
    }())
}


