class ApiConfig {
  // Use ngrok URL for permanent access across networks
  static const String baseUrl = 'https://chromatolytic-unobsessed-therese.ngrok-free.dev/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String firebaseAuth = '/auth/firebase-auth';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // Report endpoints
  static const String createReport = '/reports/create-report';
  static const String getAllReports = '/reports/get-all-reports';
  static const String getUserReports = '/reports/fetch-user-reports';
  static const String nearbyReports = '/reports/nearby';
  static const String upvoteReport = '/reports';
  static const String updateReportStatus = '/reports';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  static Map<String, String> headersWithAuth(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      };
}
