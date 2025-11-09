import SwiftUI

enum DateSelectorMode: String, CaseIterable, Identifiable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case custom = "Custom"

    var id: String { rawValue }
}

struct NutritionSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var targets: MacroBreakdown
    @State private var foodLog: [FoodEntry] = []
    @State private var showAddFood = false
    @State private var selectedDate: Date = Date()
    @State private var waterConsumed: Int = 0
    @State private var waterTarget: Int = 120
    @State private var otherLiquids: [LiquidEntry] = []
    @State private var isLoading: Bool = false

    init() {
        _targets = State(initialValue: MacroBreakdown(calories: 2000, protein: 140, carbs: 225, sugar: 40, fat: 80))
    }

    var body: some View {
        ZStack {
            simpleBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("NUTRITION TRACKER")
                        .font(SimplePalette.retroFont(size: 28, weight: .bold))
                        .foregroundStyle(SimplePalette.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    dateSelectorCard

                    targetsCard
                        .id("targets-\(selectedDate)")
                        .transition(.opacity)
                        .opacity(isLoading ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                    
                    waterIntakeCard
                        .id("water-\(selectedDate)")
                        .transition(.opacity)
                        .opacity(isLoading ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                    
                    otherLiquidsCard
                        .id("liquids-\(selectedDate)")
                        .transition(.opacity)
                        .opacity(isLoading ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                    
                    foodLogCard
                        .id("foodlog-\(selectedDate)")
                        .transition(.opacity)
                        .opacity(isLoading ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                }
                .padding(.bottom, 32)
            }
            
            // Loading indicator overlay
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                        )
                        .padding(.bottom, 100)
                    Spacer()
                }
            }
        }
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadFromPlan)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    saveToPlan()
                    dismiss()
                }) {
                    Text("SAVE")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                        .frame(width: 80, height: 44)
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
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodSheet(onAdd: { entry in
                onboardingData.addFoodEntry(entry, for: selectedDate)
                loadFromPlan()
            })
        }
    }

    private var targetsCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)

                    Text("DAILY TARGETS")
                        .font(SimplePalette.retroFont(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 20) {
                        targetPicker(label: "Calories", value: $targets.calories, range: 1200...4000, step: 100, suffix: "kcal")
                        targetPicker(label: "Protein", value: $targets.protein, range: 50...300, step: 10, suffix: "g")
                    }

                    HStack(spacing: 20) {
                        targetPicker(label: "Carbs", value: $targets.carbs, range: 100...500, step: 10, suffix: "g")
                        targetPicker(label: "Sugar", value: $targets.sugar, range: 10...100, step: 5, suffix: "g")
                    }
                    
                    HStack(spacing: 20) {
                        targetPicker(label: "Fat", value: $targets.fat, range: 30...200, step: 5, suffix: "g")
                    }
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }

    private var foodLogCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)

                    Text(dateLabel.uppercased())
                        .font(SimplePalette.retroFont(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)

                    Spacer()

                    Button(action: { showAddFood = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                    }
                    .buttonStyle(.plain)
                }

                if foodLog.isEmpty {
                    Text("NO MEALS LOGGED YET. TAP + TO ADD FOOD.")
                        .font(SimplePalette.retroFont(size: 15, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                        .padding(.vertical, 16)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(foodLog) { entry in
                            foodRow(entry: entry)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        onboardingData.removeFoodEntry(entry, for: selectedDate)
                                        loadFromPlan()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }

                        Divider().background(SimplePalette.cardBorder)

                        totalsRow
                    }
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }

    private func foodRow(entry: FoodEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.name.uppercased())
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)

                Text("\(entry.macros.calories) KCAL • \(entry.macros.protein)G P • \(entry.macros.carbs)G C • \(entry.macros.sugar)G S")
                    .font(SimplePalette.retroFont(size: 13, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
            
            Spacer()
            
            Button(action: {
                onboardingData.removeFoodEntry(entry, for: selectedDate)
                loadFromPlan()
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.retroRed)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private var totalsRow: some View {
        let totals = foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }

        return VStack(alignment: .leading, spacing: 8) {
            Text("TOTALS")
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)

            HStack(spacing: 12) {
                macroChip(label: "Calories", value: totals.calories, target: targets.calories, unit: "kcal")
                macroChip(label: "Protein", value: totals.protein, target: targets.protein, unit: "g")
            }

            HStack(spacing: 12) {
                macroChip(label: "Carbs", value: totals.carbs, target: targets.carbs, unit: "g")
                macroChip(label: "Sugar", value: totals.sugar, target: targets.sugar, unit: "g")
            }
            
            HStack(spacing: 12) {
                macroChip(label: "Fat", value: totals.fat, target: targets.fat, unit: "g")
            }
        }
        .padding(.top, 8)
    }

    private func macroChip(label: String, value: Int, target: Int, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 12, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)

            HStack(spacing: 4) {
                Text("\(value)")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(value > target ? SimplePalette.retroRed : SimplePalette.cardTextPrimary)

                Text("/")
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)

                Text("\(target) \(unit.uppercased())")
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

    private func targetPicker(label: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 14, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextSecondary)

            TextField("", value: value, format: .number)
                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                .foregroundStyle(SimplePalette.cardTextPrimary)
                .keyboardType(.numberPad)
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
                .overlay(
                    HStack {
                        Spacer()
                        Text(suffix.uppercased())
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                            .padding(.trailing, 12)
                    }
                )
        }
    }

    private var dateSelectorCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                Text("SELECT DATE")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)

                weekDateGrid
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }

    private var weekDateGrid: some View {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(weekDays, id: \.self) { date in
                Button(action: {
                    withAnimation {
                        isLoading = true
                        selectedDate = date
                    }
                    // Brief delay to show loading indicator
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        loadFromPlan()
                        isLoading = false
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(dayOfWeekAbbrev(for: date).uppercased())
                            .font(SimplePalette.retroFont(size: 11, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)

                        Text("\(calendar.component(.day, from: date))")
                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                            .foregroundStyle(calendar.isDate(date, inSameDayAs: selectedDate) ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? SimplePalette.retroRed : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(SimplePalette.retroBlack, lineWidth: 2)
                                    )
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today's Food Log"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday's Food Log"
        } else {
            formatter.dateStyle = .medium
            return "Food Log - \(formatter.string(from: selectedDate))"
        }
    }

    private func dayOfWeekAbbrev(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var waterIntakeCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("WATER INTAKE")
                        .font(SimplePalette.retroFont(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Progress display
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(waterConsumed) / \(waterTarget) OZ")
                                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextPrimary)

                            Spacer()

                            if waterConsumed >= waterTarget {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(SimplePalette.completionGreen)
                            }
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(SimplePalette.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(SimplePalette.cardBorder, lineWidth: 2)
                                    )

                                let progress = min(Double(waterConsumed) / Double(max(waterTarget, 1)), 1.0)
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(waterConsumed >= waterTarget ? SimplePalette.completionGreen.opacity(0.7) : SimplePalette.waterBlue.opacity(0.6))
                                    .frame(width: geo.size.width * progress)
                            }
                        }
                        .frame(height: 16)
                    }

                    Divider().background(SimplePalette.cardBorder)

                    // Target adjustment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DAILY TARGET")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)

                        TextField("", value: $waterTarget, format: .number)
                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                            .keyboardType(.numberPad)
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
                            .overlay(
                                HStack {
                                    Spacer()
                                    Text("OZ")
                                        .font(SimplePalette.retroFont(size: 14, weight: .medium))
                                        .foregroundStyle(SimplePalette.cardTextSecondary)
                                        .padding(.trailing, 12)
                                }
                            )
                    }

                    Divider().background(SimplePalette.cardBorder)

                    // Quick add buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK ADD")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)

                        HStack(spacing: 12) {
                            quickAddButton(amount: 8, label: "8 oz")
                            quickAddButton(amount: 16, label: "16 oz")
                            quickAddButton(amount: 24, label: "24 oz")
                            quickAddButton(amount: 32, label: "32 oz")
                        }
                    }
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private var otherLiquidsCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("OTHER LIQUIDS")
                        .font(SimplePalette.retroFont(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                    
                    Spacer()
                    
                    Text("(\(otherLiquids.count) ITEMS)")
                        .font(SimplePalette.retroFont(size: 14, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                }
                
                if otherLiquids.isEmpty {
                    Text("NO OTHER LIQUIDS LOGGED")
                        .font(SimplePalette.retroFont(size: 14, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(otherLiquids) { liquid in
                            liquidRow(liquid: liquid)
                            
                            if liquid.id != otherLiquids.last?.id {
                                Divider().background(SimplePalette.cardBorder)
                            }
                        }
                    }
                    
                    Divider().background(SimplePalette.cardBorder)
                    
                    // Liquids macro totals
                    let liquidTotals = otherLiquids.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, liquid in
                        MacroBreakdown(
                            calories: acc.calories + liquid.macros.calories,
                            protein: acc.protein + liquid.macros.protein,
                            carbs: acc.carbs + liquid.macros.carbs,
                            sugar: acc.sugar + liquid.macros.sugar,
                            fat: acc.fat + liquid.macros.fat
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LIQUID TOTALS")
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                        
                        Text("\(liquidTotals.calories) KCAL • \(liquidTotals.protein)G P • \(liquidTotals.carbs)G C • \(liquidTotals.sugar)G S • \(liquidTotals.fat)G F")
                            .font(SimplePalette.retroFont(size: 13, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                    }
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private func liquidRow(liquid: LiquidEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SimplePalette.waterBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(liquid.name.uppercased())
                    .font(SimplePalette.retroFont(size: 15, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                
                HStack(spacing: 8) {
                    Text("\(liquid.ounces) OZ")
                        .font(SimplePalette.retroFont(size: 13, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    Text("•")
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    Text("\(liquid.macros.calories) KCAL")
                        .font(SimplePalette.retroFont(size: 13, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private func quickAddButton(amount: Int, label: String) -> some View {
        Button(action: {
            onboardingData.addWaterIntake(amount, for: selectedDate)
            loadFromPlan()
        }) {
            Text(label.uppercased())
                .font(SimplePalette.retroFont(size: 14, weight: .bold))
                .foregroundStyle(SimplePalette.retroBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
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

    private func loadFromPlan() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let plan = onboardingData.generatedPlan {
                targets = plan.macroTargets
                waterTarget = plan.waterIntakeOz
            }
            foodLog = onboardingData.foodLog(for: selectedDate)
            waterConsumed = onboardingData.waterIntake(for: selectedDate)
            otherLiquids = onboardingData.otherLiquids(for: selectedDate)
        }
    }

    private func saveToPlan() {
        guard var plan = onboardingData.generatedPlan else { return }
        plan.macroTargets = targets
        plan.waterIntakeOz = waterTarget
        onboardingData.generatedPlan = plan
        
        // Save current food log to selected date
        onboardingData.setFoodLog(foodLog, for: selectedDate)
        
        // Save water intake to selected date
        onboardingData.setWaterIntake(waterConsumed, for: selectedDate)
    }
}

private struct AddFoodSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var foodName: String = ""
    @State private var calories: Int = 200
    @State private var protein: Int = 10
    @State private var carbs: Int = 25
    @State private var sugar: Int = 5

    let onAdd: (FoodEntry) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Food Name")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(SimplePalette.textSecondary)

                                TextField("e.g., Grilled chicken breast", text: $foodName)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .autocorrectionDisabled(false)
                            }
                            .simpleCardPadding()
                        }

                        SimpleCardPane {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Nutrition Info")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(SimplePalette.textSecondary)

                                VStack(alignment: .leading, spacing: 14) {
                                    macroPicker(label: "Calories", value: $calories, range: 0...2000, step: 10, suffix: "kcal")
                                    macroPicker(label: "Protein", value: $protein, range: 0...200, step: 5, suffix: "g")
                                    macroPicker(label: "Carbs", value: $carbs, range: 0...300, step: 5, suffix: "g")
                                    macroPicker(label: "Sugar", value: $sugar, range: 0...100, step: 1, suffix: "g")
                                }
                            }
                            .simpleCardPadding()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let entry = FoodEntry(
                            name: foodName.isEmpty ? "Untitled food" : foodName,
                            macros: MacroBreakdown(calories: calories, protein: protein, carbs: carbs, sugar: sugar, fat: 0)
                        )
                        onAdd(entry)
                        dismiss()
                    }
                }
            }
        }
    }

    private func macroPicker(label: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int, suffix: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(SimplePalette.textPrimary)
                .frame(width: 80, alignment: .leading)

            Spacer()

            Picker("", selection: value) {
                ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: step)), id: \.self) { val in
                    Text("\(val) \(suffix)").tag(val)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

private struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @Binding var dateSelectorMode: DateSelectorMode

    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()

                VStack(spacing: 24) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                }
                .padding(.top, 16)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dateSelectorMode = .custom
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NutritionSectionView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.generatePlaceholderPlan()
        return data
    }())
}

