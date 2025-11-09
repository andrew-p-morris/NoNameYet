import SwiftUI

// Import AnimatedCheckmarkButton from HealthPlanView
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

enum CalendarViewMode: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

struct CalendarSectionView: View {
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var viewMode: CalendarViewMode = .month
    @State private var selectedDate: Date = Date()
    @State private var showDayDetail: Date?
    @State private var drawerDate: Date?
    @State private var cardioComplete: Bool = false
    @State private var strengthComplete: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            simpleBackground()

            VStack(alignment: .leading, spacing: 20) {
                header

                SimpleCardPane {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            ForEach(CalendarViewMode.allCases) { mode in
                                Button(action: {
                                    withAnimation {
                                        viewMode = mode
                                    }
                                }) {
                                    Text(mode.rawValue.uppercased())
                                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                        .foregroundStyle(viewMode == mode ? SimplePalette.retroBlack : SimplePalette.cardTextPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(viewMode == mode ? SimplePalette.retroWhite : SimplePalette.cardBackground)
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

                        switch viewMode {
                        case .day:
                            dayView
                        case .week:
                            weekView
                        case .month:
                            monthView
                        }
                    }
                    .simpleCardPadding()
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 16)

            if let date = drawerDate {
                bottomDrawer(for: date)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: drawerDate)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Refresh calendar when view appears to reflect any changes made in workout/nutrition pages
            selectedDate = selectedDate // Trigger view refresh
        }
        .sheet(item: $showDayDetail) { date in
            DayDetailSheet(date: date)
                .environmentObject(onboardingData)
        }
        .onTapGesture {
            if drawerDate != nil {
                drawerDate = nil
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROGRESS TRACKER")
                .font(SimplePalette.retroFont(size: 28, weight: .bold))
                .foregroundStyle(SimplePalette.textPrimary)
                .padding(.horizontal, 24)

            Text("GREEN = COMPLETE • RED = MISSED • YELLOW = TODAY")
                .font(SimplePalette.retroFont(size: 14, weight: .medium))
                .foregroundStyle(SimplePalette.textSecondary)
                .padding(.horizontal, 24)
        }
    }

    private var dayView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dateLabel(for: selectedDate).uppercased())
                .font(SimplePalette.retroFont(size: 20, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            dayDetailInline(for: selectedDate)

            HStack(spacing: 16) {
                Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)! }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)! }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 60)
        }
    }

    private func dayDetailInline(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let plan = onboardingData.generatedPlan {
                workoutSection(for: date, plan: plan)
                macroProgressSection(for: date, plan: plan)
            } else {
                Text("NO PLAN AVAILABLE")
                    .font(SimplePalette.retroFont(size: 16, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
        }
    }

    private func workoutSection(for date: Date, plan: HealthPlan) -> some View {
        let workouts = onboardingData.workoutsArray(for: date)
        let completion = onboardingData.completion(for: date)
        
        // Check completion using new workout system
        let cardioWorkouts = workouts.filter { $0.type == .cardio }
        let strengthWorkouts = workouts.filter { $0.type == .strength }
        let cardioComplete = !cardioWorkouts.isEmpty && cardioWorkouts.allSatisfy { $0.isComplete } || (completion?.cardioComplete ?? false)
        let strengthComplete = !strengthWorkouts.isEmpty && strengthWorkouts.allSatisfy { $0.isComplete } || (completion?.strengthComplete ?? false)

        return VStack(alignment: .leading, spacing: 12) {
            Text("WORKOUT")
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)
            
            if !workouts.isEmpty {
                // Show all workouts from new system
                ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
                    if index > 0 {
                        Divider().background(SimplePalette.cardBorder)
                    }
                    
                    switch workout.type {
                    case .cardio:
                        if let cardio = workout.cardio {
                            HStack(spacing: 12) {
                                checkBox(isChecked: workout.isComplete)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("CARDIO")
                                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextPrimary)
                                    Text(cardioWorkoutDetail(cardio).uppercased())
                                        .font(SimplePalette.retroFont(size: 13, weight: .medium))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                }
                            }
                        }
                    case .strength:
                        if let strength = workout.strength {
                            HStack(spacing: 12) {
                                checkBox(isChecked: workout.isComplete)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("STRENGTH")
                                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextPrimary)
                                    Text(strengthWorkoutDetail(strength).uppercased())
                                        .font(SimplePalette.retroFont(size: 13, weight: .medium))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                }
                            }
                        }
                    }
                }
            } else {
                // Fallback to old system display
                HStack(spacing: 12) {
                    Button(action: {
                        let completion = onboardingData.completion(for: date)
                        let newCardioComplete = !(completion?.cardioComplete ?? false)
                        var updatedCompletion = completion ?? DayCompletion(
                            cardioComplete: false,
                            strengthComplete: false,
                            caloriesConsumed: 0,
                            proteinConsumed: 0,
                            caloriesTarget: plan.macroTargets.calories,
                            proteinTarget: plan.macroTargets.protein,
                            foodLog: [],
                            plannedCardio: nil,
                            plannedStrength: nil,
                            plannedWorkouts: [],
                            waterConsumed: 0,
                            waterTarget: plan.waterIntakeOz
                        )
                        updatedCompletion.cardioComplete = newCardioComplete
                        onboardingData.updateCompletion(for: date, completion: updatedCompletion)
                    }) {
                        checkBox(isChecked: cardioComplete)
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CARDIO")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        Text(cardioSummary(for: date).uppercased())
                            .font(SimplePalette.retroFont(size: 13, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                }

                HStack(spacing: 12) {
                    Button(action: {
                        let completion = onboardingData.completion(for: date)
                        let newStrengthComplete = !(completion?.strengthComplete ?? false)
                        var updatedCompletion = completion ?? DayCompletion(
                            cardioComplete: false,
                            strengthComplete: false,
                            caloriesConsumed: 0,
                            proteinConsumed: 0,
                            caloriesTarget: plan.macroTargets.calories,
                            proteinTarget: plan.macroTargets.protein,
                            foodLog: [],
                            plannedCardio: nil,
                            plannedStrength: nil,
                            plannedWorkouts: [],
                            waterConsumed: 0,
                            waterTarget: plan.waterIntakeOz
                        )
                        updatedCompletion.strengthComplete = newStrengthComplete
                        onboardingData.updateCompletion(for: date, completion: updatedCompletion)
                    }) {
                        checkBox(isChecked: strengthComplete)
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STRENGTH")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        Text(strengthSummary(for: date).uppercased())
                            .font(SimplePalette.retroFont(size: 13, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                }
            }

            // Removed EDIT COMPLETION button - checkboxes are enough
        }
        .padding(16)
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
    
    private func cardioWorkoutDetail(_ cardio: CardioWorkout) -> String {
        let distanceText = cardio.distance.map { String(format: "%.1f mi", $0) } ?? ""
        let parts = [cardio.type.rawValue, "\(cardio.duration) min", distanceText].filter { !$0.isEmpty }
        return parts.joined(separator: " • ")
    }
    
    private func strengthWorkoutDetail(_ strength: StrengthWorkout) -> String {
        return "\(strength.exercise.rawValue) • \(strength.sets) sets × \(strength.reps) reps"
    }

    private func macroProgressSection(for date: Date, plan: HealthPlan) -> some View {
        let completion = onboardingData.completion(for: date)
        let consumed = completion.map { comp in
            comp.foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
                MacroBreakdown(
                    calories: acc.calories + entry.macros.calories,
                    protein: acc.protein + entry.macros.protein,
                    carbs: acc.carbs + entry.macros.carbs,
                    sugar: acc.sugar + entry.macros.sugar,
                    fat: acc.fat + entry.macros.fat
                )
            }
        } ?? MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)

        return VStack(alignment: .leading, spacing: 12) {
            Text("MACRO PROGRESS")
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            progressBar(label: "Calories", consumed: consumed.calories, target: plan.macroTargets.calories, unit: "kcal")
            progressBar(label: "Protein", consumed: consumed.protein, target: plan.macroTargets.protein, unit: "g")
        }
        .padding(16)
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

    private func checkBox(isChecked: Bool) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .stroke(SimplePalette.retroBlack, lineWidth: 3)
            .frame(width: 24, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(isChecked ? SimplePalette.retroRed : Color.clear)
            )
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SimplePalette.retroBlack)
                    .opacity(isChecked ? 1 : 0)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
    }

    private func progressBar(label: String, consumed: Int, target: Int, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label.uppercased())
                    .font(SimplePalette.retroFont(size: 14, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                Spacer()

                Text("\(consumed) / \(target) \(unit.uppercased())")
                    .font(SimplePalette.retroFont(size: 13, weight: .bold))
                    .foregroundStyle(consumed >= target ? SimplePalette.completionGreen : SimplePalette.cardTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(SimplePalette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(SimplePalette.cardBorder, lineWidth: 2)
                        )

                    let progress = min(Double(consumed) / Double(max(target, 1)), 1.0)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(consumed >= target ? SimplePalette.completionGreen.opacity(0.7) : SimplePalette.retroRed)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 12)
        }
        .frame(height: 32)
    }

    private func cardioSummary(for date: Date) -> String {
        let workouts = onboardingData.workoutsArray(for: date)
        
        // If using new workout system, get cardio workouts
        let cardioWorkouts = workouts.filter { $0.type == .cardio }
        if !cardioWorkouts.isEmpty, let firstCardio = cardioWorkouts.first?.cardio {
            let distanceText = firstCardio.distance.map { String(format: "%.1f mi", $0) } ?? ""
            let parts = [firstCardio.type.rawValue, "\(firstCardio.duration) min", distanceText].filter { !$0.isEmpty }
            return parts.joined(separator: " • ")
        }
        
        // Fallback to old system
        let oldWorkouts = onboardingData.workouts(for: date)
        let cardio = oldWorkouts.cardio
        let distanceText = cardio.distance.map { String(format: "%.1f mi", $0) } ?? ""
        let parts = [cardio.type.rawValue, "\(cardio.duration) min", distanceText].filter { !$0.isEmpty }
        return parts.joined(separator: " • ")
    }

    private func strengthSummary(for date: Date) -> String {
        let workouts = onboardingData.workoutsArray(for: date)
        
        // If using new workout system, get strength workouts
        let strengthWorkouts = workouts.filter { $0.type == .strength }
        if !strengthWorkouts.isEmpty, let firstStrength = strengthWorkouts.first?.strength {
            return "\(firstStrength.exercise.rawValue) • \(firstStrength.sets) sets × \(firstStrength.reps) reps"
        }
        
        // Fallback to old system
        let oldWorkouts = onboardingData.workouts(for: date)
        let strength = oldWorkouts.strength
        return "\(strength.exercise.rawValue) • \(strength.sets) sets × \(strength.reps) reps"
    }

    private func bottomDrawer(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(shortDateLabel(for: date).uppercased())
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                Spacer()

                Button(action: { drawerDate = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                }
                .buttonStyle(.plain)
            }

            if let plan = onboardingData.generatedPlan {
                VStack(alignment: .leading, spacing: 14) {
                    Text("WORKOUT")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)

                    HStack(spacing: 12) {
                        AnimatedCheckmarkButton(isChecked: $cardioComplete) {
                            saveDrawerCompletion(for: date)
                        }
                        Text("CARDIO: \(cardioSummary(for: date).uppercased())")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                    }

                    HStack(spacing: 12) {
                        AnimatedCheckmarkButton(isChecked: $strengthComplete) {
                            saveDrawerCompletion(for: date)
                        }
                        Text("STRENGTH: \(strengthSummary(for: date).uppercased())")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                    }
                }

                Divider().background(SimplePalette.cardBorder)

                drawerMacroProgress(for: date, plan: plan)

                Button("SAVE CHANGES") {
                    saveDrawerCompletion(for: date)
                    drawerDate = nil
                }
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.retroBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
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
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(SimplePalette.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(SimplePalette.cardBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 20, y: -8)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    drawerDate = nil
                }
        )
    }

    private func drawerMacroProgress(for date: Date, plan: HealthPlan) -> some View {
        let completion = onboardingData.completion(for: date)
        let consumed = completion.map { comp in
            comp.foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
                MacroBreakdown(
                    calories: acc.calories + entry.macros.calories,
                    protein: acc.protein + entry.macros.protein,
                    carbs: acc.carbs + entry.macros.carbs,
                    sugar: acc.sugar + entry.macros.sugar,
                    fat: acc.fat + entry.macros.fat
                )
            }
        } ?? MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)

        return VStack(alignment: .leading, spacing: 10) {
            Text("MACRO PROGRESS")
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            compactProgressBar(label: "Calories", consumed: consumed.calories, target: plan.macroTargets.calories, unit: "kcal")
            compactProgressBar(label: "Protein", consumed: consumed.protein, target: plan.macroTargets.protein, unit: "g")
        }
    }

    private func compactProgressBar(label: String, consumed: Int, target: Int, unit: String) -> some View {
        HStack(spacing: 10) {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 13, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)
                .frame(width: 65, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(SimplePalette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(SimplePalette.cardBorder, lineWidth: 2)
                        )

                    let progress = min(Double(consumed) / Double(max(target, 1)), 1.0)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(consumed >= target ? SimplePalette.completionGreen : SimplePalette.retroRed)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 10)

            Text("\(consumed)/\(target)")
                .font(SimplePalette.retroFont(size: 12, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)
                .frame(width: 60, alignment: .trailing)
        }
        .frame(height: 20)
    }

    private func loadDrawerData(for date: Date) {
        if let completion = onboardingData.completion(for: date) {
            cardioComplete = completion.cardioComplete
            strengthComplete = completion.strengthComplete
        } else {
            cardioComplete = false
            strengthComplete = false
        }
    }

    private func saveDrawerCompletion(for date: Date) {
        guard let plan = onboardingData.generatedPlan else { return }

        let foodLog = onboardingData.completion(for: date)?.foodLog ?? []
        let consumed = foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }

        let existing = onboardingData.completion(for: date)
        
        // Update workout completion for new workout system
        var workouts = onboardingData.workoutsArray(for: date)
        if !workouts.isEmpty {
            // Update completion status for cardio and strength workouts
            for index in workouts.indices {
                if workouts[index].type == .cardio {
                    workouts[index].isComplete = cardioComplete
                } else if workouts[index].type == .strength {
                    workouts[index].isComplete = strengthComplete
                }
            }
            onboardingData.setWorkoutsArray(workouts, for: date)
            
            // Also update the old completion flags for backward compatibility
            var updatedCompletion = existing ?? DayCompletion(
                cardioComplete: cardioComplete,
                strengthComplete: strengthComplete,
                caloriesConsumed: consumed.calories,
                proteinConsumed: consumed.protein,
                caloriesTarget: plan.macroTargets.calories,
                proteinTarget: plan.macroTargets.protein,
                foodLog: foodLog,
                plannedWorkouts: workouts,
                waterConsumed: existing?.waterConsumed ?? 0,
                waterTarget: plan.waterIntakeOz
            )
            updatedCompletion.cardioComplete = cardioComplete
            updatedCompletion.strengthComplete = strengthComplete
            updatedCompletion.plannedWorkouts = workouts
            onboardingData.updateCompletion(for: date, completion: updatedCompletion)
        } else {
            // Old system
            let completion = DayCompletion(
                cardioComplete: cardioComplete,
                strengthComplete: strengthComplete,
                caloriesConsumed: consumed.calories,
                proteinConsumed: consumed.protein,
                caloriesTarget: plan.macroTargets.calories,
                proteinTarget: plan.macroTargets.protein,
                foodLog: foodLog,
                plannedCardio: existing?.plannedCardio,
                plannedStrength: existing?.plannedStrength,
                plannedWorkouts: [],
                waterConsumed: existing?.waterConsumed ?? 0,
                waterTarget: plan.waterIntakeOz
            )
            onboardingData.updateCompletion(for: date, completion: completion)
        }
    }

    private func shortDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var weekView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WEEK OF \(weekLabel(for: selectedDate).uppercased())")
                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            // Day headers
            HStack(spacing: 8) {
                ForEach(["M", "T", "W", "TH", "F", "S", "SU"], id: \.self) { dayHeader in
                    Text(dayHeader)
                        .font(SimplePalette.retroFont(size: 12, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            let weekDays = daysInWeek(for: selectedDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    VStack(spacing: 4) {
                        daySquare(for: day, size: 44)
                            .overlay(
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextPrimary)
                            )
                            .onTapGesture {
                                drawerDate = day
                                loadDrawerData(for: day)
                            }
                    }
                }
            }

            HStack(spacing: 16) {
                Button(action: { selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate)! }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate)! }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
        }
    }

    private var monthView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(monthLabel(for: selectedDate).uppercased())
                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            // Day headers
            HStack(spacing: 6) {
                ForEach(["M", "T", "W", "TH", "F", "S", "SU"], id: \.self) { dayHeader in
                    Text(dayHeader)
                        .font(SimplePalette.retroFont(size: 12, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            let monthDays = daysInMonth(for: selectedDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(monthDays, id: \.self) { day in
                    let isCurrentMonth = Calendar.current.isDate(day, equalTo: selectedDate, toGranularity: .month)
                    if isCurrentMonth {
                        daySquare(for: day, size: 40)
                            .overlay(
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .font(SimplePalette.retroFont(size: 12, weight: .bold))
                                    .foregroundStyle(SimplePalette.cardTextPrimary)
                            )
                            .onTapGesture {
                                drawerDate = day
                                loadDrawerData(for: day)
                            }
                    } else {
                        // Empty placeholder for days outside current month
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.clear)
                            .frame(width: 40, height: 40)
                    }
                }
            }

            HStack(spacing: 16) {
                Button(action: { selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)! }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)! }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
        }
    }

    private func daySquare(for date: Date, size: CGFloat) -> some View {
        let calendar = Calendar.current
        let today = Date()
        let isToday = calendar.isDate(date, inSameDayAs: today)
        
        // Normalize dates to start of day for comparison
        let startOfToday = calendar.startOfDay(for: today)
        let startOfDate = calendar.startOfDay(for: date)
        let isFuture = startOfDate > startOfToday
        
        let completion = onboardingData.completion(for: date)
        let isComplete = completion?.isFullyComplete ?? false
        
        // Check if either workout is marked complete
        let hasWorkoutData = completion != nil && (completion!.cardioComplete || completion!.strengthComplete)
        
        // Determine color based on date and completion status
        let color: Color = {
            if isToday {
                return SimplePalette.retroYellow.opacity(0.7) // Yellow for today
            } else if isFuture {
                // Future dates: neutral/background color (not red)
                return SimplePalette.background.opacity(0.8)
            } else if isComplete {
                return SimplePalette.completionGreen.opacity(0.7) // Green for complete
            } else if hasWorkoutData {
                // Has partial completion but not fully complete
                return SimplePalette.retroRed.opacity(0.5) // Red for partial/incomplete
            } else {
                return SimplePalette.background.opacity(0.8) // No data = neutral
            }
        }()
        
        let fillColor = color

        return RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(fillColor)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isToday ? SimplePalette.retroYellow : SimplePalette.cardBorder, lineWidth: isToday ? 3 : 1)
            )
    }

    private func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func weekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return formatter.string(from: start)
    }

    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dayOfWeekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func daysInWeek(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func daysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc.)
        let firstDayWeekday = calendar.component(.weekday, from: startOfMonth)
        // Convert to 0-based where Monday = 0 (adjusting for Sunday = 1)
        let firstDayOffset = (firstDayWeekday + 5) % 7 // Adjust so Monday = 0
        
        // Add empty days at the start to align with correct weekday
        var days: [Date] = []
        
        // Add empty placeholder dates for days before the first day of the month
        if firstDayOffset > 0 {
            let emptyDays = (0..<firstDayOffset).compactMap { offset in
                calendar.date(byAdding: .day, value: -(firstDayOffset - offset), to: startOfMonth)
            }
            days.append(contentsOf: emptyDays)
        }
        
        // Add actual month days
        let monthDays = range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
        days.append(contentsOf: monthDays)
        
        return days
    }
}

