import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.person,
            size: 80,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Profil Ekranı',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
