import Foundation

struct FoodItem {
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let sugar: Int
    let fat: Int
    let servingSize: String
    
    var macros: MacroBreakdown {
        MacroBreakdown(calories: calories, protein: protein, carbs: carbs, sugar: sugar, fat: fat)
    }
}

struct FoodDatabase {
    static let foods: [String: FoodItem] = [
        // Fruits
        "banana": FoodItem(name: "Banana", calories: 105, protein: 1, carbs: 27, sugar: 14, fat: 0, servingSize: "1 medium"),
        "apple": FoodItem(name: "Apple", calories: 95, protein: 0, carbs: 25, sugar: 19, fat: 0, servingSize: "1 medium"),
        "orange": FoodItem(name: "Orange", calories: 62, protein: 1, carbs: 15, sugar: 12, fat: 0, servingSize: "1 medium"),
        "strawberry": FoodItem(name: "Strawberries", calories: 49, protein: 1, carbs: 12, sugar: 7, fat: 0, servingSize: "1 cup"),
        "grapes": FoodItem(name: "Grapes", calories: 104, protein: 1, carbs: 27, sugar: 23, fat: 0, servingSize: "1 cup"),
        
        // Proteins
        "chicken": FoodItem(name: "Chicken Breast", calories: 231, protein: 43, carbs: 0, sugar: 0, fat: 5, servingSize: "1 breast"),
        "chicken breast": FoodItem(name: "Chicken Breast", calories: 231, protein: 43, carbs: 0, sugar: 0, fat: 5, servingSize: "1 breast"),
        "chicken leg": FoodItem(name: "Chicken Leg", calories: 209, protein: 27, carbs: 0, sugar: 0, fat: 11, servingSize: "1 leg"),
        "chicken thigh": FoodItem(name: "Chicken Thigh", calories: 229, protein: 26, carbs: 0, sugar: 0, fat: 13, servingSize: "1 thigh"),
        "beef": FoodItem(name: "Beef", calories: 250, protein: 26, carbs: 0, sugar: 0, fat: 15, servingSize: "3 oz"),
        "ground beef": FoodItem(name: "Ground Beef", calories: 218, protein: 22, carbs: 0, sugar: 0, fat: 15, servingSize: "3 oz"),
        "pork": FoodItem(name: "Pork", calories: 206, protein: 22, carbs: 0, sugar: 0, fat: 12, servingSize: "3 oz"),
        "fish": FoodItem(name: "Fish", calories: 206, protein: 22, carbs: 0, sugar: 0, fat: 12, servingSize: "3 oz"),
        "salmon": FoodItem(name: "Salmon", calories: 206, protein: 22, carbs: 0, sugar: 0, fat: 13, servingSize: "3 oz"),
        "tuna": FoodItem(name: "Tuna", calories: 99, protein: 22, carbs: 0, sugar: 0, fat: 1, servingSize: "3 oz"),
        "eggs": FoodItem(name: "Eggs", calories: 72, protein: 6, carbs: 0, sugar: 0, fat: 5, servingSize: "1 large"),
        "egg": FoodItem(name: "Egg", calories: 72, protein: 6, carbs: 0, sugar: 0, fat: 5, servingSize: "1 large"),
        
        // Grains & Carbs
        "rice": FoodItem(name: "White Rice", calories: 205, protein: 4, carbs: 45, sugar: 0, fat: 0, servingSize: "1 cup cooked"),
        "brown rice": FoodItem(name: "Brown Rice", calories: 216, protein: 5, carbs: 45, sugar: 0, fat: 2, servingSize: "1 cup cooked"),
        "bread": FoodItem(name: "Bread", calories: 79, protein: 3, carbs: 15, sugar: 2, fat: 1, servingSize: "1 slice"),
        "pasta": FoodItem(name: "Pasta", calories: 221, protein: 8, carbs: 43, sugar: 1, fat: 1, servingSize: "1 cup cooked"),
        "potato": FoodItem(name: "Potato", calories: 164, protein: 4, carbs: 37, sugar: 2, fat: 0, servingSize: "1 medium"),
        "sweet potato": FoodItem(name: "Sweet Potato", calories: 103, protein: 2, carbs: 24, sugar: 7, fat: 0, servingSize: "1 medium"),
        "oats": FoodItem(name: "Oats", calories: 154, protein: 6, carbs: 28, sugar: 1, fat: 3, servingSize: "1 cup cooked"),
        "quinoa": FoodItem(name: "Quinoa", calories: 222, protein: 8, carbs: 39, sugar: 2, fat: 4, servingSize: "1 cup cooked"),
        
        // Vegetables
        "broccoli": FoodItem(name: "Broccoli", calories: 55, protein: 4, carbs: 11, sugar: 3, fat: 0, servingSize: "1 cup"),
        "spinach": FoodItem(name: "Spinach", calories: 7, protein: 1, carbs: 1, sugar: 0, fat: 0, servingSize: "1 cup"),
        "carrots": FoodItem(name: "Carrots", calories: 50, protein: 1, carbs: 12, sugar: 6, fat: 0, servingSize: "1 cup"),
        "lettuce": FoodItem(name: "Lettuce", calories: 5, protein: 0, carbs: 1, sugar: 1, fat: 0, servingSize: "1 cup"),
        "tomato": FoodItem(name: "Tomato", calories: 32, protein: 2, carbs: 7, sugar: 5, fat: 0, servingSize: "1 medium"),
        "onion": FoodItem(name: "Onion", calories: 64, protein: 2, carbs: 15, sugar: 7, fat: 0, servingSize: "1 cup"),
        
        // Dairy
        "milk": FoodItem(name: "Milk", calories: 103, protein: 8, carbs: 12, sugar: 12, fat: 2, servingSize: "1 cup"),
        "cheese": FoodItem(name: "Cheese", calories: 113, protein: 7, carbs: 1, sugar: 0, fat: 9, servingSize: "1 oz"),
        "yogurt": FoodItem(name: "Yogurt", calories: 154, protein: 13, carbs: 17, sugar: 17, fat: 4, servingSize: "1 cup"),
        "greek yogurt": FoodItem(name: "Greek Yogurt", calories: 100, protein: 17, carbs: 6, sugar: 4, fat: 0, servingSize: "1 cup"),
        
        // Nuts & Seeds
        "almonds": FoodItem(name: "Almonds", calories: 164, protein: 6, carbs: 6, sugar: 1, fat: 14, servingSize: "1 oz"),
        "peanut": FoodItem(name: "Peanuts", calories: 166, protein: 7, carbs: 6, sugar: 1, fat: 14, servingSize: "1 oz"),
        "peanut butter": FoodItem(name: "Peanut Butter", calories: 188, protein: 8, carbs: 7, sugar: 3, fat: 16, servingSize: "2 tbsp"),
        
        // Beverages
        "coffee": FoodItem(name: "Coffee", calories: 2, protein: 0, carbs: 0, sugar: 0, fat: 0, servingSize: "1 cup"),
        "orange juice": FoodItem(name: "Orange Juice", calories: 112, protein: 2, carbs: 26, sugar: 22, fat: 0, servingSize: "1 cup"),
        "apple juice": FoodItem(name: "Apple Juice", calories: 114, protein: 0, carbs: 28, sugar: 24, fat: 0, servingSize: "1 cup"),
        
        // Fast Food - McDonald's
        "mcdouble": FoodItem(name: "McDouble", calories: 400, protein: 22, carbs: 33, sugar: 7, fat: 19, servingSize: "1 sandwich"),
        "big mac": FoodItem(name: "Big Mac", calories: 563, protein: 25, carbs: 45, sugar: 9, fat: 30, servingSize: "1 sandwich"),
        "quarter pounder": FoodItem(name: "Quarter Pounder", calories: 520, protein: 25, carbs: 42, sugar: 10, fat: 26, servingSize: "1 sandwich"),
        "mchicken": FoodItem(name: "McChicken", calories: 400, protein: 16, carbs: 40, sugar: 7, fat: 21, servingSize: "1 sandwich"),
        "chicken nuggets": FoodItem(name: "Chicken McNuggets", calories: 250, protein: 14, carbs: 15, sugar: 1, fat: 15, servingSize: "6 pieces"),
        "small fry": FoodItem(name: "Small Fries", calories: 230, protein: 3, carbs: 29, sugar: 0, fat: 11, servingSize: "1 small"),
        "medium fry": FoodItem(name: "Medium Fries", calories: 320, protein: 4, carbs: 43, sugar: 0, fat: 15, servingSize: "1 medium"),
        "large fry": FoodItem(name: "Large Fries", calories: 510, protein: 7, carbs: 66, sugar: 0, fat: 24, servingSize: "1 large"),
        "fries": FoodItem(name: "French Fries", calories: 320, protein: 4, carbs: 43, sugar: 0, fat: 15, servingSize: "1 medium"),
        "small fries": FoodItem(name: "Small Fries", calories: 230, protein: 3, carbs: 29, sugar: 0, fat: 11, servingSize: "1 small"),
        "medium fries": FoodItem(name: "Medium Fries", calories: 320, protein: 4, carbs: 43, sugar: 0, fat: 15, servingSize: "1 medium"),
        "large fries": FoodItem(name: "Large Fries", calories: 510, protein: 7, carbs: 66, sugar: 0, fat: 24, servingSize: "1 large"),
        "french fries": FoodItem(name: "French Fries", calories: 320, protein: 4, carbs: 43, sugar: 0, fat: 15, servingSize: "1 medium"),
        
        // Fast Food - Burger King
        "whopper": FoodItem(name: "Whopper", calories: 657, protein: 28, carbs: 49, sugar: 11, fat: 40, servingSize: "1 sandwich"),
        "whopper jr": FoodItem(name: "Whopper Jr", calories: 310, protein: 13, carbs: 26, sugar: 6, fat: 18, servingSize: "1 sandwich"),
        "chicken fries": FoodItem(name: "Chicken Fries", calories: 280, protein: 12, carbs: 23, sugar: 1, fat: 17, servingSize: "9 pieces"),
        
        // Fast Food - Generic
        "burger": FoodItem(name: "Burger", calories: 354, protein: 17, carbs: 33, sugar: 7, fat: 17, servingSize: "1 burger"),
        "cheeseburger": FoodItem(name: "Cheeseburger", calories: 313, protein: 15, carbs: 33, sugar: 7, fat: 13, servingSize: "1 burger"),
        "chicken sandwich": FoodItem(name: "Chicken Sandwich", calories: 470, protein: 28, carbs: 41, sugar: 6, fat: 21, servingSize: "1 sandwich"),
    ]
    
