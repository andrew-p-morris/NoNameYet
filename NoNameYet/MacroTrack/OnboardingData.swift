import Foundation
import Combine

enum WeightUnit: String, CaseIterable, Identifiable {
    case pounds
    case kilograms

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pounds: return "Pounds"
        case .kilograms: return "Kilograms"
        }
    }

    var shortLabel: String {
        switch self {
        case .pounds: return "lbs"
        case .kilograms: return "kg"
        }
    }

    var range: ClosedRange<Int> {
        switch self {
        case .pounds: return 80...400
        case .kilograms: return 36...180
        }
    }

    func convert(value: Int, to unit: WeightUnit) -> Int {
        guard self != unit else { return value }

        let poundsValue: Double = {
            switch self {
            case .pounds:
                return Double(value)
            case .kilograms:
                return Double(value) * 2.20462
            }
        }()

        let converted: Double = {
            switch unit {
            case .pounds:
                return poundsValue
            case .kilograms:
                return poundsValue / 2.20462
            }
        }()

        return Int(converted.rounded())
    }
}

enum HeightUnit: String, CaseIterable, Identifiable {
    case imperial
    case metric

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .imperial: return "Feet / Inches"
        case .metric: return "Centimeters"
        }
    }

    var shortLabel: String {
        switch self {
        case .imperial: return "ft / in"
        case .metric: return "cm"
        }
    }

    static func centimeters(feet: Int, inches: Int) -> Int {
        let totalInches = feet * 12 + inches
        return Int((Double(totalInches) * 2.54).rounded())
    }

    static func imperialValues(fromCentimeters cm: Int) -> (feet: Int, inches: Int) {
        let totalInches = Int((Double(cm) / 2.54).rounded())
        let feet = totalInches / 12
        let inches = totalInches % 12
        return (feet, inches)
    }
}

struct MacroBreakdown: Equatable {
    var calories: Int
    var protein: Int
    var carbs: Int
    var sugar: Int
    var fat: Int
}

struct FoodEntry: Identifiable, Equatable {
    let id: UUID
    var name: String
    var macros: MacroBreakdown

    init(id: UUID = UUID(), name: String, macros: MacroBreakdown) {
        self.id = id
        self.name = name
        self.macros = macros
    }
}

struct LiquidEntry: Identifiable, Equatable {
    let id: UUID
    var name: String
    var macros: MacroBreakdown
    var ounces: Int

    init(id: UUID = UUID(), name: String, macros: MacroBreakdown, ounces: Int) {
        self.id = id
        self.name = name
        self.macros = macros
        self.ounces = ounces
    }
}

enum CardioType: String, CaseIterable, Identifiable {
    case run = "Run"
    case bike = "Bike"
    case swim = "Swim"
    case elliptical = "Elliptical"
    case row = "Row"
    case walk = "Walk"

    var id: String { rawValue }
}

enum StrengthExercise: String, CaseIterable, Identifiable {
    case pushUps = "Push-ups"
    case squats = "Squats"
    case deadlifts = "Deadlifts"
    case benchPress = "Bench Press"
    case pullUps = "Pull-ups"
    case lunges = "Lunges"
    case plank = "Plank"

    var id: String { rawValue }
}

enum Intensity: String, CaseIterable, Identifiable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"

    var id: String { rawValue }
}

struct CardioWorkout: Equatable {
    var type: CardioType
    var duration: Int
    var distance: Double?
    var intensity: Intensity
}

struct StrengthWorkout: Equatable {
    var exercise: StrengthExercise
    var sets: Int
    var reps: Int
    var intensity: Intensity
}

enum WorkoutType: String {
    case cardio
    case strength
}

struct Workout: Identifiable, Equatable {
    var id: UUID
    var type: WorkoutType
    var cardio: CardioWorkout?
    var strength: StrengthWorkout?
    var isComplete: Bool
    
    init(id: UUID = UUID(), cardio: CardioWorkout, isComplete: Bool = false) {
        self.id = id
        self.type = .cardio
        self.cardio = cardio
        self.strength = nil
        self.isComplete = isComplete
    }
    
    init(id: UUID = UUID(), strength: StrengthWorkout, isComplete: Bool = false) {
        self.id = id
        self.type = .strength
        self.cardio = nil
        self.strength = strength
        self.isComplete = isComplete
    }
}

enum ChartMetric: String, CaseIterable, Identifiable {
    case calories = "Calories"
    case protein = "Protein"
    case carbs = "Carbs"
    case sugar = "Sugar"
    case water = "Water"

    var id: String { rawValue }
    
    var unit: String {
        switch self {
        case .calories: return "kcal"
        case .protein, .carbs, .sugar: return "g"
        case .water: return "oz"
        }
    }
}

enum WeighInFrequency: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
    
    var id: String { rawValue }
    
    var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biWeekly: return 14
        case .monthly: return 30
        }
    }
}

enum ChartTimeRange: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"

    var id: String { rawValue }
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extraActive = "Extra Active"

    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Little/no exercise, desk job"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderatelyActive: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Hard exercise 6-7 days/week"
        case .extraActive: return "Very hard exercise, physical job"
        }
    }
}

enum DietType: String, CaseIterable, Identifiable {
    case balanced = "Balanced"
    case keto = "Keto"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case paleo = "Paleo"
    case highProtein = "High-Protein"
    
    var id: String { rawValue }
    
    var proteinRatio: Double {
        switch self {
        case .balanced: return 0.25
        case .keto: return 0.20
        case .vegan: return 0.20
        case .vegetarian: return 0.20
        case .paleo: return 0.30
        case .highProtein: return 0.35
        }
    }
    
    var fatRatio: Double {
        switch self {
        case .balanced: return 0.30
        case .keto: return 0.70
        case .vegan: return 0.25
        case .vegetarian: return 0.30
        case .paleo: return 0.40
        case .highProtein: return 0.25
        }
    }
    
