import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showingEditSheet = false
    @State private var showingVoteSheet = false
    @State private var showingAISuggestions = false
    @State private var aiSuggestions: [String] = []
    @State private var isLoadingSuggestions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let imageURL = recipe.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 250)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Recipe Header
                    HStack {
                        Text(recipe.name)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: { showingVoteSheet = true }) {
                            Label("\(recipe.votes)", systemImage: "heart.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Recipe Info
                    HStack(spacing: 20) {
                        Label("\(recipe.cookingTime) min", systemImage: "clock")
                        Label("\(recipe.servings) servings", systemImage: "person.2")
                        Label(recipe.difficulty.rawValue, systemImage: "chart.bar")
                    }
                    .foregroundColor(.gray)
                    
                    // Description
                    Text(recipe.description)
                        .font(.body)
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients")
                            .font(.title2)
                            .bold()
                        
                        ForEach(recipe.ingredients, id: \.name) { ingredient in
                            HStack {
                                Text("•")
                                Text("\(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
                            }
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .font(.headline)
                                Text(instruction)
                            }
                        }
                    }
                    
                    // Tags
                    if !recipe.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                    
                    // AI Suggestions Button
                    Button(action: {
                        showingAISuggestions = true
                        loadAISuggestions()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Get AI Suggestions")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeEditView(recipe: recipe)
        }
        .sheet(isPresented: $showingVoteSheet) {
            VoteView(recipe: recipe)
        }
        .sheet(isPresented: $showingAISuggestions) {
            AISuggestionsView(suggestions: aiSuggestions, isLoading: isLoadingSuggestions)
        }
    }
    
    private func loadAISuggestions() {
        isLoadingSuggestions = true
        // TODO: Implement AI suggestions loading
        // This will be connected to AIService
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            aiSuggestions = [
                "Try adding a pinch of cinnamon for extra warmth",
                "Consider using whole wheat flour for added fiber",
                "Add fresh herbs at the end for more flavor"
            ]
            isLoadingSuggestions = false
        }
    }
}

struct VoteView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @State private var selectedRating = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Rate this recipe")
                    .font(.title2)
                
                HStack(spacing: 30) {
                    ForEach(1...5, id: \.self) { rating in
                        Image(systemName: rating <= selectedRating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                selectedRating = rating
                            }
                    }
                }
                
                Button(action: {
                    // TODO: Implement voting
                    dismiss()
                }) {
                    Text("Submit Rating")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}

struct AISuggestionsView: View {
    let suggestions: [String]
    let isLoading: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading suggestions...")
                } else {
                    List(suggestions, id: \.self) { suggestion in
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.blue)
                            Text(suggestion)
                        }
                    }
                }
            }
            .navigationTitle("AI Suggestions")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    NavigationView {
        RecipeDetailView(recipe: Recipe(
            name: "Grandma's Apple Pie",
            description: "A classic apple pie recipe passed down through generations",
            ingredients: [
                Ingredient(name: "Apples", amount: 6, unit: "medium"),
                Ingredient(name: "Sugar", amount: 1, unit: "cup"),
                Ingredient(name: "Cinnamon", amount: 1, unit: "tsp")
            ],
            instructions: [
                "Preheat oven to 375°F",
                "Peel and slice apples",
                "Mix with sugar and cinnamon",
                "Bake for 45 minutes"
            ],
            cookingTime: 60,
            servings: 8,
            difficulty: .medium,
            category: .dessert,
            createdBy: "Grandma"
        ))
    }
} 