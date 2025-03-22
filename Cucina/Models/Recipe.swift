import Foundation

struct Recipe: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var ingredients: [Ingredient]
    var instructions: [String]
    var cookingTime: Int // in minutes
    var servings: Int
    var difficulty: Difficulty
    var category: Category
    var createdBy: String
    var createdAt: Date
    var votes: Int
    var tags: [String]
    var imageURL: String?
    
    init(id: UUID = UUID(), name: String, description: String, ingredients: [Ingredient], 
         instructions: [String], cookingTime: Int, servings: Int, difficulty: Difficulty, 
         category: Category, createdBy: String, votes: Int = 0, tags: [String] = [], imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.cookingTime = cookingTime
        self.servings = servings
        self.difficulty = difficulty
        self.category = category
        self.createdBy = createdBy
        self.createdAt = Date()
        self.votes = votes
        self.tags = tags
        self.imageURL = imageURL
    }
}

struct Ingredient: Codable {
    var name: String
    var amount: Double
    var unit: String
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

enum Category: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case snack = "Snack"
    case appetizer = "Appetizer"
    case beverage = "Beverage"
} 
