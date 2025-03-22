import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cucina")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load Core Data store: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Recipe Operations
    
    func createRecipe(_ recipe: Recipe) -> RecipeEntity {
        let entity = RecipeEntity(context: viewContext)
        entity.id = recipe.id
        entity.name = recipe.name
        entity.desc = recipe.description
        entity.instructions = try? JSONEncoder().encode(recipe.instructions)
        entity.category = recipe.category.rawValue
        entity.difficulty = recipe.difficulty.rawValue
        entity.servings = Int16(recipe.servings)
        entity.createdAt = recipe.createdAt
        entity.createdBy = recipe.createdBy
        entity.imageURL = recipe.imageURL
        entity.tags = try? JSONEncoder().encode(recipe.tags)
        entity.votes = Int32(recipe.votes)
        
        // Add ingredients
        for ingredient in recipe.ingredients {
            let ingredientEntity = IngredientEntity(context: viewContext)
            ingredientEntity.name = ingredient.name
            ingredientEntity.amount = ingredient.amount
            ingredientEntity.unit = ingredient.unit
            ingredientEntity.recipe = entity
        }
        
        saveContext()
        return entity
    }
    
    func fetchRecipes() -> [Recipe] {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecipeEntity.createdAt, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                Recipe(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    description: entity.desc ?? "",
                    ingredients: (entity.ingredients?.allObjects as? [IngredientEntity])?.map { ingredient in
                        Ingredient(
                            name: ingredient.name ?? "",
                            amount: ingredient.amount,
                            unit: ingredient.unit ?? ""
                        )
                    } ?? [],
                    instructions: (try? JSONDecoder().decode([String].self, from: entity.instructions ?? Data())) ?? [], cookingTime: 0,
                    servings: Int(entity.servings),
                    difficulty: Difficulty(rawValue: entity.difficulty ?? "") ?? .medium,
                    category: Category(rawValue: entity.category ?? "") ?? .dinner,
                    createdBy: entity.createdBy ?? "",
                    votes: Int(entity.votes),
                    tags: (try? JSONDecoder().decode([String].self, from: entity.tags ?? Data())) ?? [],
                    imageURL: entity.imageURL
                )
            }
        } catch {
            print("Error fetching recipes: \(error)")
            return []
        }
    }
    
    func updateRecipe(_ recipe: Recipe) {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.name = recipe.name
                entity.desc = recipe.description
                entity.instructions = try? JSONEncoder().encode(recipe.instructions)
                entity.category = recipe.category.rawValue
                entity.difficulty = recipe.difficulty.rawValue
                entity.servings = Int16(recipe.servings)
                entity.imageURL = recipe.imageURL
                entity.tags = try? JSONEncoder().encode(recipe.tags)
                entity.votes = Int32(recipe.votes)
                
                // Update ingredients
                if let ingredients = entity.ingredients?.allObjects as? [IngredientEntity] {
                    for ingredient in ingredients {
                        viewContext.delete(ingredient)
                    }
                }
                
                for ingredient in recipe.ingredients {
                    let ingredientEntity = IngredientEntity(context: viewContext)
                    ingredientEntity.name = ingredient.name
                    ingredientEntity.amount = ingredient.amount
                    ingredientEntity.unit = ingredient.unit
                    ingredientEntity.recipe = entity
                }
                
                saveContext()
            }
        } catch {
            print("Error updating recipe: \(error)")
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                viewContext.delete(entity)
                saveContext()
            }
        } catch {
            print("Error deleting recipe: \(error)")
        }
    }
    
    // MARK: - User Operations
    
    func createUser(_ user: User) -> UserEntity {
        let entity = UserEntity(context: viewContext)
        entity.id = user.id
        entity.name = user.name
        entity.email = user.email
//        entity.imageData = user.imageData
        entity.preferences = try? JSONEncoder().encode(user.preferences)
        
        saveContext()
        return entity
    }
    
    func fetchUser(id: UUID) -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                return User(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    email: entity.email ?? "",
//                    imageData: entity.imageData,
                    preferences: (try? JSONDecoder().decode(UserPreferences.self, from: entity.preferences ?? Data())) ?? UserPreferences()
                )
            }
        } catch {
            print("Error fetching user: \(error)")
        }
        return nil
    }
    
    func updateUser(_ user: User) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.name = user.name
                entity.email = user.email
//                entity.imageData = user.imageData
                entity.preferences = try? JSONEncoder().encode(user.preferences)
                
                saveContext()
            }
        } catch {
            print("Error updating user: \(error)")
        }
    }
    
    // MARK: - Poll Operations
    
    func createPoll(_ poll: Poll) -> PollEntity {
        let entity = PollEntity(context: viewContext)
        entity.id = poll.id
        entity.title = poll.title
        entity.desc = poll.description
        entity.createdAt = poll.createdAt
        entity.endsAt = poll.endsAt
        entity.status = poll.status.rawValue
        entity.createdBy = poll.createdBy
        
        // Add options
        for option in poll.options {
            let optionEntity = PollOptionEntity(context: viewContext)
            optionEntity.recipeId = option.recipeId
            optionEntity.votes = Int32(option.votes)
            optionEntity.poll = entity
        }
        
        saveContext()
        return entity
    }
    
    func fetchPolls() -> [Poll] {
        let request: NSFetchRequest<PollEntity> = PollEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PollEntity.createdAt, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                Poll(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    description: entity.desc ?? "",
                    options: (entity.options?.allObjects as? [PollOptionEntity])?.map { option in
                        PollOption(
                            recipeId: option.recipeId ?? UUID(),
                            votes: Int(option.votes)
                        )
                    } ?? [],
                    createdBy: entity.createdBy ?? "",
                    createdAt: entity.createdAt ?? Date(),
                    endsAt: entity.endsAt ?? Date(),
                    status: PollStatus(rawValue: entity.status ?? "") ?? .active
                )
            }
        } catch {
            print("Error fetching polls: \(error)")
            return []
        }
    }
    
    func updatePoll(_ poll: Poll) {
        let request: NSFetchRequest<PollEntity> = PollEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", poll.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                entity.title = poll.title
                entity.desc = poll.description
                entity.endsAt = poll.endsAt
                entity.status = poll.status.rawValue
                
                // Update options
                if let options = entity.options?.allObjects as? [PollOptionEntity] {
                    for option in options {
                        viewContext.delete(option)
                    }
                }
                
                for option in poll.options {
                    let optionEntity = PollOptionEntity(context: viewContext)
                    optionEntity.recipeId = option.recipeId
                    optionEntity.votes = Int32(option.votes)
                    optionEntity.poll = entity
                }
                
                saveContext()
            }
        } catch {
            print("Error updating poll: \(error)")
        }
    }
    
    func deletePoll(_ poll: Poll) {
        let request: NSFetchRequest<PollEntity> = PollEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", poll.id as CVarArg)
        
        do {
            if let entity = try viewContext.fetch(request).first {
                viewContext.delete(entity)
                saveContext()
            }
        } catch {
            print("Error deleting poll: \(error)")
        }
    }
} 
