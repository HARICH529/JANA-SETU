import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/simple_auth_provider.dart';
import '../utils/app_settings.dart';
import '../api/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadPreferences();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
      final user = authProvider.userProfile;
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['mobile'] ?? '';
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _locationEnabled = prefs.getBool('location') ?? true;
    });
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      // Update local settings
      AppSettings.userName = _nameController.text;
      AppSettings.userEmail = _emailController.text;
      await AppSettings.saveSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    AppSettings.darkModeNotifier.value = value;
    await AppSettings.saveSettings();
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _toggleLocation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location', value);
    setState(() => _locationEnabled = value);
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    await authProvider.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Update Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: AppSettings.darkModeNotifier,
                      builder: (context, isDark, child) {
                        return SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Enable dark theme'),
                          value: isDark,
                          onChanged: _toggleDarkMode,
                          secondary: const Icon(Icons.dark_mode),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Receive push notifications'),
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      secondary: const Icon(Icons.notifications),
                    ),
                    SwitchListTile(
                      title: const Text('Location Services'),
                      subtitle: const Text('Allow location access'),
                      value: _locationEnabled,
                      onChanged: _toggleLocation,
                      secondary: const Icon(Icons.location_on),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Other Options Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showHelpDialog(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showAboutDialog(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showPrivacyDialog(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () => _showLogoutDialog(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For help and support:\n\n'
          '• Email: support@civicreporter.com\n'
          '• Phone: +1-800-CIVIC\n'
          '• Visit our website for FAQs',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Civic Reporter'),
        content: const Text(
          'Civic Reporter v1.0.0\n\n'
          'A platform for citizens to report civic issues '
          'and help improve their communities.\n\n'
          'Built with Flutter and powered by blockchain technology.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy Summary:\n\n'
            '• We collect location data only when you create reports\n'
            '• Your personal information is encrypted and secure\n'
            '• We do not share your data with third parties\n'
            '• You can delete your account and data at any time\n\n'
            'For the full privacy policy, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
