import 'package:flutter/material.dart';

class CategoryData {
  final String key;
  final String title;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
  });
}
