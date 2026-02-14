import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const YDSVibeApp());
}

class YDSVibeApp extends StatelessWidget {
  const YDSVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YDS Vibe App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