    var carbRatio: Double {
        switch self {
        case .balanced: return 0.45
        case .keto: return 0.10
        case .vegan: return 0.55
        case .vegetarian: return 0.50
        case .paleo: return 0.30
        case .highProtein: return 0.40
        }
    }
}

struct HealthPlan {
    var cardio: CardioWorkout
    var strength: StrengthWorkout
    var macroTargets: MacroBreakdown
    var waterIntakeOz: Int
    var focusNotes: String
    var goalHighlights: [String]
    var dietaryHighlights: [String]
}

struct DayCompletion {
    var cardioComplete: Bool
    var strengthComplete: Bool
    var caloriesConsumed: Int
    var proteinConsumed: Int
    var caloriesTarget: Int
    var proteinTarget: Int
    var foodLog: [FoodEntry]
    var otherLiquids: [LiquidEntry] // Track juice, milk, alcohol, etc.
    var plannedCardio: CardioWorkout? // Keep for backward compatibility
    var plannedStrength: StrengthWorkout? // Keep for backward compatibility
    var plannedWorkouts: [Workout] // New array for multiple workouts
    var waterConsumed: Int
    var waterTarget: Int

    init(
        cardioComplete: Bool = false,
        strengthComplete: Bool = false,
        caloriesConsumed: Int = 0,
        proteinConsumed: Int = 0,
        caloriesTarget: Int = 0,
        proteinTarget: Int = 0,
        foodLog: [FoodEntry] = [],
        otherLiquids: [LiquidEntry] = [],
        plannedCardio: CardioWorkout? = nil,
        plannedStrength: StrengthWorkout? = nil,
        plannedWorkouts: [Workout] = [],
        waterConsumed: Int = 0,
        waterTarget: Int = 0
    ) {
        self.cardioComplete = cardioComplete
        self.strengthComplete = strengthComplete
        self.caloriesConsumed = caloriesConsumed
        self.proteinConsumed = proteinConsumed
        self.caloriesTarget = caloriesTarget
        self.proteinTarget = proteinTarget
        self.foodLog = foodLog
        self.otherLiquids = otherLiquids
        self.plannedCardio = plannedCardio
        self.plannedStrength = plannedStrength
        self.plannedWorkouts = plannedWorkouts
        self.waterConsumed = waterConsumed
        self.waterTarget = waterTarget
    }

    var isFullyComplete: Bool {
        let macrosComplete = caloriesConsumed >= caloriesTarget && proteinConsumed >= proteinTarget
        // If using new workout system, check all workouts are complete
        if !plannedWorkouts.isEmpty {
            let allWorkoutsComplete = plannedWorkouts.allSatisfy { $0.isComplete }
            return allWorkoutsComplete && macrosComplete
        }
        // Otherwise use old system
        return cardioComplete && strengthComplete && macrosComplete
    }
}

final class OnboardingData: ObservableObject {
    @Published var username: String = ""
    @Published var age: Int?
    @Published var weight: Int?
    @Published var weightUnit: WeightUnit = .pounds
    @Published var heightUnit: HeightUnit = .imperial
    @Published var heightFeet: Int?
    @Published var heightInches: Int?
    @Published var heightCentimeters: Int?
    @Published var gender: Gender?
    @Published var activityLevel: ActivityLevel?
    @Published var goals: [Int] = []
    @Published var dietaryInputRaw: String = ""
    @Published var dietaryRestrictions: [String] = []
    @Published var dietType: DietType?
    @Published var earnedAchievements: Set<Int> = []
    @Published var generatedPlan: HealthPlan?
    @Published var todaysFoodLog: [FoodEntry] = []
    @Published var dailyCompletions: [String: DayCompletion] = [:]
    
    // Achievement tracking
    @Published var totalDistanceTraveled: Double = 0 // in miles
    @Published var currentStreak: Int = 0 // consecutive days with at least one goal completed
    @Published var lastActivityDate: Date? // last date user completed any goal
    @Published var consecutiveWeighIns: Int = 0 // consecutive weigh-ins without missing
    @Published var consecutiveMacroDays: Int = 0 // consecutive days hitting calorie + protein
    @Published var totalWorkoutsCompleted: Int = 0 // total workout days completed
    @Published var waterGoalDaysCount: Int = 0 // total days hitting water goal
    
    // Weight tracking
    @Published var currentWeight: Int?
    @Published var weightTarget: Int?
    @Published var weightHistory: [(date: Date, weight: Int)] = []
    @Published var weighInFrequency: WeighInFrequency = .weekly
    @Published var lastWeighInDate: Date?

    private let goalDescriptions: [Int: String] = [
        1: "Build Muscle / Gain Strength",
        2: "Lose Weight / Burn Fat",
        3: "Improve Endurance",
        4: "Build Functional Strength",
        5: "Improve Athletic Performance",
        6: "General Health & Wellness",
        7: "Rehabilitation / Injury Prevention"
    ]
    
    func goalDescription(for goal: Int) -> String {
        return goalDescriptions[goal] ?? "Goal \(goal)"
    }

