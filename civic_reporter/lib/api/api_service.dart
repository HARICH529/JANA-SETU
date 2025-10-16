import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      print('🌐 Making $method request to: $url');
      print('📦 Request body: $body');
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        final token = await getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          throw Exception('Authentication required but no token found');
        }
      }

      print('📋 Headers: $headers');

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 10));
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 10));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        print('✅ Success response: $data');
        return data;
      } catch (e) {
        print('❌ JSON decode error: $e');
        throw Exception('Invalid JSON response');
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        final errorMsg = data['error'] ?? data['message'] ?? 'Request failed';
        print('❌ Error response: $errorMsg');
        throw Exception(errorMsg);
      } catch (e) {
        print('❌ Error parsing response: $e');
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    return await _makeRequest('POST', ApiConfig.register, body: {
      'email': email,
      'password': password,
      'name': name,
      'mobile': phone,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest('POST', ApiConfig.login, body: {
      'email': email,
      'password': password,
    });
    
    if (response['data']?['accessToken'] != null) {
      await setToken(response['data']['accessToken']);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> firebaseAuth({
    required String idToken,
    required String name,
    required String email,
    String? phone,
  }) async {
    final response = await _makeRequest('POST', ApiConfig.firebaseAuth, body: {
      'idToken': idToken,
      'name': name,
      'email': email,
      'mobile': phone,
    });
    
    if (response['data']?['accessToken'] != null) {
      await setToken(response['data']['accessToken']);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await _makeRequest('POST', ApiConfig.logout, requiresAuth: true);
    await clearToken();
    return response;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _makeRequest('GET', ApiConfig.profile, requiresAuth: true);
    if (response['success'] == true && response['data'] != null) {
      return response['data']['user'];
    }
    return response;
  }

  // Report methods
  Future<Map<String, dynamic>> createReport({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required String address,
    File? image,
    File? voice,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No auth token');

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createReport}');
      final request = http.MultipartRequest('POST', url);
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'title': title,
        'description': description,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
      });

      if (image != null) {
        final mimeType = _getMimeType(image.path);
        request.files.add(await http.MultipartFile.fromPath(
          'image', 
          image.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      if (voice != null) {
        final mimeType = _getAudioMimeType(voice.path);
        request.files.add(await http.MultipartFile.fromPath(
          'voice', 
          voice.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      return _handleResponse(http.Response(responseBody, response.statusCode));
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  Future<Map<String, dynamic>> getAllReports() async {
    return await _makeRequest('GET', ApiConfig.getAllReports, requiresAuth: false);
  }

  Future<Map<String, dynamic>> getUserReports() async {
    return await _makeRequest('GET', ApiConfig.getUserReports, requiresAuth: true);
  }

  Future<Map<String, dynamic>> getNearbyReports({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    final endpoint = '${ApiConfig.nearbyReports}?lat=$latitude&lng=$longitude&radius=$radius';
    return await _makeRequest('GET', endpoint);
  }

  Future<Map<String, dynamic>> upvoteReport(String reportId) async {
    final endpoint = '${ApiConfig.upvoteReport}/$reportId/upvote-report';
    return await _makeRequest('POST', endpoint, requiresAuth: true);
  }

  Future<Map<String, dynamic>> updateReportStatus(String reportId) async {
    final endpoint = '${ApiConfig.updateReportStatus}/$reportId/update-report-status-resolve';
    return await _makeRequest('PATCH', endpoint, requiresAuth: true);
  }

  Future<Map<String, dynamic>> saveFcmToken(String fcmToken) async {
    return await _makeRequest('POST', '/auth/save-fcm-token', 
      body: {'fcmToken': fcmToken}, 
      requiresAuth: true
    );
  }

  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _getAudioMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'm4a':
        return 'audio/m4a';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      default:
        return 'audio/m4a';
    }
  }
}
