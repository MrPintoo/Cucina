import SwiftUI

// MARK: - Main View
struct RecipeLibraryView: View {
    @StateObject private var recipeService = RecipeService.shared
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedDifficulty: Difficulty?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FilterBar(
                    selectedCategory: $selectedCategory,
                    selectedDifficulty: $selectedDifficulty
                )
                
                RecipeList(
                    recipes: filterRecipes(recipeService.recipes),
                    onDelete: deleteRecipe
                )
            }
            .searchable(text: $searchText, prompt: "Search recipes")
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddButton(showingAddRecipe: $showingAddRecipe)
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                RecipeEditView()
            }
        }
    }
    
    private func filterRecipes(_ recipes: [Recipe]) -> [Recipe] {
        recipes
            .filter { recipe in
                guard let category = selectedCategory else { return true }
                return recipe.category == category
            }
            .filter { recipe in
                guard let difficulty = selectedDifficulty else { return true }
                return recipe.difficulty == difficulty
            }
            .filter { recipe in
                guard !searchText.isEmpty else { return true }
                return recipe.name.localizedCaseInsensitiveContains(searchText) ||
                       recipe.description.localizedCaseInsensitiveContains(searchText) ||
                       recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        for index in offsets {
            let recipes = filterRecipes(recipeService.recipes)
            recipeService.deleteRecipe(recipes[index])
        }
    }
}

// MARK: - Filter Bar
struct FilterBar: View {
    @Binding var selectedCategory: Category?
    @Binding var selectedDifficulty: Difficulty?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                categoryMenu
                difficultyMenu
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var categoryMenu: some View {
        Menu {
            Button("All Categories") {
                selectedCategory = nil
            }
            ForEach(Category.allCases, id: \.self) { category in
                Button(category.rawValue) {
                    selectedCategory = category
                }
            }
        } label: {
            FilterChip(
                title: selectedCategory?.rawValue ?? "All Categories",
                systemImage: "tag"
            )
        }
    }
    
    private var difficultyMenu: some View {
        Menu {
            Button("All Difficulties") {
                selectedDifficulty = nil
            }
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                Button(difficulty.rawValue) {
                    selectedDifficulty = difficulty
                }
            }
        } label: {
            FilterChip(
                title: selectedDifficulty?.rawValue ?? "All Difficulties",
                systemImage: "chart.bar"
            )
        }
    }
}

// MARK: - Recipe List
struct RecipeList: View {
    let recipes: [Recipe]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRow(recipe: recipe)
                }
            }
            .onDelete(perform: onDelete)
        }
    }
}

// MARK: - Add Button
struct AddButton: View {
    @Binding var showingAddRecipe: Bool
    
    var body: some View {
        Button(action: { showingAddRecipe = true }) {
            Image(systemName: "plus")
        }
    }
}

// MARK: - Recipe Row
struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 16) {
            recipeImage
            recipeDetails
        }
        .padding(.vertical, 4)
    }
    
    private var recipeImage: some View {
        Group {
            if let imageURL = recipe.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(8)
    }
    
    private var recipeDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
            
            Text(recipe.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label("\(recipe.cookingTime) min", systemImage: "clock")
                Spacer()
                Label(recipe.difficulty.rawValue, systemImage: "chart.bar")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    RecipeLibraryView()
} 