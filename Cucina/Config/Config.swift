import Foundation

enum Config {
    enum OpenAI {
        static let apiKey = "YOUR_API_KEY" // TODO: Move to secure storage
        
        enum Endpoints {
            static let baseURL = "https://api.openai.com/v1"
            static let chatCompletions = "\(baseURL)/chat/completions"
        }
        
        enum Models {
            static let gpt4 = "gpt-4"
            static let gpt35Turbo = "gpt-3.5-turbo"
        }
    }
    
    enum App {
        static let name = "Cucina"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        enum Storage {
            static let maxImageSize: Int64 = 10 * 1024 * 1024 // 10MB
            static let supportedImageTypes = ["jpg", "jpeg", "png", "heic"]
        }
        
        enum UI {
            static let cornerRadius: CGFloat = 12
            static let padding: CGFloat = 16
            static let spacing: CGFloat = 8
        }
    }
    
    enum UserDefaults {
        static let userKey = "currentUser"
        static let preferencesKey = "userPreferences"
        static let lastSyncKey = "lastSyncDate"
    }
    
    enum Notifications {
        static let pollEnded = "pollEnded"
        static let recipeAdded = "recipeAdded"
        static let recipeUpdated = "recipeUpdated"
        static let recipeDeleted = "recipeDeleted"
    }
}