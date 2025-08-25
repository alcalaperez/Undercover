#!/bin/bash
# verify_icons.sh
# Script to verify that all required icons are in place

echo "Verifying that all required icons are in place..."
echo ""

# Check Android icons
echo "Checking Android icons..."
ANDROID_RES_DIR="./android/app/src/main/res"
android_icons_ok=true

check_android_icon() {
    local path=$1
    local name=$2
    
    if [ -f "$path" ]; then
        echo "  ✓ $name found"
    else
        echo "  ✗ $name missing"
        android_icons_ok=false
    fi
}

check_android_icon "$ANDROID_RES_DIR/mipmap-mdpi/ic_launcher.png" "mdpi icon (48x48)"
check_android_icon "$ANDROID_RES_DIR/mipmap-hdpi/ic_launcher.png" "hdpi icon (72x72)"
check_android_icon "$ANDROID_RES_DIR/mipmap-xhdpi/ic_launcher.png" "xhdpi icon (96x96)"
check_android_icon "$ANDROID_RES_DIR/mipmap-xxhdpi/ic_launcher.png" "xxhdpi icon (144x144)"
check_android_icon "$ANDROID_RES_DIR/mipmap-xxxhdpi/ic_launcher.png" "xxxhdpi icon (192x192)"

if [ "$android_icons_ok" = true ]; then
    echo "  All Android icons are in place!"
else
    echo "  Some Android icons are missing!"
fi

echo ""

# Check iOS icons
echo "Checking iOS icons..."
IOS_APPICON_DIR="./ios/Runner/Assets.xcassets/AppIcon.appiconset"
ios_icons_ok=true

check_ios_icon() {
    local path=$1
    local name=$2
    
    if [ -f "$path" ]; then
        echo "  ✓ $name found"
    else
        echo "  ✗ $name missing"
        ios_icons_ok=false
    fi
}

check_ios_icon "$IOS_APPICON_DIR/Icon-App-20x20@1x.png" "20x20@1x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-20x20@2x.png" "20x20@2x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-20x20@3x.png" "20x20@3x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-29x29@1x.png" "29x29@1x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-29x29@2x.png" "29x29@2x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-29x29@3x.png" "29x29@3x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-40x40@1x.png" "40x40@1x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-40x40@2x.png" "40x40@2x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-40x40@3x.png" "40x40@3x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-60x60@2x.png" "60x60@2x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-60x60@3x.png" "60x60@3x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-76x76@1x.png" "76x76@1x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-76x76@2x.png" "76x76@2x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-83.5x83.5@2x.png" "83.5x83.5@2x"
check_ios_icon "$IOS_APPICON_DIR/Icon-App-1024x1024@1x.png" "1024x1024@1x"

if [ "$ios_icons_ok" = true ]; then
    echo "  All iOS icons are in place!"
else
    echo "  Some iOS icons are missing!"
fi

echo ""

# Overall result
if [ "$android_icons_ok" = true ] && [ "$ios_icons_ok" = true ]; then
    echo "✅ All icons are properly installed!"
    echo "You can now rebuild your app with:"
    echo "  flutter clean"
    echo "  flutter pub get"
    echo "  flutter build"
else
    echo "❌ Some icons are missing!"
    echo "Please check the output above and ensure all icons are in place."
fi