    func generatePlaceholderPlan() {
        let weightPounds: Double = {
            guard let weight else { return 160 }
            if weightUnit == .pounds {
                return Double(weight)
            } else {
                return Double(weightUnit.convert(value: weight, to: .pounds))
            }
        }()

        let calories = clamp(Int(weightPounds * 12.5), lower: 1600, upper: 3200)
        let protein = clamp(Int(weightPounds * 0.85), lower: 90, upper: 220)
        let carbs = clamp(Int(Double(calories) * 0.45 / 4.0), lower: 180, upper: 360)
        let sugar = clamp(Int(Double(calories) * 0.08 / 4.0), lower: 24, upper: 48)
        let fat = clamp(Int(Double(calories) * 0.30 / 9.0), lower: 40, upper: 150)
        let water = clamp(Int(weightPounds * 0.67), lower: 64, upper: 140)

        let goalLabels = goals.map { goalDescriptions[$0] ?? "Goal \($0)" }
        let focusNotes: String = {
            if goalLabels.isEmpty {
                return "Balance cardio capacity and total-body strength for sustainable progress."
            } else {
                return "Emphasis on \(goalLabels.joined(separator: ", ")) while maintaining overall conditioning."
            }
        }()

        generatedPlan = HealthPlan(
            cardio: CardioWorkout(type: .run, duration: 30, distance: 2.0, intensity: .moderate),
            strength: StrengthWorkout(exercise: .squats, sets: 3, reps: 12, intensity: .moderate),
            macroTargets: MacroBreakdown(calories: calories, protein: protein, carbs: carbs, sugar: sugar, fat: fat),
            waterIntakeOz: water,
            focusNotes: focusNotes,
            goalHighlights: goalLabels,
            dietaryHighlights: dietaryRestrictions
        )
    }

    func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func completion(for date: Date) -> DayCompletion? {
        dailyCompletions[dayKey(for: date)]
    }

    func updateCompletion(for date: Date, completion: DayCompletion) {
        dailyCompletions[dayKey(for: date)] = completion
    }

    func foodLog(for date: Date) -> [FoodEntry] {
        return completion(for: date)?.foodLog ?? []
    }

