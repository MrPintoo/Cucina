import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var imageData: Data?
    var familyId: UUID?
    var favoriteRecipes: [UUID] // Recipe IDs
    var createdRecipes: [UUID] // Recipe IDs
    var preferences: UserPreferences
    
    init(id: UUID = UUID(),
         name: String,
         email: String,
         imageData: Data? = nil,
         preferences: UserPreferences = UserPreferences(),
         favoriteRecipes: [UUID] = [],
         familyId: UUID? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.imageData = imageData
        self.familyId = familyId
        self.favoriteRecipes = favoriteRecipes
        self.createdRecipes = []
        self.preferences = preferences
    }
}
