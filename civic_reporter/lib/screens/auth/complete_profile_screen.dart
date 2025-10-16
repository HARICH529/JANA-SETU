import 'package:jana_setu/api/database_service.dart';
import 'package:jana_setu/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _homeAddressController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email from Firebase user
    _emailController.text = widget.user.email ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _homeAddressController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      await context.read<DatabaseService>().updateUserData(
        fullName: _fullNameController.text.trim(),
        mobileNumber: widget.user.phoneNumber ?? '',
        email: _emailController.text.trim(),
        homeAddress: _homeAddressController.text.trim(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _homeAddressController,
                decoration: const InputDecoration(labelText: 'Home Address (Optional)'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _loading ? null : _submitProfile,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
