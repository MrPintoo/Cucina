# Cucina - AI-Powered Family Recipe Manager

Cucina is an iOS application that helps families manage recipes, plan meals, and make cooking decisions together using AI-powered features.

## Features

### Recipe Management
- Create, edit, and organize recipes with detailed information
- Add photos, ingredients, instructions, and tags
- Categorize recipes by type and difficulty
- Search and filter recipes
- AI-powered recipe analysis and suggestions

### Family Sharing
- Create and join family groups
- Share recipes with family members
- Collaborative meal planning
- Family voting system for meal decisions

### AI Integration
- Recipe interpretation and analysis
- Personalized recipe suggestions based on preferences
- Nutritional information and cooking tips
- Dietary considerations and variations

### User Experience
- Modern, intuitive interface
- Dark mode support
- Offline functionality with CoreData
- Secure data storage
- Push notifications for important updates

## Technical Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- OpenAI API key for AI features

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/cucina.git
```

2. Open the project in Xcode:
```bash
cd cucina
open Cucina.xcodeproj
```

3. Configure your OpenAI API key:
   - Open `Config.swift`
   - Replace `YOUR_API_KEY` with your actual OpenAI API key
   - For production, use secure storage methods

4. Build and run the project in Xcode

## Project Structure

```
Cucina/
├── App/
│   ├── CucinaApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Recipe.swift
│   ├── User.swift
│   └── Poll.swift
├── Views/
│   ├── RecipeLibraryView.swift
│   ├── RecipeDetailView.swift
│   ├── RecipeEditView.swift
│   ├── FamilyVotingView.swift
│   └── ProfileView.swift
├── Services/
│   ├── RecipeService.swift
│   ├── VotingService.swift
│   └── AIService.swift
├── Data/
│   ├── CoreDataManager.swift
│   └── Cucina.xcdatamodeld
└── Config/
    └── Config.swift
```

## Dependencies

- SwiftUI
- CoreData
- OpenAI API
- PhotosUI (for image selection)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for providing the GPT API
- Apple for SwiftUI and CoreData frameworks
- The open-source community for inspiration and resources

## Support

For support, please open an issue in the GitHub repository or contact the maintainers. 