#!/bin/bash
# copy_existing_icons.sh
# Script to copy your existing icon assets to the correct locations

echo "Copying existing icon assets to the correct locations..."

# Define source and destination directories
ASSETS_DIR="./assets/images/android"
ANDROID_RES_DIR="./android/app/src/main/res"

# Create a function to copy files with error checking
copy_icon() {
    local src=$1
    local dest=$2
    local name=$3
    
    if [ -f "$src" ]; then
        # Create destination directory if it doesn't exist
        mkdir -p "$(dirname "$dest")"
        
        # Copy the file
        cp "$src" "$dest"
        echo "  ✓ Copied $name"
    else
        echo "  ✗ Warning: $src not found"
    fi
}

# Copy Android icons
echo "Copying Android icons..."
copy_icon "$ASSETS_DIR/Icon-mdpi-48x48.png" "$ANDROID_RES_DIR/mipmap-mdpi/ic_launcher.png" "mdpi icon"
copy_icon "$ASSETS_DIR/Icon-hdpi-72x72.png" "$ANDROID_RES_DIR/mipmap-hdpi/ic_launcher.png" "hdpi icon"
copy_icon "$ASSETS_DIR/Icon-xdpi-96x96.png" "$ANDROID_RES_DIR/mipmap-xhdpi/ic_launcher.png" "xhdpi icon"
copy_icon "$ASSETS_DIR/Icon-xxdpi-144x144.png" "$ANDROID_RES_DIR/mipmap-xxhdpi/ic_launcher.png" "xxhdpi icon"
copy_icon "$ASSETS_DIR/Icon-xxxdpi-192x192.png" "$ANDROID_RES_DIR/mipmap-xxxhdpi/ic_launcher.png" "xxxhdpi icon"

echo ""
echo "Android icons copied successfully!"
echo ""
echo "For iOS icons, you'll need to:"
echo "1. Run the copy_ios_icons.sh script"
echo "2. Or manually copy them to ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo ""
echo "After copying all icons, rebuild your app with:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter build"