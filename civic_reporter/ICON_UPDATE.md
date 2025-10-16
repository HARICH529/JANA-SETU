# App Icon Update Guide

## Quick Fix (Manual)
The app icon has been updated to use `start-logo.png`. The changes are already applied:

1. ✅ Added `start-logo.png` to `assets/` folder
2. ✅ Copied logo to `android/app/src/main/res/drawable/ic_launcher.png`
3. ✅ Updated `AndroidManifest.xml` to use drawable icon

## To Apply Changes:
1. **Clean and rebuild the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

2. **Install the new APK** to see the updated icon

## Alternative Method (Automated)
If you want to generate proper resolution icons:

1. **Run the icon generator:**
   ```bash
   generate_icons.bat
   ```

2. **Rebuild the app:**
   ```bash
   flutter clean
   flutter build apk
   ```

## Files Modified:
- `pubspec.yaml` - Added flutter_launcher_icons configuration
- `assets/start-logo.png` - App logo file
- `android/app/src/main/res/drawable/ic_launcher.png` - Android icon
- `android/app/src/main/AndroidManifest.xml` - Updated icon reference

## Result:
The app will now show the `start-logo.png` image as the launcher icon instead of the default exclamation mark with green background.