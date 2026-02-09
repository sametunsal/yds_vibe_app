import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.home,
            size: 80,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 16),
          Text(
            'Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'YDS Vibe App - Ana Ekran',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
