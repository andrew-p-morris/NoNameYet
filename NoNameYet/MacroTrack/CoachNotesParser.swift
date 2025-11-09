import Foundation

struct ParsedFood {
    let name: String
    let quantity: Double
    let macros: MacroBreakdown
}

struct ParsedWater {
    let ounces: Int
}

enum ParsedWorkoutType {
    case cardio
    case strength
}

struct ParsedWorkout {
    let type: ParsedWorkoutType
    let cardioType: CardioType?
    let strengthExercise: StrengthExercise?
    let duration: Int?
    let distance: Double?
    let sets: Int?
    let reps: Int?
    let isComplete: Bool
    
    init(type: ParsedWorkoutType, cardioType: CardioType? = nil, strengthExercise: StrengthExercise? = nil, duration: Int? = nil, distance: Double? = nil, sets: Int? = nil, reps: Int? = nil, isComplete: Bool = true) {
        self.type = type
        self.cardioType = cardioType
        self.strengthExercise = strengthExercise
        self.duration = duration
        self.distance = distance
        self.sets = sets
        self.reps = reps
        self.isComplete = isComplete
    }
}

struct ParsedResult {
    let date: Date
    let foods: [ParsedFood]
    let water: ParsedWater?
    let workouts: [ParsedWorkout]
    let rawText: String
}

struct CoachNotesParser {
    /// NEW: Use OpenAI to parse coach input (async)
    static func parseWithAI(_ input: String) async -> ParsedResult {
        do {
            return try await OpenAIService.shared.parseCoachInput(input)
        } catch {
            print("OpenAI parsing failed, falling back to regex: \(error.localizedDescription)")
            // Fallback to regex parser if OpenAI fails
            return parse(input)
        }
    }
    
    /// OLD: Legacy regex-based parser (used as fallback)
    static func parse(_ input: String) -> ParsedResult {
        let normalized = input.lowercased()
        let calendar = Calendar.current
        
        // Parse date
        let date = parseDate(from: normalized, calendar: calendar)
        
        // Parse water
        let water = parseWater(from: normalized)
        
        // Parse foods
        let foods = parseFoods(from: normalized)
        
        // Parse workouts
        let workouts = parseWorkouts(from: normalized)
        
        return ParsedResult(
            date: date,
            foods: foods,
            water: water,
            workouts: workouts,
            rawText: input
        )
    }
    
    private static func parseDate(from text: String, calendar: Calendar) -> Date {
        let today = Date()
        
        // Check for date keywords
        if text.contains("yesterday") {
            return calendar.date(byAdding: .day, value: -1, to: today) ?? today
        }
        
        if text.contains("today") || text.contains("this morning") || text.contains("this afternoon") {
            return today
        }
        
        if text.contains("two days ago") || text.contains("2 days ago") {
            return calendar.date(byAdding: .day, value: -2, to: today) ?? today
        }
        
        if text.contains("three days ago") || text.contains("3 days ago") {
            return calendar.date(byAdding: .day, value: -3, to: today) ?? today
        }
        
        // Check for day names
        let dayNames = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        for (index, dayName) in dayNames.enumerated() {
            if text.contains(dayName) {
                let weekday = index + 2 // Calendar uses 1=Sunday, 2=Monday, etc.
                let currentWeekday = calendar.component(.weekday, from: today)
                var daysToSubtract = currentWeekday - weekday
                if daysToSubtract <= 0 {
                    daysToSubtract += 7
                }
                return calendar.date(byAdding: .day, value: -daysToSubtract, to: today) ?? today
            }
        }
        
        // Default to today
        return today
    }
    
    private static func parseWater(from text: String) -> ParsedWater? {
        var waterOunces: Int? = nil
        
        // Pattern: "drank X oz water" or "X oz water"
        let ozPattern = #"(\d+)\s*oz"#
        if let regex = try? NSRegularExpression(pattern: ozPattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text),
           let oz = Int(text[range]),
           text.contains("water") {
            waterOunces = oz
        }
        
        // Pattern: "drank X glasses of water" or "X glasses"
        let glassPattern = #"(\d+)\s*glass"#
        if waterOunces == nil,
           let regex = try? NSRegularExpression(pattern: glassPattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text),
           let glasses = Int(text[range]),
           text.contains("water") {
            waterOunces = glasses * 8 // Assume 8 oz per glass
        }
        
        // Pattern: "drank water" or "had water" (default to 1 glass)
        if waterOunces == nil && (text.contains("drank water") || text.contains("had water") || text.contains("water")) {
            // Only if no food items mentioned to avoid false positives
            if !text.contains("ate") && !text.contains("had") && !text.contains("consumed") {
                waterOunces = 8
            }
        }
        
        return waterOunces.map { ParsedWater(ounces: $0) }
    }
    
