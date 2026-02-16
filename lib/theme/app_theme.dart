import 'package:flutter/material.dart';

/// App theme configuration with dark mode support.
/// Follows Material 3 design guidelines.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Primary seed color - can be customized
  static const Color _seedColor = Colors.deepPurple;

  // Minimum touch target size (48dp for Android, 44pt for iOS)
  static const double minTouchTarget = 48.0;
  static const double minInteractiveDimension = 48.0;

  /// Light theme
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.all(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelStyle: const TextStyle(fontSize: 14),
        side: BorderSide.none,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  /// Dark theme
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.all(12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelStyle: const TextStyle(fontSize: 14),
        side: BorderSide.none,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  /// Helper method to ensure minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double minWidth = minInteractiveDimension,
    double minHeight = minInteractiveDimension,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          minHeight: minHeight,
        ),
        child: Center(child: child),
      ),
    );
  }

  /// Helper to wrap icon buttons with proper touch target
  static Widget touchTargetIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    Color? color,
    double size = 24.0,
  }) {
    return IconButton(
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
      style: IconButton.styleFrom(
        minimumSize: const Size(minInteractiveDimension, minInteractiveDimension),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