private struct DayDetailSheet: View, Identifiable {
    var id: Date { date }
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    let date: Date

    @State private var cardioComplete: Bool = false
    @State private var strengthComplete: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if let plan = onboardingData.generatedPlan {
                            SimpleCardPane {
                                VStack(alignment: .leading, spacing: 18) {
                                    Text("WORKOUT COMPLETION")
                                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                                        .foregroundStyle(SimplePalette.cardTextPrimary)

                                    HStack(spacing: 12) {
                                        AnimatedCheckmarkButton(isChecked: $cardioComplete) {
                                            saveCompletion()
                                        }
                                        Text("CARDIO")
                                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextPrimary)
                                    }

                                    HStack(spacing: 12) {
                                        AnimatedCheckmarkButton(isChecked: $strengthComplete) {
                                            saveCompletion()
                                        }
                                        Text("STRENGTH")
                                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                            .foregroundStyle(SimplePalette.cardTextPrimary)
                                    }
                                }
                                .simpleCardPadding()
                            }

                            SimpleCardPane {
                                macroProgress(plan: plan)
                                    .simpleCardPadding()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(shortDateLabel(for: date).uppercased())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("DONE") {
                        dismiss()
                    }
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.retroRed)
                }
            }
            .onAppear(perform: loadCompletion)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private func macroProgress(plan: HealthPlan) -> some View {
        let foodLog = onboardingData.completion(for: date)?.foodLog ?? []
        let consumed = foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }

        return VStack(alignment: .leading, spacing: 18) {
            Text("MACRO PROGRESS")
                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            progressBar(label: "Calories", consumed: consumed.calories, target: plan.macroTargets.calories, unit: "kcal")
            progressBar(label: "Protein", consumed: consumed.protein, target: plan.macroTargets.protein, unit: "g")
        }
    }

    private func progressBar(label: String, consumed: Int, target: Int, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label.uppercased())
                    .font(SimplePalette.retroFont(size: 14, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                Spacer()

                Text("\(consumed) / \(target) \(unit.uppercased())")
                    .font(SimplePalette.retroFont(size: 13, weight: .bold))
                    .foregroundStyle(consumed >= target ? SimplePalette.completionGreen : SimplePalette.cardTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(SimplePalette.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(SimplePalette.cardBorder, lineWidth: 2)
                        )

                    let progress = min(Double(consumed) / Double(max(target, 1)), 1.0)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(consumed >= target ? SimplePalette.completionGreen.opacity(0.7) : SimplePalette.retroRed)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 12)
        }
        .frame(height: 32)
    }

    private func shortDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func loadCompletion() {
        if let completion = onboardingData.completion(for: date) {
            cardioComplete = completion.cardioComplete
            strengthComplete = completion.strengthComplete
        } else {
            cardioComplete = false
            strengthComplete = false
        }
    }

    private func saveCompletion() {
        guard let plan = onboardingData.generatedPlan else { return }

        let foodLog = onboardingData.completion(for: date)?.foodLog ?? []
        let consumed = foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }

        let existing = onboardingData.completion(for: date)
        let completion = DayCompletion(
            cardioComplete: cardioComplete,
            strengthComplete: strengthComplete,
            caloriesConsumed: consumed.calories,
            proteinConsumed: consumed.protein,
            caloriesTarget: plan.macroTargets.calories,
            proteinTarget: plan.macroTargets.protein,
            foodLog: foodLog,
            plannedCardio: existing?.plannedCardio,
            plannedStrength: existing?.plannedStrength,
            waterConsumed: existing?.waterConsumed ?? 0,
            waterTarget: plan.waterIntakeOz
        )

        onboardingData.updateCompletion(for: date, completion: completion)
    }
}

extension Date: Identifiable {
    public var id: TimeInterval { self.timeIntervalSince1970 }
}

#Preview {
    NavigationStack {
        CalendarSectionView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.generatePlaceholderPlan()
        return data
    }())
}