    func addFoodEntry(_ entry: FoodEntry, for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        var existing = dailyCompletions[key] ?? DayCompletion(
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
        
        existing.foodLog.append(entry)
        
        // Calculate macros from both food and other liquids
        let foodMacros = existing.foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        let liquidMacros = existing.otherLiquids.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        existing.caloriesConsumed = foodMacros.calories + liquidMacros.calories
        existing.proteinConsumed = foodMacros.protein + liquidMacros.protein
        existing.caloriesTarget = plan.macroTargets.calories
        existing.proteinTarget = plan.macroTargets.protein
        
        dailyCompletions[key] = existing
        
        // Check if macro goals met for today (only if today)
        if Calendar.current.isDateInToday(date) {
            checkAndUpdateMacroStreak()
        }
    }
    
    func addLiquidEntry(_ entry: LiquidEntry, for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        var existing = dailyCompletions[key] ?? DayCompletion(
            cardioComplete: false,
            strengthComplete: false,
            caloriesConsumed: 0,
            proteinConsumed: 0,
            caloriesTarget: plan.macroTargets.calories,
            proteinTarget: plan.macroTargets.protein,
            foodLog: [],
            otherLiquids: [],
            plannedCardio: nil,
            plannedStrength: nil,
            plannedWorkouts: [],
            waterConsumed: 0,
            waterTarget: plan.waterIntakeOz
        )
        
        existing.otherLiquids.append(entry)
        
        // Calculate macros from both food and other liquids
        let foodMacros = existing.foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        let liquidMacros = existing.otherLiquids.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        existing.caloriesConsumed = foodMacros.calories + liquidMacros.calories
        existing.proteinConsumed = foodMacros.protein + liquidMacros.protein
        existing.caloriesTarget = plan.macroTargets.calories
        existing.proteinTarget = plan.macroTargets.protein
        
        dailyCompletions[key] = existing
        
        // Check if macro goals met for today (only if today)
        if Calendar.current.isDateInToday(date) {
            checkAndUpdateMacroStreak()
        }
    }

    func removeFoodEntry(_ entry: FoodEntry, for date: Date) {
        let key = dayKey(for: date)
        guard var existing = dailyCompletions[key] else { return }
        
        existing.foodLog.removeAll { $0.id == entry.id }
        
        let consumed = existing.foodLog.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        existing.caloriesConsumed = consumed.calories
        existing.proteinConsumed = consumed.protein
        
        dailyCompletions[key] = existing
    }

    func setFoodLog(_ entries: [FoodEntry], for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        let consumed = entries.reduce(MacroBreakdown(calories: 0, protein: 0, carbs: 0, sugar: 0, fat: 0)) { acc, entry in
            MacroBreakdown(
                calories: acc.calories + entry.macros.calories,
                protein: acc.protein + entry.macros.protein,
                carbs: acc.carbs + entry.macros.carbs,
                sugar: acc.sugar + entry.macros.sugar,
                fat: acc.fat + entry.macros.fat
            )
        }
        
        let current = dailyCompletions[key]
        var existing = current ?? DayCompletion(
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
        
        existing.foodLog = entries
        existing.caloriesConsumed = consumed.calories
        existing.proteinConsumed = consumed.protein
        existing.caloriesTarget = plan.macroTargets.calories
        existing.proteinTarget = plan.macroTargets.protein
        
        dailyCompletions[key] = existing
    }

    func workouts(for date: Date) -> (cardio: CardioWorkout, strength: StrengthWorkout) {
        guard let plan = generatedPlan else {
            let defaultCardio = CardioWorkout(type: .run, duration: 30, distance: 2.0, intensity: .moderate)
            let defaultStrength = StrengthWorkout(exercise: .squats, sets: 3, reps: 12, intensity: .moderate)
            return (defaultCardio, defaultStrength)
        }
        
        let completion = self.completion(for: date)
        let cardio = completion?.plannedCardio ?? plan.cardio
        let strength = completion?.plannedStrength ?? plan.strength
        
        return (cardio, strength)
    }

    func setWorkouts(cardio: CardioWorkout?, strength: StrengthWorkout?, for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        var existing = dailyCompletions[key] ?? DayCompletion(
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
        
        if let cardio = cardio {
            existing.plannedCardio = cardio
        }
        if let strength = strength {
            existing.plannedStrength = strength
        }
        
        dailyCompletions[key] = existing
    }
    
    // New methods for managing multiple workouts
    func workoutsArray(for date: Date) -> [Workout] {
        let completion = self.completion(for: date)
        
        // If using new workout system, return those
        if let workouts = completion?.plannedWorkouts, !workouts.isEmpty {
            return workouts
        }
        
        // Otherwise, convert old system to new system
        guard let plan = generatedPlan else {
            return []
        }
        
        var workouts: [Workout] = []
        let cardio = completion?.plannedCardio ?? plan.cardio
        let strength = completion?.plannedStrength ?? plan.strength
        let cardioComplete = completion?.cardioComplete ?? false
        let strengthComplete = completion?.strengthComplete ?? false
        
        workouts.append(Workout(cardio: cardio, isComplete: cardioComplete))
        workouts.append(Workout(strength: strength, isComplete: strengthComplete))
        
        return workouts
    }
    
    func setWorkoutsArray(_ workouts: [Workout], for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        var existing = dailyCompletions[key] ?? DayCompletion(
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
        
        // Limit to 4 workouts max
        existing.plannedWorkouts = Array(workouts.prefix(4))
        
        // Update completion status from workouts
        existing.cardioComplete = workouts.filter { $0.type == .cardio }.allSatisfy { $0.isComplete }
        existing.strengthComplete = workouts.filter { $0.type == .strength }.allSatisfy { $0.isComplete }
        
        dailyCompletions[key] = existing
    }
    
    func addWorkout(_ workout: Workout, for date: Date) {
        var workouts = workoutsArray(for: date)
        
        // Don't add if already at max (4 workouts)
        guard workouts.count < 4 else { return }
        
        workouts.append(workout)
        setWorkoutsArray(workouts, for: date)
    }
    
    func removeWorkout(at index: Int, for date: Date) {
        var workouts = workoutsArray(for: date)
        guard index < workouts.count else { return }
        
        workouts.remove(at: index)
        setWorkoutsArray(workouts, for: date)
    }
    
    func updateWorkout(at index: Int, workout: Workout, for date: Date) {
        var workouts = workoutsArray(for: date)
        guard index < workouts.count else { return }
        
        workouts[index] = workout
        setWorkoutsArray(workouts, for: date)
    }

    func waterIntake(for date: Date) -> Int {
        return completion(for: date)?.waterConsumed ?? 0
    }
    
    func otherLiquids(for date: Date) -> [LiquidEntry] {
        return completion(for: date)?.otherLiquids ?? []
    }

    func addWaterIntake(_ ounces: Int, for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        let current = dailyCompletions[key]
        var existing = current ?? DayCompletion(
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
        
        let wasUnderGoal = existing.waterConsumed < existing.waterTarget
        existing.waterConsumed += ounces
        existing.waterTarget = plan.waterIntakeOz
        
        // If water goal is now met for the first time today, increment counter
        if wasUnderGoal && existing.waterConsumed >= existing.waterTarget {
            waterGoalDaysCount += 1
        }
        
        dailyCompletions[key] = existing
    }

    func setWaterIntake(_ ounces: Int, for date: Date) {
        let key = dayKey(for: date)
        guard let plan = generatedPlan else { return }
        
        let current = dailyCompletions[key]
        var existing = current ?? DayCompletion(
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
        
        existing.waterConsumed = ounces
        existing.waterTarget = plan.waterIntakeOz
        
        dailyCompletions[key] = existing
    }

    func parseAndLogCoachInput(_ input: String, completion: @escaping (Bool, String, [String], Int?, [Int]) -> Void) {
        Task {
            let result = await CoachNotesParser.parseWithAI(input)
            var foodsLogged: [String] = []
            var waterLogged: Int? = nil
            var workoutsLogged: [String] = []
        
        // Log foods
        for food in result.foods {
            let entry = FoodEntry(
                name: food.name,
                macros: food.macros
            )
            self.addFoodEntry(entry, for: result.date)
            foodsLogged.append(food.name)
        }
        
        // Log water
        if let water = result.water {
            let currentWater = self.waterIntake(for: result.date)
            self.addWaterIntake(water.ounces, for: result.date)
            waterLogged = currentWater + water.ounces
        }
        
        // Log other liquids (juice, milk, alcohol, etc.)
        for liquid in result.otherLiquids {
            let entry = LiquidEntry(
                name: liquid.name,
                macros: liquid.macros,
                ounces: liquid.ounces
            )
            self.addLiquidEntry(entry, for: result.date)
        }
        
        // Process workouts
        let key = self.dayKey(for: result.date)
        guard let plan = self.generatedPlan else {
            // If no plan, still generate message for foods/water
            var messageParts: [String] = []
            if !foodsLogged.isEmpty {
                let foodList = foodsLogged.joined(separator: ", ")
                messageParts.append("Logged: \(foodList)")
            }
            if let water = result.water {
                messageParts.append("Water: \(water.ounces) oz")
            }
            let dateFormatter = DateFormatter()
            if Calendar.current.isDateInToday(result.date) {
                messageParts.append("(today)")
            } else if Calendar.current.isDateInYesterday(result.date) {
                messageParts.append("(yesterday)")
            } else {
                dateFormatter.dateStyle = .medium
                messageParts.append("(\(dateFormatter.string(from: result.date)))")
            }
            let success = !foodsLogged.isEmpty || result.water != nil
            let message = success ? messageParts.joined(separator: " ") : "Could not parse any food or water from your input."
            let finalFoodsLogged = foodsLogged
            let finalWaterLogged = waterLogged
            
            // Check for newly unlocked achievements
            let newAchievements = self.checkAchievements()
            
            await MainActor.run {
                completion(success, message, finalFoodsLogged, finalWaterLogged, newAchievements)
            }
            return
        }
        
        var dayCompletion = self.dailyCompletions[key] ?? DayCompletion(
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
        
        // Process each workout
        for workout in result.workouts {
            switch workout.type {
            case .cardio:
                if let cardioType = workout.cardioType {
                    // Create or update cardio workout
                    let duration = workout.duration ?? plan.cardio.duration
                    let distance = workout.distance ?? plan.cardio.distance
                    let newCardio = CardioWorkout(
                        type: cardioType,
                        duration: duration,
                        distance: distance,
                        intensity: plan.cardio.intensity
                    )
                    dayCompletion.plannedCardio = newCardio
                    
                    if workout.isComplete {
                        let wasIncomplete = !dayCompletion.cardioComplete
                        dayCompletion.cardioComplete = true
                        
                        // Track distance for Run, Bike, Swim, Walk
                        if let distance = workout.distance {
                            self.totalDistanceTraveled += distance
                        }
                        
                        // Increment workout count if this is the first workout completed today
                        if wasIncomplete && !dayCompletion.strengthComplete {
                            self.totalWorkoutsCompleted += 1
                        }
                    }
                    
                    let workoutDesc = workout.distance != nil 
                        ? "\(cardioType.rawValue) \(String(format: "%.1f", workout.distance!)) mi"
                        : workout.duration != nil
                        ? "\(cardioType.rawValue) \(workout.duration!) min"
                        : cardioType.rawValue
                    workoutsLogged.append(workoutDesc)
                }
                
            case .strength:
                if let strengthExercise = workout.strengthExercise {
                    // Create or update strength workout
                    let sets = workout.sets ?? plan.strength.sets
                    let reps = workout.reps ?? plan.strength.reps
                    let newStrength = StrengthWorkout(
                        exercise: strengthExercise,
                        sets: sets,
                        reps: reps,
                        intensity: plan.strength.intensity
                    )
                    dayCompletion.plannedStrength = newStrength
                    
                    if workout.isComplete {
                        let wasIncomplete = !dayCompletion.strengthComplete
                        dayCompletion.strengthComplete = true
                        
                        // Increment workout count if this is the first workout completed today
                        if wasIncomplete && !dayCompletion.cardioComplete {
                            self.totalWorkoutsCompleted += 1
                        }
                    }
                    
                    let workoutDesc = workout.sets != nil && workout.reps != nil
                        ? "\(strengthExercise.rawValue) \(workout.sets!)x\(workout.reps!)"
                        : strengthExercise.rawValue
                    workoutsLogged.append(workoutDesc)
                }
            }
        }
        
        // Save updated dayCompletion
        self.dailyCompletions[key] = dayCompletion
        
        // Update app usage streak if any goal completed today
        if Calendar.current.isDateInToday(result.date) && 
           (!result.foods.isEmpty || !result.otherLiquids.isEmpty || result.water != nil || !result.workouts.isEmpty) {
            self.updateAppStreak()
        }
        
        // Generate confirmation message
        var messageParts: [String] = []
        
        if !foodsLogged.isEmpty {
            let foodList = foodsLogged.joined(separator: ", ")
            messageParts.append("Logged: \(foodList)")
        }
        
        if !workoutsLogged.isEmpty {
            let workoutList = workoutsLogged.joined(separator: ", ")
            messageParts.append("Workouts: \(workoutList)")
        }
        
        if let water = result.water {
            messageParts.append("Water: \(water.ounces) oz")
        }
        
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(result.date) {
            messageParts.append("(today)")
        } else if Calendar.current.isDateInYesterday(result.date) {
            messageParts.append("(yesterday)")
        } else {
            dateFormatter.dateStyle = .medium
            messageParts.append("(\(dateFormatter.string(from: result.date)))")
        }
        
        let success = !foodsLogged.isEmpty || result.water != nil || !result.workouts.isEmpty
        let message = success ? messageParts.joined(separator: " ") : "Could not parse any food, water, or workouts from your input."
        let finalFoodsLogged = foodsLogged
        let finalWaterLogged = waterLogged
        
        // Check for newly unlocked achievements
        let newAchievements = self.checkAchievements()
        
        await MainActor.run {
            completion(success, message, finalFoodsLogged, finalWaterLogged, newAchievements)
        }
        }
    }
    
    // Struct to hold parsed preview data before logging
    struct ParsedPreview: Identifiable {
        let id = UUID()
        let date: Date
        let foods: [(name: String, macros: MacroBreakdown)]
        let water: Int?
        let workouts: [(description: String, type: String)]
        let hasContent: Bool
        
        var dateString: String {
            let dateFormatter = DateFormatter()
            if Calendar.current.isDateInToday(date) {
                return "today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "yesterday"
            } else {
                dateFormatter.dateStyle = .medium
                return dateFormatter.string(from: date)
            }
        }
    }
    
    func parseCoachInputPreview(_ input: String, completion: @escaping (ParsedPreview) -> Void) {
        Task {
            let result = await CoachNotesParser.parseWithAI(input)
        
        var foodItems: [(name: String, macros: MacroBreakdown)] = []
        for food in result.foods {
            foodItems.append((name: food.name, macros: food.macros))
        }
        
        var workoutItems: [(description: String, type: String)] = []
        for workout in result.workouts {
            var desc = ""
            if workout.type == .cardio, let cardioType = workout.cardioType {
                if let distance = workout.distance {
                    desc = "\(cardioType.rawValue) \(String(format: "%.1f", distance)) mi"
                } else if let duration = workout.duration {
                    desc = "\(cardioType.rawValue) \(duration) min"
                } else {
                    desc = cardioType.rawValue
                }
            } else if workout.type == .strength, let exercise = workout.strengthExercise {
                if let sets = workout.sets, let reps = workout.reps {
                    desc = "\(exercise.rawValue) \(sets)x\(reps)"
                } else {
                    desc = exercise.rawValue
                }
            }
            if !desc.isEmpty {
                workoutItems.append((description: desc, type: workout.type == .cardio ? "Cardio" : "Strength"))
            }
        }
        
        let preview = ParsedPreview(
            date: result.date,
            foods: foodItems,
            water: result.water?.ounces,
            workouts: workoutItems,
            hasContent: !foodItems.isEmpty || result.water != nil || !workoutItems.isEmpty
        )
        
        await MainActor.run {
            completion(preview)
        }
        }
    }

    func getChartData(for metric: ChartMetric, timeRange: ChartTimeRange) -> [(date: Date, value: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let startDate: Date
        
        switch timeRange {
        case .day:
            // Last 14 days
            startDate = calendar.date(byAdding: .day, value: -13, to: today) ?? today
            return getDayChartData(metric: metric, startDate: startDate, endDate: today)
        case .week:
            // Last 8 weeks
            startDate = calendar.date(byAdding: .weekOfYear, value: -7, to: today) ?? today
            return getWeekChartData(metric: metric, startDate: startDate, endDate: today)
        case .month:
            // Last 12 months
            startDate = calendar.date(byAdding: .month, value: -11, to: today) ?? today
            return getMonthChartData(metric: metric, startDate: startDate, endDate: today)
        }
    }
    
    private func getDayChartData(metric: ChartMetric, startDate: Date, endDate: Date) -> [(date: Date, value: Int)] {
        let calendar = Calendar.current
        var data: [(date: Date, value: Int)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let value = getMetricValue(for: metric, date: currentDate)
            data.append((date: currentDate, value: value))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return data
    }
    
    private func getWeekChartData(metric: ChartMetric, startDate: Date, endDate: Date) -> [(date: Date, value: Int)] {
        let calendar = Calendar.current
        var data: [(date: Date, value: Int)] = []
        
        // Find the start of the week (Monday) for startDate
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate)) ?? startDate
        var currentWeekStart = startOfWeek
        let endOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: endDate)) ?? endDate
        
        while currentWeekStart <= endOfWeek {
            // Get all days in this week
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: currentWeekStart) ?? currentWeekStart
            var totalValue = 0
            var dayCount = 0
            
            var currentDay = currentWeekStart
            while currentDay <= weekEnd && currentDay <= endDate {
                totalValue += getMetricValue(for: metric, date: currentDay)
                dayCount += 1
                currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
            }
            
            let averageValue = dayCount > 0 ? totalValue / dayCount : 0
            data.append((date: currentWeekStart, value: averageValue))
            
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? currentWeekStart
        }
        
        return data
    }
    
    private func getMonthChartData(metric: ChartMetric, startDate: Date, endDate: Date) -> [(date: Date, value: Int)] {
        let calendar = Calendar.current
        var data: [(date: Date, value: Int)] = []
        
        // Find the start of the month for startDate
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)) ?? startDate
        var currentMonthStart = startOfMonth
        let endOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: endDate)) ?? endDate
        
        while currentMonthStart <= endOfMonth {
            // Get all days in this month
            let range = calendar.range(of: .day, in: .month, for: currentMonthStart) ?? 1..<2
            var totalValue = 0
            var dayCount = 0
            
            for day in range {
                if let currentDay = calendar.date(byAdding: .day, value: day - 1, to: currentMonthStart),
                   currentDay <= endDate {
                    totalValue += getMetricValue(for: metric, date: currentDay)
                    dayCount += 1
                }
            }
            
            let averageValue = dayCount > 0 ? totalValue / dayCount : 0
            data.append((date: currentMonthStart, value: averageValue))
            
            currentMonthStart = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) ?? currentMonthStart
        }
        
