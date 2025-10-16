import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static String userName = 'User';
  static String userEmail = 'user@example.com';
  static ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);

  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? 'User';
    userEmail = prefs.getString('userEmail') ?? 'user@example.com';
    darkModeNotifier.value = prefs.getBool('darkMode') ?? false;
  }

  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
    await prefs.setBool('darkMode', darkModeNotifier.value);
  }
}
