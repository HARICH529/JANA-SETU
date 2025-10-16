import 'package:flutter/material.dart';
import 'api/api_service.dart';

class DebugLoginScreen extends StatefulWidget {
  @override
  _DebugLoginScreenState createState() => _DebugLoginScreenState();
}

class _DebugLoginScreenState extends State<DebugLoginScreen> {
  final _emailController = TextEditingController(text: 'mobiletest@example.com');
  final _passwordController = TextEditingController(text: 'mobile123');
  String _result = '';
  bool _loading = false;

  Future<void> _testLogin() async {
    setState(() {
      _loading = true;
      _result = 'Testing login...';
    });

    try {
      final response = await ApiService().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      setState(() {
        _result = '✅ SUCCESS!\n${response.toString()}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ ERROR: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug Login Test')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _testLogin,
              child: _loading ? CircularProgressIndicator() : Text('Test Login'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}