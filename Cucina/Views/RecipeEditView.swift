import SwiftUI
import PhotosUI

struct RecipeEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var recipeService = RecipeService.shared
    
    let recipe: Recipe?
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: [String] = [""]
    @State private var cookingTime: Int = 30
    @State private var servings: Int = 4
    @State private var difficulty: Difficulty = .medium
    @State private var category: Category = .dinner
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    
    init(recipe: Recipe? = nil) {
        self.recipe = recipe
        if let recipe = recipe {
            _name = State(initialValue: recipe.name)
            _description = State(initialValue: recipe.description)
            _ingredients = State(initialValue: recipe.ingredients)
            _instructions = State(initialValue: recipe.instructions)
            _cookingTime = State(initialValue: recipe.cookingTime)
            _servings = State(initialValue: recipe.servings)
            _difficulty = State(initialValue: recipe.difficulty)
            _category = State(initialValue: recipe.category)
            _tags = State(initialValue: recipe.tags)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                Section("Basic Information") {
                    TextField("Recipe Name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else {
                            Label("Add Photo", systemImage: "photo")
                        }
                    }
                }
                
                // Ingredients
                Section("Ingredients") {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Ingredient", text: $ingredients[index].name)
                            TextField("Amount", value: $ingredients[index].amount, format: .number)
                                .keyboardType(.decimalPad)
                            TextField("Unit", text: $ingredients[index].unit)
                            Button(action: { ingredients.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button(action: addIngredient) {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                }
                
                // Instructions
                Section("Instructions") {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.gray)
                            TextEditor(text: $instructions[index])
                                .frame(height: 60)
                            Button(action: { instructions.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button(action: addInstruction) {
                        Label("Add Step", systemImage: "plus.circle.fill")
                    }
                }
                
                // Details
                Section("Details") {
                    Stepper("Cooking Time: \(cookingTime) min", value: $cookingTime, in: 1...480)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...50)
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                // Tags
                Section("Tags") {
                    HStack {
                        TextField("New Tag", text: $newTag)
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagView(tag: tag) {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                }
            }
            .navigationTitle(recipe == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveRecipe() }
            )
            .onChange(of: selectedImage) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }
    
    private func addIngredient() {
        ingredients.append(Ingredient(name: "", amount: 0, unit: ""))
    }
    
    private func addInstruction() {
        instructions.append("")
    }
    
    private func addTag() {
        if !newTag.isEmpty && !tags.contains(newTag) {
            tags.append(newTag)
            newTag = ""
        }
    }
    
    private func saveRecipe() {
        let newRecipe = Recipe(
            id: recipe?.id ?? UUID(),
            name: name,
            description: description,
            ingredients: ingredients,
            instructions: instructions.filter { !$0.isEmpty },
            cookingTime: cookingTime,
            servings: servings,
            difficulty: difficulty,
            category: category,
            createdBy: "Current User", // TODO: Get actual user
            votes: recipe?.votes ?? 0,
            tags: tags
        )
        
        if recipe == nil {
            recipeService.addRecipe(newRecipe)
        } else {
            recipeService.updateRecipe(newRecipe)
        }
        
        dismiss()
    }
}

struct TagView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, spacing: spacing, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, spacing: spacing, subviews: subviews)
        for (index, line) in result.lines.enumerated() {
            let y = bounds.minY + result.lineOffsets[index]
            var x = bounds.minX
            
            for item in line {
                let position = CGPoint(x: x, y: y)
                subviews[item.index].place(at: position, proposal: .unspecified)
                x += item.size.width + spacing
            }
        }
    }
    
    private struct FlowResult {
        struct Item {
            let index: Int
            let size: CGSize
        }
        
        struct Line: Sequence {
            var items: [Item] = []
            var width: CGFloat = 0
            var height: CGFloat = 0
            
            func makeIterator() -> Array<Item>.Iterator {
                items.makeIterator()
            }
        }
        
        let lines: [Line]
        let lineOffsets: [CGFloat]
        let size: CGSize
        
        init(in maxWidth: CGFloat, spacing: CGFloat, subviews: Subviews) {
            var lines: [Line] = [Line()]
            var currentLine = 0
            var totalHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                let item = Item(index: index, size: size)
                
                if lines[currentLine].width + size.width + spacing <= maxWidth || lines[currentLine].items.isEmpty {
                    lines[currentLine].items.append(item)
                    lines[currentLine].width += size.width + (lines[currentLine].items.count > 1 ? spacing : 0)
                    lines[currentLine].height = max(lines[currentLine].height, size.height)
                } else {
                    currentLine += 1
                    lines.append(Line(items: [item], width: size.width, height: size.height))
                }
                
                maxWidth = max(maxWidth, lines[currentLine].width)
            }
            
            var offsets: [CGFloat] = []
            var currentOffset: CGFloat = 0
            
            for line in lines {
                offsets.append(currentOffset)
                currentOffset += line.height + spacing
                totalHeight += line.height + spacing
            }
            
            self.lines = lines
            self.lineOffsets = offsets
            self.size = CGSize(width: maxWidth, height: max(0, totalHeight - spacing))
        }
    }
}

#Preview {
    RecipeEditView()
} 
