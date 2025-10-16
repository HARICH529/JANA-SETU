@echo off
echo Setting up Flutter cache on E drive...

echo Step 1: Deleting Flutter cache from C drive...
if exist "C:\Users\%USERNAME%\AppData\Local\Pub\Cache" (
    echo Deleting Pub cache...
    rmdir /s /q "C:\Users\%USERNAME%\AppData\Local\Pub\Cache"
)

if exist "C:\Users\%USERNAME%\.gradle" (
    echo Deleting Gradle cache...
    rmdir /s /q "C:\Users\%USERNAME%\.gradle"
)

echo Step 2: Setting Flutter cache environment variables to E drive...
set PUB_CACHE=E:\flutter-cache\pub
set GRADLE_USER_HOME=E:\flutter-cache\gradle
set FLUTTER_ROOT=E:\flutter-cache\flutter

echo Step 3: Creating cache directories on E drive...
mkdir E:\flutter-cache\pub 2>nul
mkdir E:\flutter-cache\gradle 2>nul
mkdir E:\flutter-cache\flutter 2>nul

echo Step 4: Setting environment variables permanently...
setx PUB_CACHE "E:\flutter-cache\pub"
setx GRADLE_USER_HOME "E:\flutter-cache\gradle"

echo Step 5: Cleaning Flutter project...
flutter clean

echo Step 6: Getting dependencies...
flutter pub get

echo Step 7: Running Flutter app...
flutter run

pause