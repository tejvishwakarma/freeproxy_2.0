import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Small delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if admin is authenticated
    final authService = Provider.of<AuthService>(context, listen: false);

    // Wait for authentication check to complete
    if (authService.isLoading) {
      await _waitForAuthCheck(authService);
    }

    if (!mounted) return;

    // Navigate based on authentication status
    if (authService.isAuthenticated) {
      // Admin is already logged in - go to admin dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      // Not logged in - go to home screen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  // Helper method to wait for auth check to complete
  Future<void> _waitForAuthCheck(AuthService authService) async {
    final completer = Completer<void>();

    // Listen for changes in loading state
    late final void Function() listener;
    listener = () {
      if (!authService.isLoading && !completer.isCompleted) {
        completer.complete();
        authService.removeListener(listener);
      }
    };

    authService.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or app icon
            Icon(Icons.public, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            // App name
            Text(
              'FreeProxy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
