import 'package:flutter/material.dart';

class AppTheme {
  // Colors - Green Nature Theme for Trekking
  static const Color primaryColor = Color(0xFF2E7D32); // Dark Green
  static const Color secondaryColor = Color(0xFF66BB6A); // Light Green
  static const Color accentColor = Color(0xFF8BC34A); // Lime Green
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  
  // Difficulty colors
  static const Color easyColor = Color(0xFF4CAF50);
  static const Color moderateColor = Color(0xFFFF9800);
  static const Color challengingColor = Color(0xFFFF5722);
  static const Color difficultColor = Color(0xFFF44336);
  
  // Risk level colors
  static const Color lowRisk = Color(0xFF4CAF50);
  static const Color mediumRisk = Color(0xFFFF9800);
  static const Color highRisk = Color(0xFFF44336);
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 2,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  static ThemeData mountainTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.white,
      surface: Colors.black,
      error: Color(0xFFFF4D4D),
    ),
    cardTheme: CardThemeData(
      color: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _NoAnimationTransitionsBuilder(),
        TargetPlatform.iOS: _NoAnimationTransitionsBuilder(),
        TargetPlatform.windows: _NoAnimationTransitionsBuilder(),
        TargetPlatform.macOS: _NoAnimationTransitionsBuilder(),
        TargetPlatform.linux: _NoAnimationTransitionsBuilder(),
      },
    ),
  );
  
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return easyColor;
      case 'MODERATE':
        return moderateColor;
      case 'CHALLENGING':
        return challengingColor;
      case 'DIFFICULT':
        return difficultColor;
      default:
        return moderateColor;
    }
  }
  
  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return lowRisk;
      case 'MEDIUM':
        return mediumRisk;
      case 'HIGH':
        return highRisk;
      default:
        return mediumRisk;
    }
  }
}

class _NoAnimationTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
