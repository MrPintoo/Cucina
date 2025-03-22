import Foundation
import SwiftUI

class RecipeService: ObservableObject {
    static let shared = RecipeService()
    private let coreDataManager = CoreDataManager.shared
    
    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private init() {
        loadRecipes()
    }
    
    private func loadRecipes() {
        recipes = coreDataManager.fetchRecipes()
    }
    
    func addRecipe(_ recipe: Recipe) {
        coreDataManager.createRecipe(recipe)
        loadRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe) {
        coreDataManager.updateRecipe(recipe)
        loadRecipes()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        coreDataManager.deleteRecipe(recipe)
        loadRecipes()
    }
    
    func getRecipe(id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }
    
    func searchRecipes(query: String) -> [Recipe] {
        recipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(query) ||
            recipe.description.localizedCaseInsensitiveContains(query) ||
            recipe.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func filterRecipes(category: String? = nil, difficulty: Difficulty? = nil) -> [Recipe] {
        recipes.filter { recipe in
            (category == nil || recipe.category.rawValue == category) &&
            (difficulty == nil || recipe.difficulty == difficulty)
        }
    }
    
    func getTopVotedRecipes(limit: Int = 5) -> [Recipe] {
        recipes.sorted { $0.votes > $1.votes }.prefix(limit).map { $0 }
    }
    
    func getRecipesByUser(_ userId: String) -> [Recipe] {
        recipes.filter { $0.createdBy == userId }
    }
    
    func getFavoriteRecipes(for userId: String) -> [Recipe] {
        recipes.filter { recipe in
            // TODO: Implement favorite recipes functionality
            false
        }
    }
    
    func addToFavorites(_ recipe: Recipe, for userId: String) {
        // TODO: Implement add to favorites functionality
    }
    
    func removeFromFavorites(_ recipe: Recipe, for userId: String) {
        // TODO: Implement remove from favorites functionality
    }
} 
