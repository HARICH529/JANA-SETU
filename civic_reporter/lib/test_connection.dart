import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing connection to backend...');
  
  try {
    final url = Uri.parse('http://192.168.29.244:3000/api/v1/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'mobiletest@example.com',
        'password': 'mobile123',
      }),
    ).timeout(const Duration(seconds: 10));
    
    print('✅ Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('🎉 Login successful!');
      } else {
        print('❌ Login failed: ${data['error']}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Connection error: $e');
  }
}