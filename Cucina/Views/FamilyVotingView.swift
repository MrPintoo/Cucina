import SwiftUI

struct FamilyVotingView: View {
    @StateObject private var votingService = VotingService.shared
    @StateObject private var recipeService = RecipeService.shared
    @State private var showingCreatePoll = false
    @State private var selectedTimeFrame: TimeFrame = .today
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case thisWeek = "This Week"
        case upcoming = "Upcoming"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Frame Selector
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Active Polls
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Polls")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(votingService.getActivePolls()) { poll in
                                    PollCard(poll: poll)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Top Voted Recipes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Voted Recipes")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recipeService.getTopVotedRecipes()) { recipe in
                                    TopVotedRecipeCard(recipe: recipe)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Create Poll Button
                    Button(action: { showingCreatePoll = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Poll")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Family Voting")
            .sheet(isPresented: $showingCreatePoll) {
                CreatePollView()
            }
        }
    }
}

struct PollCard: View {
    let poll: Poll
    @StateObject private var recipeService = RecipeService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(poll.title)
                .font(.headline)
            
            Text(poll.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let recipe = recipeService.recipes.first(where: { $0.id == poll.options.first?.recipeId }) {
                RecipePreviewRow(recipe: recipe)
            }
            
            HStack {
                Text("\(poll.options.reduce(0) { $0 + $1.votes }) votes")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(poll.endsAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 300)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TopVotedRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = recipe.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 200, height: 150)
                .cornerRadius(8)
            }
            
            Text(recipe.name)
                .font(.headline)
            
            HStack {
                Label("\(recipe.votes)", systemImage: "heart.fill")
                    .foregroundColor(.red)
                Spacer()
                Text(recipe.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CreatePollView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var votingService = VotingService.shared
    @StateObject private var recipeService = RecipeService.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedRecipes: Set<UUID> = []
    @State private var duration: TimeInterval = 86400 // 24 hours
    @State private var showingRecipePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Poll Details") {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section("Duration") {
                    Picker("Duration", selection: $duration) {
                        Text("12 hours").tag(TimeInterval(43200))
                        Text("24 hours").tag(TimeInterval(86400))
                        Text("48 hours").tag(TimeInterval(172800))
                        Text("1 week").tag(TimeInterval(604800))
                    }
                }
                
                Section("Recipes") {
                    ForEach(Array(selectedRecipes), id: \.self) { recipeId in
                        if let recipe = recipeService.recipes.first(where: { $0.id == recipeId }) {
                            HStack {
                                RecipePreviewRow(recipe: recipe)
                                Spacer()
                                Button(action: { selectedRecipes.remove(recipeId) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: { showingRecipePicker = true }) {
                        Label("Add Recipe", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Create Poll")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Create") { createPoll() }
                    .disabled(title.isEmpty || selectedRecipes.isEmpty)
            )
            .sheet(isPresented: $showingRecipePicker) {
                RecipePickerView(selectedRecipes: $selectedRecipes)
            }
        }
    }
    
    private func createPoll() {
        let options = selectedRecipes.map { recipeId in
            PollOption(recipeId: recipeId, votes: 0)
        }
        
        votingService.createPoll(
            title: title,
            description: description,
            options: options,
            duration: duration,
            createdBy: "Current User" // TODO: Get actual user
        )
        
        dismiss()
    }
}

struct RecipePickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var recipeService = RecipeService.shared
    @Binding var selectedRecipes: Set<UUID>
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipeService.recipes
        }
        return recipeService.searchRecipes(query: searchText)
    }
    
    var body: some View {
        NavigationView {
            List(filteredRecipes) { recipe in
                HStack {
                    RecipePreviewRow(recipe: recipe)
                    Spacer()
                    if selectedRecipes.contains(recipe.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedRecipes.contains(recipe.id) {
                        selectedRecipes.remove(recipe.id)
                    } else {
                        selectedRecipes.insert(recipe.id)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes")
            .navigationTitle("Select Recipes")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct RecipePreviewRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageURL = recipe.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    FamilyVotingView()
} 
