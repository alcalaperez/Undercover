# Wordpack System Documentation

## Overview
The Undercover game now supports multi-language wordpacks, allowing the game words to be displayed in the user's selected language. This system is extensible and automatically switches wordpacks when the user changes the interface language.

## Architecture

### Files Structure
```
assets/
├── data/
│   ├── word_pairs.json          # Legacy file (still exists for backwards compatibility)
│   └── wordpacks/               # New language-specific wordpacks
│       ├── en.json              # English wordpack
│       ├── es.json              # Spanish wordpack  
│       ├── fr.json              # French wordpack
│       ├── de.json              # German wordpack
│       └── zh.json              # Simplified Chinese wordpack
└── locales/                     # UI translation files
    ├── en.json
    ├── es.json
    ├── fr.json
    ├── de.json
    └── zh.json
```

### Key Components

#### 1. WordRepository (Enhanced)
- **Location**: `lib/data/repositories/word_repository.dart`
- **Changes**: 
  - Now loads language-specific wordpack files
  - Automatically listens for language changes
  - Falls back to English if requested language is unavailable
  - Provides methods to check language availability

#### 2. LocalizationService (Enhanced)
- **Location**: `lib/core/utils/localization_service.dart`
- **Changes**: 
  - Triggers wordpack updates when language changes
  - Works seamlessly with existing UI translation system

## Supported Languages

| Language | Code | Wordpack Available | UI Translations |
|----------|------|-------------------|-----------------|
| English | `en` | ✅ | ✅ |
| Spanish | `es` | ✅ | ✅ |
| French | `fr` | ✅ | ✅ |
| German | `de` | ✅ | ✅ |
| Chinese (Simplified) | `zh` | ✅ | ✅ |

## How It Works

### Automatic Language Switching
1. User changes language in settings
2. LocalizationService loads new UI translations
3. LocalizationService triggers language change event
4. WordRepository automatically switches to matching wordpack
5. Game uses new language words in next game session

### Fallback Mechanism
- If a requested language wordpack doesn't exist, the system falls back to English
- This ensures the game always has words available
- Fallback is logged for debugging purposes

## Wordpack Format

Each wordpack file follows this JSON structure:

```json
{
  "word_pairs": [
    {
      "civilianWord": "Word for civilians",
      "undercoverWord": "Similar word for undercovers", 
      "category": "Category name in target language",
      "difficulty": "easy|medium|hard"
    }
  ]
}
```

### Example Categories by Language
- **English**: Animals, Food, Objects, Places, Activities, Movies, Professions
- **Spanish**: Animales, Comida, Objetos, Lugares, Actividades, Películas, Profesiones  
- **French**: Animaux, Nourriture, Objets, Lieux, Activités, Films, Professions
- **German**: Tiere, Essen, Objekte, Orte, Aktivitäten, Filme, Berufe
- **Chinese**: 动物, 食物, 物品, 地点, 活动, 电影, 职业

## Adding New Languages

To add support for a new language:

1. **Create wordpack file**: 
   - Add `assets/data/wordpacks/{language_code}.json`
   - Translate all word pairs and categories
   - Maintain same difficulty levels and structure

2. **Add to supported languages**:
   - Update `LocalizationService.supportedLanguages` list
   - Add language name to `languageNames` map

3. **Create UI translations**:
   - Add `assets/locales/{language_code}.json` with UI translations

4. **Update assets in pubspec.yaml** (already configured):
   ```yaml
   assets:
     - assets/data/wordpacks/
     - assets/locales/
   ```

## API Reference

### WordRepository Methods

```dart
// Initialize with specific language
await WordRepository.instance.initialize('es');

// Switch language
await WordRepository.instance.switchLanguage('fr');

// Check if language is available
bool available = await WordRepository.instance.isLanguageAvailable('de');

// Get current language
String currentLang = WordRepository.instance.currentLanguage;

// Get available languages
List<String> languages = await WordRepository.instance.getAvailableLanguages();
```

## Testing

The system includes comprehensive tests in `test/wordpack_test.dart`:
- Tests loading different language wordpacks
- Tests language switching functionality
- Tests fallback to English for unavailable languages
- Tests language availability checking

Run tests with:
```bash
flutter test test/wordpack_test.dart
```

## Performance Notes

- Wordpacks are loaded on-demand and cached in memory
- Only one language wordpack is loaded at a time
- Language switching clears cache and reloads new wordpack
- Average wordpack size: ~10KB per language
- Loading time: <100ms on typical devices

## Future Enhancements

Potential improvements for the wordpack system:
1. **Community wordpacks**: Allow users to create/share custom wordpacks
2. **Difficulty-specific packs**: Separate wordpacks by difficulty level  
3. **Regional variants**: Support for regional word variations (e.g., en-US vs en-GB)
4. **Category filtering**: Enable/disable specific categories per language
5. **Dynamic loading**: Download wordpacks from server instead of bundling
6. **Word validation**: Check word similarity/difficulty automatically