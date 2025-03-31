import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freeproxy/firebase_options.dart';
import 'package:freeproxy/services/theme_provider.dart';
import 'package:freeproxy/services/auth_service.dart';
import 'package:freeproxy/screens/splash/splash_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              // Theme provider
              ChangeNotifierProvider(create: (_) => ThemeProvider()),

              // Auth service provider
              ChangeNotifierProvider(create: (_) => AuthService()),
            ],
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                // Use the actual getTheme method from your ThemeProvider
                return MaterialApp(
                  title: 'FreeProxy',
                  debugShowCheckedModeBanner: false,
                  theme:
                      themeProvider
                          .getTheme(), // Using the getTheme() method instead of properties
                  home: const SplashScreen(),
                );
              },
            ),
          );
        }

        // Show loading screen while Firebase initializes
        return MaterialApp(
          title: 'FreeProxy',
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
