# Civic Issue Reporter

A Flutter application that allows citizens to report civic issues with photo upload, voice notes, and GPS location tracking.

## Features

- **User Authentication**: Email/password and phone OTP authentication
- **Profile Management**: Complete user profile with all required fields
- **Issue Reporting**: 
  - Mandatory photo upload (camera or gallery)
  - Optional description
  - Optional voice note recording
  - Automatic GPS location tagging
- **Dashboard**: View all reported issues with status tracking
- **Resolution Acknowledgment**: Users can acknowledge resolved issues
- **Map View**: Visual representation of all reported issues on a map

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase project
- Android Studio / Xcode for mobile development

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable the following services:
   - Authentication (Email/Password and Phone)
   - Firestore Database
   - Firebase Cloud Messaging
   - ~~Firebase Storage~~ (Optional - using local storage for now)

3. Download the configuration files:
   - For Android: Download `google-services.json` and place it in `android/app/`
   - For iOS: Download `GoogleService-Info.plist` and place it in `ios/Runner/`

4. Update the Firebase configuration in `lib/firebase_options.dart` with your project details:
   ```dart
   // Replace the placeholder values with your actual Firebase project configuration
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'your-actual-android-api-key',
     appId: 'your-actual-android-app-id',
     messagingSenderId: 'your-actual-sender-id',
     projectId: 'your-actual-project-id',
     storageBucket: 'your-actual-project-id.appspot.com',
   );
   ```

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd civic_reporter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── api/                    # API services
│   ├── auth_service.dart   # Authentication service
│   ├── database_service.dart # Firestore operations
│   └── storage_service.dart # Firebase Storage operations
├── models/                 # Data models
│   ├── user_model.dart     # User data model
│   └── issue_model.dart   # Issue data model
├── screens/               # UI screens
│   ├── auth/              # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── phone_auth_screen.dart
│   │   └── complete_profile_screen.dart
│   └── home/              # Main app screens
│       ├── home_screen.dart
│       ├── dashboard_screen.dart
│       ├── profile_screen.dart
│       ├── report_issue_screen.dart
│       └── map_view_screen.dart
├── services/              # App services
│   └── notification_service.dart
├── widgets/               # Reusable widgets
│   └── issue_card.dart
├── firebase_options.dart   # Firebase configuration
├── main.dart              # App entry point
└── wrapper.dart           # Auth state wrapper
```

### Permissions

The app requires the following permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
- INTERNET
- CAMERA
- RECORD_AUDIO
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- WRITE_EXTERNAL_STORAGE
- READ_EXTERNAL_STORAGE

**iOS** (`ios/Runner/Info.plist`):
- NSCameraUsageDescription
- NSMicrophoneUsageDescription
- NSLocationWhenInUseUsageDescription

### Usage

1. **Registration**: Users can register using email/password or phone number with OTP verification
2. **Profile Setup**: Complete profile information including full name, mobile number, email, and home address
3. **Report Issues**: 
   - Take a photo or select from gallery (mandatory)
   - Add optional description
   - Record optional voice note
   - GPS location is automatically captured
4. **Track Issues**: View all reported issues in the dashboard with their current status
5. **Acknowledge Resolution**: Confirm when issues are marked as resolved

### Status Flow

Issues follow this status progression:
- **Pending**: Newly reported issue
- **In Progress**: Issue is being addressed by authorities
- **Fixed**: Issue has been fixed by authorities (awaiting user confirmation)
- **Resolved**: User has acknowledged and confirmed the fix

### Technologies Used

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Messaging)
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Audio**: Record and AudioPlayers packages
- **Location**: Geolocator package
- **Image**: Image Picker package

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### License

This project is licensed under the MIT License.
