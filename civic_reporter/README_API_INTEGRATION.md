# API Integration Guide

## Overview
This Flutter app now includes complete API integration with your backend server. The integration includes authentication, report management, and real-time data synchronization.

## Files Added/Modified

### New API Files:
- `lib/api/api_config.dart` - API configuration and endpoints
- `lib/api/api_service.dart` - Core API service with HTTP methods
- `lib/models/report_model.dart` - Report data model
- `lib/services/report_service.dart` - Report-specific API calls
- `lib/providers/auth_provider.dart` - Authentication state management
- `lib/providers/report_provider.dart` - Report state management
- `lib/screens/create_report_screen.dart` - Example screen using API

### Modified Files:
- `lib/api/auth_service.dart` - Added backend integration methods
- `lib/main.dart` - Added provider setup
- `pubspec.yaml` - Added HTTP dependencies

## Setup Instructions

1. **Install Dependencies:**
   ```bash
   cd civic_reporter
   flutter pub get
   ```

2. **Update API Configuration:**
   Edit `lib/api/api_config.dart` and change the `baseUrl` to your backend server URL:
   ```dart
   static const String baseUrl = 'http://your-backend-url:3000/api';
   ```

3. **Backend Server:**
   Make sure your backend server is running on the configured URL.

## Usage Examples

### Authentication
```dart
// Register new user
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.register(
  email: 'user@example.com',
  password: 'password',
  name: 'John Doe',
  phone: '+1234567890',
);

// Login
final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password',
);

// Firebase authentication
final success = await authProvider.authenticateWithFirebase(
  name: 'John Doe',
  email: 'user@example.com',
  phone: '+1234567890',
);
```

### Report Management
```dart
// Create report
final reportProvider = Provider.of<ReportProvider>(context, listen: false);
final success = await reportProvider.createReport(
  title: 'Broken Street Light',
  description: 'Street light not working',
  category: 'Infrastructure',
  latitude: 28.6139,
  longitude: 77.2090,
  address: 'New Delhi, India',
  image: imageFile, // Optional
);

// Get all reports
await reportProvider.fetchAllReports();
final reports = reportProvider.reports;

// Get user reports
await reportProvider.fetchUserReports();
final userReports = reportProvider.userReports;

// Get nearby reports
await reportProvider.fetchNearbyReports(
  latitude: 28.6139,
  longitude: 77.2090,
  radius: 5.0,
);

// Upvote report
await reportProvider.upvoteReport(reportId);

// Update report status
await reportProvider.updateReportStatus(reportId);
```

### Using in Widgets
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return CircularProgressIndicator();
        }
        
        if (reportProvider.error != null) {
          return Text('Error: ${reportProvider.error}');
        }
        
        return ListView.builder(
          itemCount: reportProvider.reports.length,
          itemBuilder: (context, index) {
            final report = reportProvider.reports[index];
            return ListTile(
              title: Text(report.title),
              subtitle: Text(report.description),
              trailing: Text(report.status),
            );
          },
        );
      },
    );
  }
}
```

## API Endpoints Covered

### Authentication:
- POST `/auth/register` - Register new user
- POST `/auth/login` - Login user
- POST `/auth/firebase-auth` - Firebase authentication
- POST `/auth/refresh-token` - Refresh JWT token
- POST `/auth/logout` - Logout user
- GET `/auth/profile` - Get user profile

### Reports:
- POST `/reports/create-report` - Create new report (with image upload)
- GET `/reports/get-all-reports` - Get all reports
- GET `/reports/fetch-user-reports` - Get user's reports
- GET `/reports/nearby` - Get nearby reports
- POST `/reports/{id}/upvote-report` - Upvote a report
- PATCH `/reports/{id}/update-report-status-resolve` - Update report status

## Error Handling

The API service includes comprehensive error handling:
- Network errors
- Authentication errors
- Validation errors
- Server errors

Errors are propagated through the providers and can be displayed in the UI.

## State Management

The app uses Provider pattern for state management:
- `AuthProvider` - Manages authentication state
- `ReportProvider` - Manages report data and operations

## Security

- JWT tokens are automatically stored and included in authenticated requests
- Tokens are persisted using SharedPreferences
- Firebase authentication is integrated with backend authentication

## Next Steps

1. Replace mock data in existing screens with API calls
2. Add offline support with local database
3. Implement push notifications
4. Add image caching
5. Add pagination for large datasets

## Testing

Test the integration by:
1. Starting your backend server
2. Running the Flutter app
3. Creating a new account
4. Submitting a report
5. Viewing reports in the dashboard

The API calls will appear in your backend server logs.