    static func findFood(_ searchTerm: String) -> FoodItem? {
        let normalized = searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct match
        if let food = foods[normalized] {
            return food
        }
        
        // Partial match - prioritize longer, more specific keys first
        // Sort keys by length (longest first) to match "cheeseburger" before "cheese"
        let sortedKeys = foods.keys.sorted { $0.count > $1.count }
        
        for key in sortedKeys {
            if let food = foods[key] {
                // Check if search term contains the key (exact substring match)
                if normalized.contains(key) {
                    return food
                }
            }
        }
        
        // Reverse check - check if any key contains the normalized search term
        // (for cases like "mcdouble" matching "mcdouble")
        for key in sortedKeys {
            if let food = foods[key] {
                if key.contains(normalized) {
                    return food
                }
            }
        }
        
        // Common variations
        let variations: [String: String] = [
            "chicken breast": "chicken",
            "chicken leg": "chicken leg",
            "chicken thigh": "chicken thigh",
            "baked chicken": "chicken",
            "grilled chicken": "chicken",
            "fried chicken": "chicken",
            "rice": "rice",
            "white rice": "rice",
            "cup of rice": "rice",
            "glass of water": "water",
            "water": "water"
        ]
        
        for (variation, foodKey) in variations {
            if normalized.contains(variation) {
                if let food = foods[foodKey] {
                    return food
                }
            }
        }
        
        return nil
    }
    
    static func getMacros(for foodName: String, quantity: Double) -> MacroBreakdown? {
        guard let food = findFood(foodName) else { return nil }
        
        return MacroBreakdown(
            calories: Int(Double(food.calories) * quantity),
            protein: Int(Double(food.protein) * quantity),
            carbs: Int(Double(food.carbs) * quantity),
            sugar: Int(Double(food.sugar) * quantity),
            fat: 0
        )
    }
}

