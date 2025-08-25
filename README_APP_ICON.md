# Undercover App Icon Implementation Guide

## Overview

This guide provides instructions for implementing a new app icon for your Undercover game, based on the design from your splash screen. The splash screen features a white rounded square with a purple theater comedy icon, which we'll use as the basis for your app icon.

## Files Created

1. `copy_existing_icons.sh/.bat` - Copy Android icons from assets
2. `copy_ios_icons.sh` - Copy iOS icons from assets
3. `update_app_icons.sh/.bat` - Copy generated icons to correct locations
4. `verify_icons.sh` - Verification script to check if all icons are in place
5. `README_APP_ICON.md` - This guide
6. `ICON_IMPLEMENTATION_COMPLETE.md` - Completion summary

## Implementation Steps

### Using Your Existing Assets (Recommended)

You've already added the following icon files to `assets/images`:
- `assets/images/android/` - Contains Android icons in various resolutions
- `assets/images/ios/` - Contains iOS icons in various resolutions

To copy these icons to the correct locations in your Flutter project:

1. **For Android**, run:
   ```bash
   ./copy_existing_icons.sh
   ```

2. **For iOS**, run:
   ```bash
   ./copy_ios_icons.sh
   ```

3. **To verify all icons are in place**, run:
   ```bash
   ./verify_icons.sh
   ```

## App Icon Design Specifications

Your app icon is based on your splash screen design with these specifications:

1. **Shape**: White rounded square
   - Corner radius: 25% of the icon size (e.g., 256px for a 1024px icon)
   - No shadow or border effects

2. **Icon**: Theater Comedy (Material Icons)
   - Color: #6366F1 (Indigo)
   - Size: 50% of the icon dimensions (e.g., 512px for a 1024px icon)

3. **Background**: Solid white (#FFFFFF)

## Troubleshooting

If you encounter issues:

1. **Icon not updating on device**: 
   - Uninstall the app completely before installing the new version
   - Clear your device's icon cache (device-specific process)

2. **Wrong icon size**:
   - Verify that each icon file matches the required dimensions
   - Check that the file names match exactly

3. **iOS build errors**:
   - Ensure all required icon sizes are present in the AppIcon.appiconset
   - Check the Contents.json file in the appiconset directory

4. **Android build errors**:
   - Verify that all mipmap directories contain the correctly sized icons
   - Check that the file names match exactly

## Additional Resources

For any questions or issues, refer to the detailed instructions in `ICON_IMPLEMENTATION_COMPLETE.md`.

## Creating Multiple Sized Versions

You have several options for creating the various sized versions of your icon:

### Option A: Use Online Tools (Recommended)
Upload your base icon (1024x1024) to one of these services:
- https://appicon.co/
- https://makeappicon.com/
- https://www.favicon-generator.org/

### Option B: Use the Python Script
1. Install the required dependency:
   ```
   pip install Pillow
   ```

2. Run the script to generate all icon sizes:
   ```
   python generate_icons.py output/app_icon.png generated_icons
   ```

### Option C: Use Android Studio
1. Open your project in Android Studio
2. Right-click on `android/app/src/main/res` in the project view
3. Select "New" > "Image Asset"
4. Configure the asset studio with your icon

## Replacing Existing Icons

### For Android:
Replace the icons in these directories:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### For iOS:
Replace the images in:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

You can use the provided scripts to automate this process:
- On Linux/Mac: `./update_app_icons.sh generated_icons`
- On Windows: `update_app_icons.bat generated_icons`

## Testing Your Changes

Rebuild your app to see the new icon:
```
flutter clean
flutter pub get
flutter build
```

## App Icon Design Specifications

Your app icon is based on your splash screen design with these specifications:

1. **Shape**: White rounded square
   - Corner radius: 25% of the icon size (e.g., 256px for a 1024px icon)
   - No shadow or border effects

2. **Icon**: Theater Comedy (Material Icons)
   - Color: #6366F1 (Indigo)
   - Size: 50% of the icon dimensions (e.g., 512px for a 1024px icon)

3. **Background**: Solid white (#FFFFFF)

## Troubleshooting

If you encounter issues:

1. **Icon not updating on device**: 
   - Uninstall the app completely before installing the new version
   - Clear your device's icon cache (device-specific process)

2. **Wrong icon size**:
   - Verify that each icon file matches the required dimensions
   - Check that the file names match exactly

3. **iOS build errors**:
   - Ensure all required icon sizes are present in the AppIcon.appiconset
   - Check the Contents.json file in the appiconset directory

4. **Android build errors**:
   - Verify that all mipmap directories contain the correctly sized icons
   - Check that the file names match exactly

5. **GStreamer dependency issues on Linux**:
   - Install the required packages as shown above
   - Alternatively, use the HTML/SVG approach instead

## Additional Resources

- Detailed instructions: `ICON_GENERATION.md`
- Design specifications: `APP_ICON_SPEC.md`
- iOS icon requirements: `ios_icon_spec.json`
- Android icon requirements: `android_icon_spec.json`

For any questions or issues, refer to the detailed instructions in `ICON_GENERATION.md`.