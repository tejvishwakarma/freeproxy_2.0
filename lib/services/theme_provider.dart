import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Save and toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey[800],
          colorScheme: ColorScheme.dark(
            primary: Colors.blueGrey[300]!,
            secondary: Colors.tealAccent,
          ),
        )
        : ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.teal,
          ),
        );
  }
}
