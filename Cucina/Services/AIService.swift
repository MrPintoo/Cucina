import Foundation

class AIService {
    static let shared = AIService()
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // TODO: Load API key from secure storage
        self.apiKey = "YOUR_API_KEY"
    }
    
    func interpretRecipe(_ recipe: Recipe) async throws -> String {
        let prompt = """
        Analyze this recipe and provide insights:
        
        Name: \(recipe.name)
        Description: \(recipe.description)
        Ingredients: \(recipe.ingredients.map { "\($0.amount) \($0.unit) \($0.name)" }.joined(separator: ", "))
        Instructions: \(recipe.instructions.joined(separator: "\n"))
        
        Please provide:
        1. Nutritional information
        2. Cooking tips
        3. Potential variations
        4. Dietary considerations
        """
        
        let response = try await makeAPIRequest(prompt: prompt)
        return response
    }
    
    func suggestRecipes(basedOn preferences: UserPreferences) async throws -> [Recipe] {
        let prompt = """
        Suggest recipes based on these preferences:
        
        Dietary Restrictions: \(preferences.dietaryRestrictions.map { $0.rawValue }.joined(separator: ", "))
        Cuisine Preferences: \(preferences.cuisinePreferences.joined(separator: ", "))
        Spice Level: \(preferences.spiceLevel.rawValue)
        Health Goals: \(preferences.healthGoals.map { $0.rawValue }.joined(separator: ", "))
        
        Please provide 5 recipe suggestions in JSON format with the following structure:
        {
            "recipes": [
                {
                    "name": "Recipe Name",
                    "description": "Recipe Description",
                    "ingredients": [
                        {
                            "name": "Ingredient Name",
                            "amount": 1.0,
                            "unit": "unit"
                        }
                    ],
                    "instructions": ["Step 1", "Step 2"],
                    "category": "Category",
                    "difficulty": "Difficulty",
                    "servings": 4
                }
            ]
        }
        """
        
        let response = try await makeAPIRequest(prompt: prompt)
        if let data = response.data(using: .utf8),
           let recipeResponse = try? JSONDecoder().decode(RecipeResponse.self, from: data) {
            return recipeResponse.recipes.map { recipe in
                Recipe(
                    id: UUID(),
                    name: recipe.name,
                    description: recipe.description,
                    ingredients: recipe.ingredients,
                    instructions: recipe.instructions,
                    cookingTime: 0,
                    servings: recipe.servings,
                    difficulty: Difficulty(rawValue: recipe.difficulty) ?? .medium,
                    category: Category(rawValue: recipe.category) ?? Category.dinner,
                    createdBy: "AI",
//                    createdAt: Date(),
                    votes: 0,
                    tags: [],
                    imageURL: nil
                )
            }
        }
        return []
    }
    
    private func makeAPIRequest(prompt: String) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful cooking assistant."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.requestFailed
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenAIResponse.self, from: data)
        
        return result.choices.first?.message.content ?? ""
    }
    
    // Recipe Improvement Suggestions
    func getRecipeSuggestions(for recipe: Recipe, focus: RecipeFocus) async throws -> [String] {
        // TODO: Implement AI-powered recipe suggestions
        // This will analyze the recipe and provide suggestions based on the focus
        // (health, flavor, etc.)
        fatalError("Not implemented")
    }
    
    // Ingredient Substitutions
    func getIngredientSubstitutions(for ingredient: Ingredient) async throws -> [Ingredient] {
        // TODO: Implement AI-powered ingredient substitution suggestions
        // This will suggest alternative ingredients based on dietary restrictions
        // and nutritional goals
        fatalError("Not implemented")
    }
    
    // Recipe Personalization
    func personalizeRecipe(_ recipe: Recipe, for user: User) async throws -> Recipe {
        // TODO: Implement AI-powered recipe personalization
        // This will modify the recipe based on user preferences and dietary restrictions
        fatalError("Not implemented")
    }
}

enum RecipeFocus {
    case health
    case flavor
    case simplicity
    case cost
    case time
}

// MARK: - Models

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct RecipeResponse: Codable {
    let recipes: [RecipeSuggestion]
}

struct RecipeSuggestion: Codable {
    let name: String
    let description: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let category: String
    let difficulty: String
    let servings: Int
}

enum AIError: Error {
    case requestFailed
    case invalidResponse
} 
