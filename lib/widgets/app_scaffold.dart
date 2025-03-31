import 'package:flutter/material.dart';
import 'package:freeproxy/screens/proxy_list/proxy_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:freeproxy/services/theme_provider.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final int bottomNavigationIndex;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    required this.bottomNavigationIndex,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          // Theme toggle icon
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          // Additional actions if provided
          if (actions != null) ...actions!,
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      // Removed bottom navigation since we only have one main screen now
    );
  }
}
