import 'package:flutter/material.dart';

/// Reusable box shadow styles for consistent elevation effects
/// across the application.
class ShadowStyles {
  ShadowStyles._();

  /// Card elevation - used for main content cards
  static const List<BoxShadow> cardElevation = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Colored card elevation - deep purple themed shadow
  static List<BoxShadow> deepPurpleCard(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Button elevation - subtle shadow for interactive elements
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised button elevation - more prominent shadow
  static const List<BoxShadow> buttonRaised = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Subtle shadow for decorative containers
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Floating action button style shadow
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}

/// Named color constants for consistent theming
class ColorPalette {
  ColorPalette._();

  // Primary colors
  static const Color deepPurple = Colors.deepPurple;
  static const Color deepPurpleAccent = Color(0xFF9575CD);

  // Semantic colors for SRS ratings
  static const Color ratingAgain = Color(0xFFE53935);     // Red
  static const Color ratingStruggled = Color(0xFFFFB74D); // Orange
  static const Color ratingGood = Color(0xFF66BB6A);      // Green
  static const Color ratingEasy = Color(0xFF42A5F5);      // Blue

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral grays with semantic names
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFBDBDBD);

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundCard = Colors.white;
  static const Color backgroundSurface = Color(0xFFF5F5F5);

  // Quiz-specific colors
  static const Color quizCorrect = Color(0xFF66BB6A);
  static const Color quizWrong = Color(0xFFE53935);
  static const Color quizSelected = Color(0xFF42A5F5);

  // Streak colors
  static const Color streakActive = Color(0xFFFF6F00);
  static const Color streakInactive = Color(0xFFBDBDBD);

  // Progress colors
  static const Color progressBackground = Color(0xFFE0E0E0);
  static const Color progressFill = Colors.deepPurple;
}

/// Border radius presets for consistent corner rounding
class BorderRadiusPresets {
  BorderRadiusPresets._();

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 20.0;
  static const double xxlarge = 24.0;
  static const double circular = 999.0;

  static BorderRadius smallBorder = BorderRadius.circular(small);
  static BorderRadius mediumBorder = BorderRadius.circular(medium);
  static BorderRadius largeBorder = BorderRadius.circular(large);
  static BorderRadius xlargeBorder = BorderRadius.circular(xlarge);
  static BorderRadius xxlargeBorder = BorderRadius.circular(xxlarge);
}

/// Common gradient presets
class GradientPresets {
  GradientPresets._();

  /// Primary card gradient - white to light purple
  static LinearGradient get primaryCard => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFEDE7F6)],
      );

  /// Reverse card gradient - light purple to white
  static LinearGradient get reverseCard => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEDE7F6), Colors.white],
      );

  /// Subtle gradient for backgrounds
  static LinearGradient get subtle => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.withValues(alpha: 0.02),
          Colors.grey.withValues(alpha: 0.05),
        ],
      );
}

/// Spacing constants for consistent gaps and padding
class Spacing {
  Spacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets allXS = EdgeInsets.all(xs);
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  static const EdgeInsets allMD = EdgeInsets.all(md);
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  static const EdgeInsets allXL = EdgeInsets.all(xl);
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
}
