import 'package:jana_setu/api/auth_service.dart';
import 'package:jana_setu/screens/auth/register_screen.dart';
import 'package:jana_setu/screens/auth/phone_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String error = '';
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email/Phone Number',
                  hintText: 'Enter email or 10-digit phone number'
                ),
                keyboardType: TextInputType.text,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter email/phone number';
                  }
                  // Check if it's email or phone
                  bool isEmail = val.contains('@');
                  bool isPhone = RegExp(r'^[6-9]\d{9}$').hasMatch(val);
                  
                  if (!isEmail && !isPhone) {
                    return 'Enter valid email/phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Enter a password 6+ chars long' : null,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    dynamic result = await authService.signInWithEmailAndPassword(
                        _emailController.text.trim(), _passwordController.text.trim());
                    if (result == null) {
                      setState(() {
                        error = 'Could not sign in with those credentials';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
              TextButton(
                child: const Text("Don't have an account? Register"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text('OR', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Sign in with Phone'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneAuthScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
