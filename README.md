# Undercover Game

A party game where players try to identify the undercover player among them.

## Getting Started

This project is a Flutter application for the Undercover party game.

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Xcode for mobile development

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## App Icon Implementation

✅ **Complete!** The app now features custom icons based on the splash screen design.

### Design

The app icon features a white rounded square with a purple theater comedy icon (#6366F1), matching the splash screen design.

### Implementation Details

- **Android**: Icons in all required resolutions (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS**: Icons in all required sizes and scales for iPhone and iPad
- **Assets**: Source images stored in `assets/images/` for future updates

For detailed information about the icon implementation process, see:
- `ICON_IMPLEMENTATION_COMPLETE.md` - Summary of completed work
- `README_APP_ICON.md` - Implementation guide

## Project Structure

- `lib/` - Main source code
  - `core/` - Core functionality (themes, constants, utils)
  - `data/` - Data models and repositories
  - `presentation/` - UI screens and widgets
- `assets/` - Application assets
  - `audio/` - Sound files
  - `data/` - Game data and word packs
  - `images/` - Icon assets
  - `locales/` - Localization files
- `android/` - Android-specific code
- `ios/` - iOS-specific code

## Building the App

### For Android
```
flutter build apk
```

### For iOS
```
flutter build ios
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)