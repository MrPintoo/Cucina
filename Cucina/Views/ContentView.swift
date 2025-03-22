import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            RecipeLibraryView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .tag(1)
            
            FamilyVotingView()
                .tabItem {
                    Label("Vote", systemImage: "checkmark.circle.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// Placeholder Views
struct HomeView: View {
    @StateObject private var recipeService = RecipeService.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    FeaturedRecipesView(recipes: recipeService.recipes)
                    TodaysVotesView()
                    RecipeSuggestionsView()

                }
                .padding()
            }
            .navigationTitle("Mi Cucina")
        }
    }
}

struct FeaturedRecipesView: View {
    let recipes: [Recipe]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Featured Recipes")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(recipes) { recipe in
                        RecipeCard(recipe: recipe)
                    }
                }
            }
        }
    }
}

struct TodaysVotesView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Votes")
                .font(.title2)
                .bold()
            
            // Placeholder for voting cards
            Text("No active votes")
                .foregroundColor(.gray)
        }
    }
}

struct RecipeSuggestionsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("AI Suggestions")
                .font(.title2)
                .bold()
            
            // Placeholder for AI suggestions
            Text("Loading suggestions...")
                .foregroundColor(.gray)
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 200, height: 150)
                .cornerRadius(10)
            
            Text(recipe.name)
                .font(.headline)
            
            Text("\(recipe.cookingTime) min • \(recipe.difficulty)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 200)
    }
}

#Preview {
    ContentView()
} 
