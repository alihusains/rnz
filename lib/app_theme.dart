import 'package:flutter/material.dart';

/// Islamic-themed color palette and styling
class AppTheme {
  // Islamic Color Palette
  static const Color primaryGreen = Color(0xFF1F7A4F); // Deep Islamic Green
  static const Color primaryGold = Color(0xFFD4AF37); // Islamic Gold
  static const Color darkGreen = Color(0xFF0F4C2F); // Very Dark Green
  static const Color lightGreen = Color(0xFFA8D5BA); // Light Green
  static const Color creamWhite = Color(0xFFFAF8F3); // Cream White
  static const Color darkText = Color(0xFF1A1A1A); // Dark Text
  static const Color lightText = Color(0xFFFFFFFF); // Light Text
  static const Color errorRed = Color(0xFFD32F2F); // Error Red
  static const Color successGreen = Color(0xFF388E3C); // Success Green

  // Gradient backgrounds
  static LinearGradient islamicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryGreen,
      darkGreen,
    ],
  );

  static LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      creamWhite,
      Color(0xFFF5F1E8),
    ],
  );

  // AppBar Theme
  static AppBarTheme getAppBarTheme() {
    return AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: lightText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightText,
        letterSpacing: 0.5,
      ),
    );
  }

  // Card Theme
  static CardThemeData getCardTheme() {
    return CardThemeData(
      color: creamWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: primaryGold,
          width: 1,
        ),
      ),
    );
  }

  // Button Theme
  static ElevatedButtonThemeData getElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: lightText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
    );
  }

  // Text Themes
  static TextStyle headingStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkGreen,
    letterSpacing: 0.5,
  );

  static TextStyle subheadingStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryGreen,
    letterSpacing: 0.3,
  );

  static TextStyle bodyTextStyle = const TextStyle(
    fontSize: 14,
    color: darkText,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle captionStyle = const TextStyle(
    fontSize: 12,
    color: Color(0xFF666666),
    height: 1.4,
  );

  static TextStyle whiteBodyStyle = const TextStyle(
    fontSize: 14,
    color: lightText,
    height: 1.6,
    letterSpacing: 0.2,
  );

  // ThemeData
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: creamWhite,
      appBarTheme: getAppBarTheme(),
      cardTheme: getCardTheme(),
      elevatedButtonTheme: getElevatedButtonTheme(),
      textTheme: TextTheme(
        displayLarge: headingStyle,
        headlineSmall: subheadingStyle,
        bodyMedium: bodyTextStyle,
        bodySmall: captionStyle,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: subheadingStyle,
        subtitleTextStyle: captionStyle,
        textColor: darkText,
        iconColor: primaryGreen,
      ),
    );
  }

  // Helper method to get box decoration with Islamic border
  static BoxDecoration islamicCardDecoration({Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? creamWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: primaryGold,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: darkGreen.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Helper method for elevated decoration
  static BoxDecoration elevatedDecoration({Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
