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

struct MacroBreakdown {
    var calories: Int
    var protein: Int
    var carbs: Int
    var sugar: Int
}

struct HealthPlan {
    var cardioMinutes: Int
    var workoutMinutes: Int
    var macroTargets: MacroBreakdown
    var waterIntakeOz: Int
    var focusNotes: String
    var goalHighlights: [String]
    var dietaryHighlights: [String]
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
    @Published var goals: [Int] = []
    @Published var dietaryInputRaw: String = ""
    @Published var dietaryRestrictions: [String] = []
    @Published var generatedPlan: HealthPlan?

    private let goalDescriptions: [Int: String] = [
        1: "Build lean muscle",
        2: "Lose body fat",
        3: "Boost endurance",
        4: "Increase flexibility",
        5: "Enhance mobility",
        6: "Strengthen core",
        7: "Improve posture",
        8: "Gain functional strength",
        9: "Support heart health",
        10: "Reduce stress"
    ]

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
            cardioMinutes: 30,
            workoutMinutes: 30,
            macroTargets: MacroBreakdown(calories: calories, protein: protein, carbs: carbs, sugar: sugar),
            waterIntakeOz: water,
            focusNotes: focusNotes,
            goalHighlights: goalLabels,
            dietaryHighlights: dietaryRestrictions
        )
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
    }

    private func clamp(_ value: Int, lower: Int, upper: Int) -> Int {
        return max(lower, min(upper, value))
    }
}


