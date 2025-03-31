import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication state
  String? _currentAdminId;
  String? _currentAdminUsername;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  String? get currentAdminId => _currentAdminId;
  String? get currentAdminUsername => _currentAdminUsername;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Constructor - check for stored credentials on init
  AuthService() {
    _checkStoredCredentials();
  }

  // Check if we have stored credentials
  Future<void> _checkStoredCredentials() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedAdminData = prefs.getString('admin_data');

      if (storedAdminData != null) {
        final adminData = jsonDecode(storedAdminData);
        _currentAdminId = adminData['id'];
        _currentAdminUsername = adminData['username'];
        _isAuthenticated = true;
        print('Found stored admin credentials for: $_currentAdminUsername');
      } else {
        print('No stored admin credentials found');
      }
    } catch (e) {
      print('Error checking stored credentials: $e');
      // Clear potentially corrupted data
      _clearStoredCredentials();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Store admin credentials in shared preferences
  Future<void> _storeCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminData = {
        'id': _currentAdminId,
        'username': _currentAdminUsername,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString('admin_data', jsonEncode(adminData));
      print('Admin credentials stored: $_currentAdminUsername');
    } catch (e) {
      print('Error storing credentials: $e');
    }
  }

  // Clear stored credentials
  Future<void> _clearStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_data');
      print('Admin credentials cleared');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // For development/testing - hardcoded admin credentials
      // In production, remove this and only use the database check
      if (username == 'admin' && password == 'admin123' ||
          username == 'tejvishwakarma' && password == 'admin123') {
        _currentAdminId = 'admin_${username}_id';
        _currentAdminUsername = username;
        _isAuthenticated = true;
        await _storeCredentials(); // Store credentials
        notifyListeners();
        return true;
      }

      // Check against admin collection in Firestore
      final QuerySnapshot adminSnapshot =
          await _firestore
              .collection('admins')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (adminSnapshot.docs.isEmpty) {
        return false;
      }

      final adminDoc = adminSnapshot.docs.first;
      final adminData = adminDoc.data() as Map<String, dynamic>;

      // In a real application, use proper password hashing
      if (adminData['password'] == password) {
        _currentAdminId = adminDoc.id;
        _currentAdminUsername = username;
        _isAuthenticated = true;
        await _storeCredentials(); // Store credentials
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear stored credentials
      await _clearStoredCredentials();

      _currentAdminId = null;
      _currentAdminUsername = null;
      _isAuthenticated = false;
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