        return data
    }
    
    private func getMetricValue(for metric: ChartMetric, date: Date) -> Int {
        guard let completion = completion(for: date) else { return 0 }
        
        switch metric {
        case .calories:
            return completion.caloriesConsumed
        case .protein:
            return completion.proteinConsumed
        case .carbs:
            let foodLog = self.foodLog(for: date)
            return foodLog.reduce(0) { $0 + $1.macros.carbs }
        case .sugar:
            let foodLog = self.foodLog(for: date)
            return foodLog.reduce(0) { $0 + $1.macros.sugar }
        case .water:
            return completion.waterConsumed
        }
    }

    func reset() {
        username = ""
        age = nil
        weight = nil
        weightUnit = .pounds
        heightUnit = .imperial
        heightFeet = nil
        heightInches = nil
        heightCentimeters = nil
        goals = []
        dietaryInputRaw = ""
        dietaryRestrictions = []
        generatedPlan = nil
        todaysFoodLog = []
        dailyCompletions = [:]
        currentWeight = nil
        weightTarget = nil
        weightHistory = []
        weighInFrequency = .weekly
        lastWeighInDate = nil
    }
    
    // Weight tracking functions
    func recordWeight(_ weight: Int) {
        let today = Date()
        let calendar = Calendar.current
        
        currentWeight = weight
        weightHistory.append((date: today, weight: weight))
        
        // Check if this is a consecutive weigh-in
        if let lastDate = lastWeighInDate,
           let nextExpectedDate = calendar.date(byAdding: .day, value: weighInFrequency.days, to: lastDate) {
            // If weighing in on or before the expected date, it's consecutive
            if today <= nextExpectedDate || calendar.isDate(today, inSameDayAs: nextExpectedDate) {
                consecutiveWeighIns += 1
            } else {
                // Missed the window, reset streak
                consecutiveWeighIns = 1
            }
        } else {
            // First weigh-in
            consecutiveWeighIns = 1
        }
        
        lastWeighInDate = today
        
        // Check if goal weight reached
        if let target = weightTarget, weight == target {
            checkAchievements()
        }
    }
    
    func nextWeighInDate() -> Date? {
        guard let lastDate = lastWeighInDate else {
            return Date() // If never weighed in, next is today
        }
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: weighInFrequency.days, to: lastDate)
    }
    
    func daysUntilNextWeighIn() -> Int? {
        guard let nextDate = nextWeighInDate() else { return nil }
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.day], from: today, to: nextDate)
        return max(0, components.day ?? 0)
    }
    
    // Check and update macro streak (consecutive days hitting calorie + protein targets)
    private func checkAndUpdateMacroStreak() {
        let today = Date()
        let key = dayKey(for: today)
        guard let todayCompletion = dailyCompletions[key],
              todayCompletion.caloriesConsumed >= todayCompletion.caloriesTarget &&
              todayCompletion.proteinConsumed >= todayCompletion.proteinTarget else {
            return // Today's macros not met yet
        }
        
        // Check if yesterday also met macros
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            consecutiveMacroDays = 1
            return
        }
        
        let yesterdayKey = dayKey(for: yesterday)
        if let yesterdayCompletion = dailyCompletions[yesterdayKey],
           yesterdayCompletion.caloriesConsumed >= yesterdayCompletion.caloriesTarget &&
           yesterdayCompletion.proteinConsumed >= yesterdayCompletion.proteinTarget {
            // Continue streak
            consecutiveMacroDays += 1
        } else {
            // Start new streak
            consecutiveMacroDays = 1
        }
    }
    
    // Update app usage streak (called when user completes any goal)
    func updateAppStreak() {
        let today = Date()
        let calendar = Calendar.current
        
        // If already logged activity today, don't update
        if let lastDate = lastActivityDate, calendar.isDate(today, inSameDayAs: lastDate) {
            return
        }
        
        // Check if this continues a streak
        if let lastDate = lastActivityDate {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(lastDate, inSameDayAs: yesterday) {
                // Streak continues
                currentStreak += 1
            } else {
                // Streak broken, reset to 1
                currentStreak = 1
            }
        } else {
            // First day
            currentStreak = 1
        }
        
        lastActivityDate = today
    }
    
    // Achievement checking function - returns newly unlocked achievement IDs
    func checkAchievements() -> [Int] {
        var newlyUnlocked: [Int] = []
        
        // Distance achievements (1-10)
        let distanceMilestones: [(id: Int, miles: Double)] = [
            (1, 1), (2, 10), (3, 25), (4, 50), (5, 100),
            (6, 250), (7, 500), (8, 1000), (9, 2000), (10, 5000)
        ]
        for milestone in distanceMilestones {
            if totalDistanceTraveled >= milestone.miles && !earnedAchievements.contains(milestone.id) {
                earnedAchievements.insert(milestone.id)
                newlyUnlocked.append(milestone.id)
            }
        }
        
        // Streak achievements (11-20)
        let streakMilestones: [(id: Int, days: Int)] = [
            (11, 7), (12, 14), (13, 30), (14, 60), (15, 90),
            (16, 180), (17, 270), (18, 365), (19, 500), (20, 730)
        ]
        for milestone in streakMilestones {
            if currentStreak >= milestone.days && !earnedAchievements.contains(milestone.id) {
                earnedAchievements.insert(milestone.id)
                newlyUnlocked.append(milestone.id)
            }
        }
        
        // Weight achievements (21-30)
        // 21 = Goal Weight (special check)
        if let current = currentWeight, let target = weightTarget, current == target && !earnedAchievements.contains(21) {
            earnedAchievements.insert(21)
            newlyUnlocked.append(21)
        }
        
        // 22 = First weigh-in
        if !weightHistory.isEmpty && !earnedAchievements.contains(22) {
            earnedAchievements.insert(22)
            newlyUnlocked.append(22)
        }
        
        // Consecutive weigh-ins (23-30)
        let weighInMilestones: [(id: Int, count: Int)] = [
            (23, 5), (24, 10), (25, 15), (26, 25), (27, 52),
            (28, 100), (29, 150), (30, 200)
        ]
        for milestone in weighInMilestones {
            if consecutiveWeighIns >= milestone.count && !earnedAchievements.contains(milestone.id) {
                earnedAchievements.insert(milestone.id)
                newlyUnlocked.append(milestone.id)
            }
        }
        
        // Macro achievements (31-40)
        let macroMilestones: [(id: Int, days: Int)] = [
            (31, 7), (32, 14), (33, 21), (34, 30), (35, 45),
            (36, 60), (37, 90), (38, 120), (39, 150), (40, 180)
        ]
        for milestone in macroMilestones {
            if consecutiveMacroDays >= milestone.days && !earnedAchievements.contains(milestone.id) {
                earnedAchievements.insert(milestone.id)
                newlyUnlocked.append(milestone.id)
            }
        }
        
        // Workout achievements (41-50)
        let workoutMilestones: [(id: Int, count: Int)] = [
            (41, 1), (42, 5), (43, 10), (44, 30), (45, 50),
            (46, 75), (47, 100), (48, 125), (49, 150), (50, 175)
        ]
        for milestone in workoutMilestones {
            if totalWorkoutsCompleted >= milestone.count && !earnedAchievements.contains(milestone.id) {
                earnedAchievements.insert(milestone.id)
                newlyUnlocked.append(milestone.id)
            }
        }
        
        // Water achievements (51-60)
        let waterMilestones: [(id: Int, days: Int)] = [
            (51, 7), (52, 14), (53, 30), (54, 45), (55, 60),
            (56, 90), (57, 120), (58, 150), (59, 180), (60, 210)
        ]
        for milestone in waterMilestones {
            if waterGoalDaysCount >= milestone.days && !earnedAchievements.contains(milestone.id) {
                earnedAchievements.insert(milestone.id)
                newlyUnlocked.append(milestone.id)
            }
        }
        
        return newlyUnlocked
    }

    private func clamp(_ value: Int, lower: Int, upper: Int) -> Int {
        return max(lower, min(upper, value))
    }
    
    // Mifflin-St Jeor BMR calculation
    func calculateBMR(weightKg: Double, heightCm: Double, age: Int, gender: Gender) -> Double {
        let base: Double
        switch gender {
        case .male:
            base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case .other:
            // Use average of male/female formula
            base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 78
        }
        return base
    }
    
    // Generate plan using Mifflin-St Jeor equation
    func generatePlanWithMifflinStJeor() {
        guard let age = age,
              let weight = weight,
              let gender = gender,
              let activityLevel = activityLevel else {
            // Fallback to placeholder if missing data
            generatePlaceholderPlan()
            return
        }
        
        // Convert weight to kg
        let weightKg: Double = {
            if weightUnit == .kilograms {
                return Double(weight)
            } else {
                return Double(weight) / 2.20462
            }
        }()
        
        // Convert height to cm
        let heightCm: Double = {
            if heightUnit == .metric {
                return Double(heightCentimeters ?? 173)
            } else {
                let feet = heightFeet ?? 5
                let inches = heightInches ?? 8
                return Double(HeightUnit.centimeters(feet: feet, inches: inches))
            }
        }()
        
        // Calculate BMR using Mifflin-St Jeor
        let bmr = calculateBMR(weightKg: weightKg, heightCm: heightCm, age: age, gender: gender)
        
        // Calculate TDEE (Total Daily Energy Expenditure)
        let tdee = bmr * activityLevel.multiplier
        
        // Adjust calories based on goals
        var adjustedCalories = tdee
        let goalLabels = goals.map { goalDescriptions[$0] ?? "Goal \($0)" }
        let hasWeightLoss = goalLabels.contains { $0.contains("Lose Weight") || $0.contains("Burn Fat") }
        let hasMuscleGain = goalLabels.contains { $0.contains("Build Muscle") || $0.contains("Gain Strength") }
        
        if hasWeightLoss {
            // Use 15-20% deficit, but cap at 500 calories max
            let deficitPercent = 0.17 // ~17% average
            let maxDeficit = 500.0
            let calculatedDeficit = min(tdee * deficitPercent, maxDeficit)
            adjustedCalories = tdee - calculatedDeficit
            
            // Ensure minimum is BMR + 100 (for basic metabolic function)
            let minCalories = bmr + 100
            adjustedCalories = max(adjustedCalories, minCalories)
        } else if hasMuscleGain {
            // Use 10-15% surplus, capped at 400 calories max
            let surplusPercent = 0.12 // ~12% average
            let maxSurplus = 400.0
            let calculatedSurplus = min(tdee * surplusPercent, maxSurplus)
            adjustedCalories = tdee + calculatedSurplus
            
            // Ensure minimum is BMR + 100 (for basic metabolic function)
            adjustedCalories = max(adjustedCalories, bmr + 100)
        } else {
            // Maintenance: ensure minimum is BMR + 100
            adjustedCalories = max(tdee, bmr + 100)
        }
        
        // Universal minimum: BMR + 100, with 1200 as absolute hard floor
        let universalMin = max(Int((bmr + 100).rounded()), 1200)
        let calories = clamp(Int(adjustedCalories.rounded()), lower: universalMin, upper: 4000)
        
        // Calculate macros using diet type ratios
        let diet = dietType ?? .balanced
        
        // Convert percentages to calories
        let proteinCalories = Double(calories) * diet.proteinRatio
        let fatCalories = Double(calories) * diet.fatRatio
        let carbCalories = Double(calories) * diet.carbRatio
        
        // Convert calories to grams (protein/carbs: 4 cal/g, fat: 9 cal/g)
        let protein = clamp(Int(proteinCalories / 4.0), lower: 60, upper: 250)
        let fat = clamp(Int(fatCalories / 9.0), lower: 40, upper: 150)
        let carbs = max(0, Int(carbCalories / 4.0))
        
        // Sugar: ~10% of total calories or based on carbs
        let sugar = clamp(Int(Double(calories) * 0.10 / 4.0), lower: 20, upper: 100)
        
        // Water: 30-35ml per kg body weight, convert to oz
        let waterMl = weightKg * 33
        let waterOz = Int((waterMl / 29.5735).rounded())
        let water = clamp(waterOz, lower: 50, upper: 150)
        
        // Generate workout recommendations based on goals
        let cardio = generateCardioWorkout(for: goalLabels)
        let strength = generateStrengthWorkout(for: goalLabels)
        
        let focusNotes: String = {
            if goalLabels.isEmpty {
                return "Balance cardio capacity and total-body strength for sustainable progress."
            } else {
                return "Emphasis on \(goalLabels.joined(separator: ", ")) while maintaining overall conditioning."
            }
        }()
        
        generatedPlan = HealthPlan(
            cardio: cardio,
            strength: strength,
            macroTargets: MacroBreakdown(calories: calories, protein: protein, carbs: carbs, sugar: sugar, fat: fat),
            waterIntakeOz: water,
            focusNotes: focusNotes,
            goalHighlights: goalLabels,
            dietaryHighlights: dietaryRestrictions
        )
    }
    
    func generateCardioWorkout(for goalLabels: [String]) -> CardioWorkout {
        let hasEndurance = goalLabels.contains { $0.contains("Endurance") }
        let hasAthletic = goalLabels.contains { $0.contains("Athletic Performance") }
        
        if hasEndurance || hasAthletic {
            return CardioWorkout(type: .run, duration: 45, distance: 3.0, intensity: .moderate)
        } else {
            return CardioWorkout(type: .run, duration: 30, distance: 2.0, intensity: .moderate)
        }
    }
    
    func generateStrengthWorkout(for goalLabels: [String]) -> StrengthWorkout {
        let hasFunctional = goalLabels.contains { $0.contains("Functional Strength") }
        let hasMuscle = goalLabels.contains { $0.contains("Build Muscle") || $0.contains("Gain Strength") }
        let hasRehab = goalLabels.contains { $0.contains("Rehabilitation") || $0.contains("Injury Prevention") }
        
        if hasRehab {
            return StrengthWorkout(exercise: .plank, sets: 3, reps: 60, intensity: .low)
        } else if hasFunctional || hasMuscle {
            return StrengthWorkout(exercise: .squats, sets: 4, reps: 12, intensity: .moderate)
        } else {
            return StrengthWorkout(exercise: .squats, sets: 3, reps: 12, intensity: .moderate)
        }
    }
}


