import 'package:jana_setu/api/auth_service.dart';
import 'package:jana_setu/api/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();

  String error = '';
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val!.isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _mobileNumberController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.isEmpty ? 'Enter your mobile number' : null,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter an email';
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
                    : const Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    UserCredential? result =
                        await authService.registerWithEmailAndPassword(
                            _emailController.text.trim(), _passwordController.text.trim());
                    if (result == null) {
                      setState(() {
                        error = 'Registration failed. Please try again.';
                        loading = false;
                      });
                    } else {
                      // Create a new document for the user with the uid.
                      await DatabaseService(uid: result.user!.uid)
                          .updateUserData(
                        fullName: _fullNameController.text.trim(),
                        mobileNumber: _mobileNumberController.text.trim(),
                        email: _emailController.text.trim(),
                        homeAddress: '', // Initially empty
                      );
                      if (mounted) Navigator.pop(context);
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
            ],
          ),
        ),
      ),
    );
  }
}
