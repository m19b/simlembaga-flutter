import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: Colors.green,
      primary: Colors.green[800]!,
      secondary: Colors.green[600]!,
      surface: Colors.white,
      onSurface: const Color(0xFF1F2937), // Gray 800
      surfaceContainerHighest: const Color(0xFFF3F4F6), // Gray 100 for background
    ),
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F2937),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1F2937)),
    ),

    dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB)), // Gray 200
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.green,
      primary: Colors.green[400]!,
      secondary: Colors.green[300]!,
      surface: const Color(0xFF1F2937), // Gray 800
      onSurface: const Color(0xFFF9FAFB), // Gray 50
      surfaceContainerHighest: const Color(0xFF111827), // Gray 900 for background
    ),
    scaffoldBackgroundColor: const Color(0xFF111827),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Color(0xFFF9FAFB),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFF9FAFB)),
    ),

    dividerTheme: const DividerThemeData(color: Color(0xFF374151)), // Gray 700
    useMaterial3: true,
  );
}
