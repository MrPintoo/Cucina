import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var recipeService = RecipeService.shared
    @State private var showingEditProfile = false
    @State private var showingFamilySettings = false
    @State private var showingPreferences = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    
    // Sample user data (TODO: Replace with actual user data)
    @State private var user = User(
        name: "John Doe",
        email: "john@example.com",
        preferences: UserPreferences(
            dietaryRestrictions: [.vegetarian],
            cuisinePreferences: ["Italian", "Mexican"],
            spiceLevel: .medium,
            healthGoals: [.generalWellness]
        )
    )
    
    private var userRecipes: [Recipe] {
        recipeService.recipes.filter { $0.createdBy == user.name }
    }
    
    private var favoriteRecipes: [Recipe] {
        recipeService.recipes.filter { recipe in
            user.favoriteRecipes.contains(recipe.id)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                profileHeaderSection
                quickActionsSection
                myRecipesSection
                favoritesSection
                dietaryRestrictionsSection
                healthGoalsSection
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(user: $user, imageData: $imageData)
            }
            .sheet(isPresented: $showingFamilySettings) {
                FamilySettingsView()
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView(preferences: $user.preferences)
            }
        }
    }
    
    private var profileHeaderSection: some View {
        Section {
            HStack(spacing: 20) {
                profileImage
                profileInfo
            }
            .padding(.vertical, 8)
        }
    }
    
    private var profileImage: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    private var profileInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(user.name)
                .font(.title2)
                .bold()
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var quickActionsSection: some View {
        Section("Quick Actions") {
            Button(action: { showingEditProfile = true }) {
                Label("Edit Profile", systemImage: "pencil")
            }
            
            Button(action: { showingFamilySettings = true }) {
                Label("Family Settings", systemImage: "person.2")
            }
            
            Button(action: { showingPreferences = true }) {
                Label("Preferences", systemImage: "gear")
            }
        }
    }
    
    private var myRecipesSection: some View {
        Section("My Recipes") {
            ForEach(userRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipePreviewRow(recipe: recipe)
                }
            }
        }
    }
    
    private var favoritesSection: some View {
        Section("Favorites") {
            ForEach(favoriteRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipePreviewRow(recipe: recipe)
                }
            }
        }
    }
    
    private var dietaryRestrictionsSection: some View {
        Section("Dietary Restrictions") {
            ForEach(user.preferences.dietaryRestrictions, id: \.self) { restriction in
                Text(restriction.rawValue)
            }
        }
    }
    
    private var healthGoalsSection: some View {
        Section("Health Goals") {
            ForEach(user.preferences.healthGoals, id: \.self) { goal in
                Text(goal.rawValue)
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var user: User
    @Binding var imageData: Data?
    @State private var selectedImage: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                )
                        }
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label("Change Photo", systemImage: "photo")
                    }
                }
                
                Section {
                    TextField("Name", text: $user.name)
                    TextField("Email", text: $user.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { dismiss() }
            )
            .onChange(of: selectedImage) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }
}

struct FamilySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var familyCode = ""
    @State private var showingJoinFamily = false
    @State private var showingCreateFamily = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { showingJoinFamily = true }) {
                        Label("Join Family", systemImage: "person.badge.plus")
                    }
                    
                    Button(action: { showingCreateFamily = true }) {
                        Label("Create Family", systemImage: "person.3")
                    }
                }
                
                Section("Current Family") {
                    Text("No family joined")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Family Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .sheet(isPresented: $showingJoinFamily) {
                JoinFamilyView(familyCode: $familyCode)
            }
            .sheet(isPresented: $showingCreateFamily) {
                CreateFamilyView()
            }
        }
    }
}

struct JoinFamilyView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var familyCode: String
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Family Code", text: $familyCode)
                        .textInputAutocapitalization(.characters)
                }
                
                Section {
                    Button("Join Family") {
                        // TODO: Implement family joining
                        dismiss()
                    }
                    .disabled(familyCode.isEmpty)
                }
            }
            .navigationTitle("Join Family")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}

struct CreateFamilyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var familyName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Family Name", text: $familyName)
                }
                
                Section {
                    Button("Create Family") {
                        // TODO: Implement family creation
                        dismiss()
                    }
                    .disabled(familyName.isEmpty)
                }
            }
            .navigationTitle("Create Family")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}

struct PreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var preferences: UserPreferences
    
    var body: some View {
        NavigationView {
            Form {
                dietaryRestrictionsSection
                spiceLevelSection
                healthGoalsSection
            }
            .navigationTitle("Preferences")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var dietaryRestrictionsSection: some View {
        Section("Dietary Restrictions") {
            ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                DietaryRestrictionToggle(
                    restriction: restriction,
                    isSelected: preferences.dietaryRestrictions.contains(restriction),
                    onToggle: { isOn in
                        if isOn {
                            preferences.dietaryRestrictions.append(restriction)
                        } else {
                            preferences.dietaryRestrictions.removeAll { $0 == restriction }
                        }
                    }
                )
            }
        }
    }
    
    private var spiceLevelSection: some View {
        Section("Spice Level") {
            Picker("Spice Level", selection: $preferences.spiceLevel) {
                ForEach(SpiceLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
        }
    }
    
    private var healthGoalsSection: some View {
        Section("Health Goals") {
            ForEach(HealthGoal.allCases, id: \.self) { goal in
                HealthGoalToggle(
                    goal: goal,
                    isSelected: preferences.healthGoals.contains(goal),
                    onToggle: { isOn in
                        if isOn {
                            preferences.healthGoals.append(goal)
                        } else {
                            preferences.healthGoals.removeAll { $0 == goal }
                        }
                    }
                )
            }
        }
    }
}

struct DietaryRestrictionToggle: View {
    let restriction: DietaryRestriction
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Toggle(restriction.rawValue, isOn: Binding(
            get: { isSelected },
            set: onToggle
        ))
    }
}

struct HealthGoalToggle: View {
    let goal: HealthGoal
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Toggle(goal.rawValue, isOn: Binding(
            get: { isSelected },
            set: onToggle
        ))
    }
}

#Preview {
    ProfileView()
} 