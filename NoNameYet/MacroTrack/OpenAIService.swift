//
//  OpenAIService.swift
//  MacroTrack
//
//  Created by AI Assistant on 11/9/25.
//

import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // Load API key from Config.plist
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["OPENAI_API_KEY"] as? String else {
            fatalError("Config.plist not found or OPENAI_API_KEY missing")
        }
        self.apiKey = key
    }
    
    /// Parse natural language input for food/water/workout using OpenAI
    /// Returns ParsedResult compatible with existing CoachNotesParser structure
    func parseCoachInput(_ input: String) async throws -> ParsedResult {
        let availableFoods = FoodDatabase.foods
        let foodList = availableFoods.values.map { "- \($0.name)" }.joined(separator: "\n")
        
        let systemPrompt = """
        You are a fitness tracking assistant. Parse user input about food, water, and workouts.
        
        Available foods in database:
        \(foodList)
        
        IMPORTANT: User can mention multiple items in one message (e.g., "I ate a burger and fries and drank 2 glasses of water")
        
        Respond ONLY with valid JSON in this exact format:
        {
          "date": "today" | "yesterday" | "2 days ago",
          "foods": [
            {
              "name": "Food Name from database",
              "quantity": 1.0
            }
          ],
          "water_ounces": 0,
          "workouts": [
            {
              "type": "cardio" | "strength",
              "cardio_type": "Run" | "Bike" | "Swim" | "Walk" | "Elliptical" | "Row" | null,
              "strength_exercise": "Push Ups" | "Squats" | "Deadlifts" | "Bench Press" | "Pull Ups" | "Lunges" | "Plank" | null,
              "duration": 30,
              "distance": 2.5,
              "sets": 3,
              "reps": 12
            }
          ]
        }
        
        Rules:
        1. For FOOD: Match to database foods (fuzzy match ok, e.g., "big mac" -> "Big Mac"). Extract quantity (default 1.0). Can have multiple foods.
        2. For WATER: Extract ounces (8 oz per glass/cup). Sum all water mentioned.
        3. For WORKOUTS: Extract type, details, and duration/distance/sets/reps as mentioned.
        4. DATE: Default to "today" unless user says otherwise.
        5. Arrays can be empty [] if nothing mentioned.
        
        Examples:
        Input: "I ate 2 chicken breasts and a large fries"
        Output: {
          "date": "today",
          "foods": [
            {"name": "Chicken Breast", "quantity": 2.0},
            {"name": "Large Fries", "quantity": 1.0}
          ],
          "water_ounces": 0,
          "workouts": []
        }
        
        Input: "Had 3 glasses of water"
        Output: {
          "date": "today",
          "foods": [],
          "water_ounces": 24,
          "workouts": []
        }
        
        Input: "Ran 3 miles yesterday"
        Output: {
          "date": "yesterday",
          "foods": [],
          "water_ounces": 0,
          "workouts": [{
            "type": "cardio",
            "cardio_type": "Run",
            "strength_exercise": null,
            "duration": null,
            "distance": 3.0,
            "sets": null,
            "reps": null
          }]
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": input]
            ],
            "temperature": 0.3,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("OpenAI API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        // Parse the JSON response from OpenAI
        return try await parseOpenAIResponse(content)
    }
    
    private func parseOpenAIResponse(_ jsonString: String) async throws -> ParsedResult {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw OpenAIError.parsingError("Invalid JSON from AI")
        }
        
        // Parse date
        let dateString = json["date"] as? String ?? "today"
        let date = parseDateString(dateString)
        
        // Parse foods
        var parsedFoods: [ParsedFood] = []
        if let foodsArray = json["foods"] as? [[String: Any]] {
            for foodDict in foodsArray {
                if let name = foodDict["name"] as? String,
                   let quantity = foodDict["quantity"] as? Double {
                    
                    // Try database first
                    if let food = FoodDatabase.findFood(name) {
                        let macros = MacroBreakdown(
                            calories: Int(Double(food.calories) * quantity),
                            protein: Int(Double(food.protein) * quantity),
                            carbs: Int(Double(food.carbs) * quantity),
                            sugar: Int(Double(food.sugar) * quantity),
                            fat: Int(Double(food.fat) * quantity)
                        )
                        parsedFoods.append(ParsedFood(name: food.name, quantity: quantity, macros: macros))
                    } else {
                        // Fallback: Ask AI to estimate macros
                        print("Food '\(name)' not found in database, estimating macros...")
                        if let estimatedMacros = try? await estimateMacros(foodName: name, quantity: quantity) {
                            parsedFoods.append(ParsedFood(
                                name: "\(name) (est.)",
                                quantity: quantity,
                                macros: estimatedMacros
                            ))
                        } else {
                            print("Failed to estimate macros for '\(name)'")
                        }
                    }
                }
            }
        }
        
        // Parse water
        var parsedWater: ParsedWater? = nil
        if let waterOunces = json["water_ounces"] as? Int, waterOunces > 0 {
            parsedWater = ParsedWater(ounces: waterOunces)
        }
        
        // Parse workouts
        var parsedWorkouts: [ParsedWorkout] = []
        if let workoutsArray = json["workouts"] as? [[String: Any]] {
            for workoutDict in workoutsArray {
                if let typeString = workoutDict["type"] as? String {
                    if typeString == "cardio", let cardioTypeStr = workoutDict["cardio_type"] as? String {
                        let cardioType = CardioType(rawValue: cardioTypeStr) ?? .run
                        let duration = workoutDict["duration"] as? Int
                        let distance = workoutDict["distance"] as? Double
                        
                        parsedWorkouts.append(ParsedWorkout(
                            type: .cardio,
                            cardioType: cardioType,
                            duration: duration,
                            distance: distance,
                            isComplete: true
                        ))
                    } else if typeString == "strength", let exerciseStr = workoutDict["strength_exercise"] as? String {
                        let exercise = StrengthExercise(rawValue: exerciseStr) ?? .squats
                        let sets = workoutDict["sets"] as? Int
                        let reps = workoutDict["reps"] as? Int
                        
                        parsedWorkouts.append(ParsedWorkout(
                            type: .strength,
                            strengthExercise: exercise,
                            sets: sets,
                            reps: reps,
                            isComplete: true
                        ))
                    }
                }
            }
        }
        
        return ParsedResult(
            date: date,
            foods: parsedFoods,
            water: parsedWater,
            workouts: parsedWorkouts,
            rawText: jsonString
        )
    }
    
    /// Estimate macros for a food not in the database using OpenAI
    private func estimateMacros(foodName: String, quantity: Double) async throws -> MacroBreakdown {
        let prompt = """
        Estimate the nutritional macros for: \(quantity) serving(s) of \(foodName)
        
        Respond ONLY with valid JSON in this exact format:
        {
          "calories": 285,
          "protein": 12,
          "carbs": 36,
          "sugar": 4,
          "fat": 10
        }
        
        Base estimates on typical serving sizes for common foods. Be accurate and reasonable.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a nutrition expert. Provide accurate macro estimates based on typical serving sizes."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 150
        ]
        
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("OpenAI API Error in estimateMacros (\(httpResponse.statusCode)): \(errorMessage)")
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        // Parse the macro JSON from the AI response
        guard let macroData = content.data(using: .utf8),
              let macroJson = try? JSONSerialization.jsonObject(with: macroData) as? [String: Any],
              let calories = macroJson["calories"] as? Int,
              let protein = macroJson["protein"] as? Int,
              let carbs = macroJson["carbs"] as? Int,
              let sugar = macroJson["sugar"] as? Int,
              let fat = macroJson["fat"] as? Int else {
            throw OpenAIError.parsingError("Could not parse macro estimation from AI")
        }
        
        return MacroBreakdown(
            calories: calories,
            protein: protein,
            carbs: carbs,
            sugar: sugar,
            fat: fat
        )
    }
    
    private func parseDateString(_ dateString: String) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        switch dateString.lowercased() {
        case "yesterday":
            return calendar.date(byAdding: .day, value: -1, to: today) ?? today
        case "2 days ago", "two days ago":
            return calendar.date(byAdding: .day, value: -2, to: today) ?? today
        case "3 days ago", "three days ago":
            return calendar.date(byAdding: .day, value: -3, to: today) ?? today
        default:
            return today
        }
    }
}

enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .apiError(let statusCode, let message):
            return "API Error (\(statusCode)): \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}

