import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const YDSVibeApp());
}

class YDSVibeApp extends StatelessWidget {
  const YDSVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YDS Vibe App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Follow system preference
      home: const MainNavigationScreen(),
    );
  }
}
