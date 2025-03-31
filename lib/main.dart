import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:freeproxy/services/theme_provider.dart';
import 'package:freeproxy/services/database_service.dart';
import 'package:freeproxy/services/notification_service.dart';
// Import your home screen
import 'package:freeproxy/screens/home/home_screen.dart'; // Adjust the path if needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Free Proxy',
            theme: themeProvider.getTheme(),
            // Use your Home_screen as the initial screen
            home: const HomeScreen(),
            routes: {
              // Your existing routes
            },
          );
        },
      ),
    );
  }
}