    private static func parseFoods(from text: String) -> [ParsedFood] {
        var foods: [ParsedFood] = []
        let normalized = text.lowercased()
        
        // Extract and remove restaurant names
        let restaurantPatterns = [
            "from mcdonalds", "from mcdonald's", "from mcdonald", "mcdonalds", "mcdonald's",
            "from burger king", "from burger kings", "from bk", "burger king", "burger kings", "bk",
            "from wendy's", "from wendy", "wendy's", "wendy",
            "from taco bell", "taco bell",
            "from subway", "subway",
            "from chipotle", "chipotle"
        ]
        
        var cleanedText = normalized
        
        for pattern in restaurantPatterns {
            if normalized.contains(pattern) {
                cleanedText = cleanedText.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
                break
            }
        }
        
        // Split by common conjunctions
        let separators = [" and ", ", ", " plus ", " with "]
        var parts = [cleanedText]
        
        for separator in separators {
            var newParts: [String] = []
            for part in parts {
                newParts.append(contentsOf: part.components(separatedBy: separator))
            }
            parts = newParts
        }
        
        // Common food action verbs
        let actionPatterns = [
            "i just ate", "i just had", "i just consumed", "i just finished",
            "i ate", "ate", "had", "consumed", "finished", "drank",
            "i had", "i consumed", "i finished", "i drank",
            "just ate", "just had", "just consumed", "just finished"
        ]
        
        for part in parts {
            let cleaned = part.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip if it's just water
            if cleaned.contains("water") && !cleaned.contains("food") {
                continue
            }
            
            // Remove action verbs
            var foodText = cleaned
            for pattern in actionPatterns {
                foodText = foodText.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
            }
            foodText = foodText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse quantity and size
            let (quantity, remainingText) = parseQuantity(from: foodText)
            
            // Extract size (small, medium, large) and prepend to food name
            let sizePatterns = [
                ("small", "small"),
                ("medium", "medium"),
                ("large", "large"),
                ("big", "large")
            ]
            
            var foodName = remainingText
            var sizePrefix = ""
            
            for (pattern, size) in sizePatterns {
                if foodName.contains(pattern) {
                    sizePrefix = size + " "
                    foodName = foodName.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    break
                }
            }
            
            // Clean up food name - remove common filler words
            foodName = foodName
                .replacingOccurrences(of: "a ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "an ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "the ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "of ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "just ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: " i ", with: " ", options: .caseInsensitive)
                .replacingOccurrences(of: "^i ", with: "", options: [.caseInsensitive, .regularExpression])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty or very short food names
            if foodName.count < 2 {
                continue
            }
            
            // Skip if it's just water
            if foodName.lowercased() == "water" {
                continue
            }
            
            // Try with size prefix first (for fries especially)
            var searchName = sizePrefix + foodName
            var foundFood: FoodItem? = FoodDatabase.findFood(searchName)
            var macros: MacroBreakdown? = nil
            
            if let food = foundFood {
                macros = MacroBreakdown(
                    calories: Int(Double(food.calories) * quantity),
                    protein: Int(Double(food.protein) * quantity),
                    carbs: Int(Double(food.carbs) * quantity),
                    sugar: Int(Double(food.sugar) * quantity),
                    fat: Int(Double(food.fat) * quantity)
                )
            }
            
            // If not found and it's fries, try "fries" or "fry" with size
            if macros == nil && (foodName.contains("fry") || foodName.contains("fries")) {
                if sizePrefix.isEmpty {
                    searchName = "fries"
                } else {
                    searchName = sizePrefix + "fries"
                }
                foundFood = FoodDatabase.findFood(searchName)
                if let food = foundFood {
                    macros = MacroBreakdown(
                        calories: Int(Double(food.calories) * quantity),
                        protein: Int(Double(food.protein) * quantity),
                        carbs: Int(Double(food.carbs) * quantity),
                        sugar: Int(Double(food.sugar) * quantity),
                        fat: Int(Double(food.fat) * quantity)
                    )
                }
            }
            
            // If still not found, try without size prefix
            if macros == nil {
                foundFood = FoodDatabase.findFood(foodName)
                if let food = foundFood {
                    macros = MacroBreakdown(
                        calories: Int(Double(food.calories) * quantity),
                        protein: Int(Double(food.protein) * quantity),
                        carbs: Int(Double(food.carbs) * quantity),
                        sugar: Int(Double(food.sugar) * quantity),
                        fat: Int(Double(food.fat) * quantity)
                    )
                }
            }
            
            // Look up food in database - use actual food name from database
            if let macros = macros, let food = foundFood {
                let displayName = food.name
                foods.append(ParsedFood(
                    name: displayName,
                    quantity: quantity,
                    macros: macros
                ))
            }
        }
        
        return foods
    }
    
    private static func parseQuantity(from text: String) -> (Double, String) {
        var text = text.lowercased()
        var quantity: Double = 1.0
        
        // Number patterns
        let numberPatterns = [
            (#"(\d+\.?\d*)\s*(cup|cup of|cups|cups of)"#, 1.0),
            (#"(\d+\.?\d*)\s*(glass|glass of|glasses|glasses of)"#, 1.0),
            (#"(\d+\.?\d*)\s*(piece|pieces)"#, 1.0),
            (#"(\d+\.?\d*)\s*(slice|slices)"#, 1.0),
            (#"(\d+\.?\d*)\s*(oz|ounce|ounces)"#, 1.0),
            (#"(\d+\.?\d*)"#, 1.0),
        ]
        
        for (pattern, multiplier) in numberPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text),
               let num = Double(text[range]) {
                quantity = num * multiplier
                // Remove matched pattern from text
                let matchedRange = match.range
                if let matchedTextRange = Range(matchedRange, in: text) {
                    text = text.replacingCharacters(in: matchedTextRange, with: "")
                }
                break
            }
        }
        
        // Word patterns
        let wordNumbers: [String: Double] = [
            "one": 1.0,
            "two": 2.0,
            "three": 3.0,
            "four": 4.0,
            "five": 5.0,
            "six": 6.0,
            "seven": 7.0,
            "eight": 8.0,
            "nine": 9.0,
            "ten": 10.0,
            "a ": 1.0,
            "an ": 1.0,
            "half": 0.5,
            "quarter": 0.25
        ]
        
        for (word, num) in wordNumbers {
            if text.contains(word) {
                quantity = num
                text = text.replacingOccurrences(of: word, with: "", options: .caseInsensitive)
                break
            }
        }
        
        // Check for "cup" or "cups" without number (default to 1)
        if text.contains("cup") && quantity == 1.0 {
            quantity = 1.0
        }
        
        return (quantity, text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private static func parseWorkouts(from text: String) -> [ParsedWorkout] {
        var workouts: [ParsedWorkout] = []
        let normalized = text.lowercased()
        
        // Split by common conjunctions
        let separators = [" and ", ", ", " plus ", " with ", " then "]
        var parts = [normalized]
        
        for separator in separators {
            var newParts: [String] = []
            for part in parts {
                newParts.append(contentsOf: part.components(separatedBy: separator))
            }
            parts = newParts
        }
        
        for part in parts {
            let cleaned = part.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse cardio workouts
            if let cardio = parseCardio(from: cleaned) {
                workouts.append(cardio)
            }
            
            // Parse strength workouts
            if let strength = parseStrength(from: cleaned) {
                workouts.append(strength)
            }
        }
        
        return workouts
    }
    
    private static func parseCardio(from text: String) -> ParsedWorkout? {
        let normalized = text.lowercased()
        
        // Cardio keywords
        let cardioKeywords: [(CardioType, [String])] = [
            (.run, ["ran", "run", "running", "jogged", "jogging"]),
            (.bike, ["biked", "bike", "biking", "cycled", "cycling"]),
            (.swim, ["swam", "swim", "swimming"]),
            (.walk, ["walked", "walk", "walking"]),
            (.elliptical, ["elliptical"]),
            (.row, ["rowed", "row", "rowing"])
        ]
        
        var cardioType: CardioType? = nil
        var duration: Int? = nil
        var distance: Double? = nil
        var isComplete = false
        
        // Check for generic "cardio" keyword
        if normalized.contains("cardio") {
            // Default to run if no specific type mentioned
            cardioType = .run
        }
        
        // Check for specific cardio types
        for (type, keywords) in cardioKeywords {
            for keyword in keywords {
                if normalized.contains(keyword) {
                    cardioType = type
                    isComplete = true
                    break
                }
            }
            if cardioType != nil { break }
        }
        
        // If no cardio type found, return nil
        guard let type = cardioType else {
            return nil
        }
        
        // Parse duration: "30 minutes", "30 min", "half hour"
        let durationPatterns = [
            (#"(\d+)\s*(minutes?|mins?|min)"#, 1),
            (#"half\s*hour"#, 30),
            (#"(\d+)\s*hour"#, 60)
        ]
        
        for (pattern, multiplier) in durationPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: normalized, range: NSRange(normalized.startIndex..., in: normalized)) {
                if pattern.contains("half") {
                    duration = 30
                } else if let range = Range(match.range(at: 1), in: normalized),
                          let minutes = Int(normalized[range]) {
                    duration = minutes * multiplier
                }
                break
            }
        }
        
        // Parse distance: "2 miles", "3 mi", "5 km"
        let distancePatterns = [
            (#"(\d+\.?\d*)\s*(miles?|mi\b)"#, 1.0),
            (#"(\d+\.?\d*)\s*(kilometers?|km\b)"#, 0.621371) // Convert km to miles
        ]
        
        for (pattern, multiplier) in distancePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: normalized, range: NSRange(normalized.startIndex..., in: normalized)),
               let range = Range(match.range(at: 1), in: normalized),
               let dist = Double(normalized[range]) {
                distance = dist * multiplier
                break
            }
        }
        
        // Check for completion verbs
        let completionVerbs = ["completed", "did", "finished", "ran", "biked", "swam", "walked"]
        if !isComplete {
            isComplete = completionVerbs.contains { normalized.contains($0) }
        }
        
        return ParsedWorkout(
            type: .cardio,
            cardioType: type,
            duration: duration,
            distance: distance,
            isComplete: isComplete
        )
    }
    
    private static func parseStrength(from text: String) -> ParsedWorkout? {
        let normalized = text.lowercased()
        
        // Strength exercise keywords
        let exerciseKeywords: [(StrengthExercise, [String])] = [
            (.pushUps, ["push-ups", "pushups", "push ups", "push-up"]),
            (.squats, ["squats", "squat"]),
            (.deadlifts, ["deadlifts", "deadlift"]),
            (.benchPress, ["bench press", "bench"]),
            (.pullUps, ["pull-ups", "pullups", "pull ups", "pull-up"]),
            (.lunges, ["lunges", "lunge"]),
            (.plank, ["plank", "planks"])
        ]
        
        var strengthExercise: StrengthExercise? = nil
        var sets: Int? = nil
        var reps: Int? = nil
        var isComplete = false
        
        // Check for generic "strength" keyword
        if normalized.contains("strength") || normalized.contains("strength workout") {
            // Default to squats if no specific exercise mentioned
            strengthExercise = .squats
        }
        
        // Check for specific exercises
        for (exercise, keywords) in exerciseKeywords {
            for keyword in keywords {
                if normalized.contains(keyword) {
                    strengthExercise = exercise
                    isComplete = true
                    break
                }
            }
            if strengthExercise != nil { break }
        }
        
        // If no exercise found, return nil
        guard let exercise = strengthExercise else {
            return nil
        }
        
        // Parse sets and reps: "3 sets of 12", "4 sets × 15 reps", "3x12"
        let setsRepsPatterns = [
            (#"(\d+)\s*sets?\s*(of|×|\*)\s*(\d+)\s*(reps?|rep)"#, (1, 3)), // "3 sets of 12 reps"
            (#"(\d+)\s*(×|\*)\s*(\d+)"#, (1, 3)), // "3x12" or "3*12"
            (#"(\d+)\s*sets?"#, (1, nil)) // Just sets
        ]
        
        for (pattern, indices) in setsRepsPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: normalized, range: NSRange(normalized.startIndex..., in: normalized)) {
                if let setsRange = Range(match.range(at: indices.0), in: normalized),
                   let setsValue = Int(normalized[setsRange]) {
                    sets = setsValue
                    
                    if let repsIndex = indices.1,
                       let repsRange = Range(match.range(at: repsIndex), in: normalized),
                       let repsValue = Int(normalized[repsRange]) {
                        reps = repsValue
                    }
                }
                break
            }
        }
        
        // Check for completion verbs
        let completionVerbs = ["completed", "did", "finished"]
        if !isComplete {
            isComplete = completionVerbs.contains { normalized.contains($0) }
        }
        
        return ParsedWorkout(
            type: .strength,
            strengthExercise: exercise,
            sets: sets,
            reps: reps,
            isComplete: isComplete
        )
    }
}

