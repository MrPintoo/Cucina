import Foundation

enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten Free"
    case dairyFree = "Dairy Free"
    case nutFree = "Nut Free"
    case kosher = "Kosher"
    case halal = "Halal"
}

enum SpiceLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case medium = "Medium"
    case spicy = "Spicy"
    case extraSpicy = "Extra Spicy"
}

enum HealthGoal: String, Codable, CaseIterable {
    case weightLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    case heartHealth = "Heart Health"
    case diabetesFriendly = "Diabetes Friendly"
    case generalWellness = "General Wellness"
    case lowCarb = "Low Carb"
    case highProtein = "High Protein"
}

struct UserPreferences: Codable {
    var dietaryRestrictions: [DietaryRestriction]
    var cuisinePreferences: [String]
    var spiceLevel: SpiceLevel
    var healthGoals: [HealthGoal]
    
    init(dietaryRestrictions: [DietaryRestriction] = [],
         cuisinePreferences: [String] = [],
         spiceLevel: SpiceLevel = .medium,
         healthGoals: [HealthGoal] = []) {
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
        self.spiceLevel = spiceLevel
        self.healthGoals = healthGoals
    }
} 