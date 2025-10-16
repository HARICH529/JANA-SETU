@echo off
echo Generating app launcher icons...

echo Installing flutter_launcher_icons...
flutter pub get

echo Generating icons from start-logo.png...
flutter pub run flutter_launcher_icons:main

echo Icons generated successfully!
echo Please rebuild the app to see the new icon.
pause