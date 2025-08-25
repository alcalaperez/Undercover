#!/bin/bash
# copy_ios_icons.sh
# Script to copy iOS icons from assets to the correct location

echo "Copying iOS icons from assets to the correct location..."

# Define source and destination directories
IOS_ASSETS_DIR="./assets/images/ios"
IOS_APPICON_DIR="./ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Create destination directory if it doesn't exist
mkdir -p "$IOS_APPICON_DIR"

# Function to copy files with error checking
copy_icon() {
    local src=$1
    local dest=$2
    local name=$3
    
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo "  ✓ Copied $name"
    else
        echo "  ✗ Warning: $src not found"
    fi
}

# Copy iOS icons based on the Contents.json requirements
echo "Copying iOS app icons..."
copy_icon "$IOS_ASSETS_DIR/Icon-20x20.png" "$IOS_APPICON_DIR/Icon-App-20x20@1x.png" "20x20@1x"
copy_icon "$IOS_ASSETS_DIR/Icon-40x40.png" "$IOS_APPICON_DIR/Icon-App-20x20@2x.png" "20x20@2x"
copy_icon "$IOS_ASSETS_DIR/Icon-60x60.png" "$IOS_APPICON_DIR/Icon-App-20x20@3x.png" "20x20@3x"
copy_icon "$IOS_ASSETS_DIR/Icon-29x29.png" "$IOS_APPICON_DIR/Icon-App-29x29@1x.png" "29x29@1x"
copy_icon "$IOS_ASSETS_DIR/Icon-58x58.png" "$IOS_APPICON_DIR/Icon-App-29x29@2x.png" "29x29@2x"
copy_icon "$IOS_ASSETS_DIR/Icon-87x87.png" "$IOS_APPICON_DIR/Icon-App-29x29@3x.png" "29x29@3x"
copy_icon "$IOS_ASSETS_DIR/Icon-40x40.png" "$IOS_APPICON_DIR/Icon-App-40x40@1x.png" "40x40@1x"
copy_icon "$IOS_ASSETS_DIR/Icon-80x80.png" "$IOS_APPICON_DIR/Icon-App-40x40@2x.png" "40x40@2x"
copy_icon "$IOS_ASSETS_DIR/Icon-120x120.png" "$IOS_APPICON_DIR/Icon-App-40x40@3x.png" "40x40@3x"
copy_icon "$IOS_ASSETS_DIR/Icon-120x120.png" "$IOS_APPICON_DIR/Icon-App-60x60@2x.png" "60x60@2x"
copy_icon "$IOS_ASSETS_DIR/Icon-180x180.png" "$IOS_APPICON_DIR/Icon-App-60x60@3x.png" "60x60@3x"
copy_icon "$IOS_ASSETS_DIR/Icon-76x76.png" "$IOS_APPICON_DIR/Icon-App-76x76@1x.png" "76x76@1x"
copy_icon "$IOS_ASSETS_DIR/Icon-152x152.png" "$IOS_APPICON_DIR/Icon-App-76x76@2x.png" "76x76@2x"
copy_icon "$IOS_ASSETS_DIR/Icon-167x167.png" "$IOS_APPICON_DIR/Icon-App-83.5x83.5@2x.png" "83.5x83.5@2x"
copy_icon "$IOS_ASSETS_DIR/Icon-1024x1024.png" "$IOS_APPICON_DIR/Icon-App-1024x1024@1x.png" "1024x1024@1x"

echo ""
echo "iOS icons copied successfully!"
echo ""
echo "To verify the icons were copied correctly, check the files in:"
echo "  $IOS_APPICON_DIR"
echo ""
echo "After copying all icons, rebuild your app with:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter build"