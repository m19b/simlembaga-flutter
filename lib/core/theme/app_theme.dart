import 'package:flutter/material.dart';

class AppCustomStyles extends ThemeExtension<AppCustomStyles> {
  final Color headerBorder;
  final Color cardBorder;
  final Color success;
  final Color warning;
  final Color error;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppCustomStyles({
    required this.headerBorder,
    required this.cardBorder,
    required this.success,
    required this.warning,
    required this.error,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  @override
  ThemeExtension<AppCustomStyles> copyWith({
    Color? headerBorder,
    Color? cardBorder,
    Color? success,
    Color? warning,
    Color? error,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppCustomStyles(
      headerBorder: headerBorder ?? this.headerBorder,
      cardBorder: cardBorder ?? this.cardBorder,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  ThemeExtension<AppCustomStyles> lerp(
      covariant ThemeExtension<AppCustomStyles>? other, double t) {
    if (other is! AppCustomStyles) return this;
    return AppCustomStyles(
      headerBorder: Color.lerp(headerBorder, other.headerBorder, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

class AppTheme {
  static const Color primaryColor = Color(0xFF0F4C2A);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1F2937),
      onSurfaceVariant: Color(0xFF4B5563),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F2937),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1F2937)),
    ),
    splashColor: Colors.black.withValues(alpha: 0.05),
    highlightColor: Colors.black.withValues(alpha: 0.05),
    cardColor: Colors.white,
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB)),
    useMaterial3: true,
    extensions: [
      AppCustomStyles(
        headerBorder: Colors.black.withValues(alpha: 0.1),
        cardBorder: Colors.black.withValues(alpha: 0.05),
        success: Colors.green,
        warning: Colors.orange,
        error: Colors.red,
        shimmerBase: Colors.grey.shade200,
        shimmerHighlight: Colors.white,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,
      surface: Colors.black, // True AMOLED Black
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFF9CA3AF),
    ),
    scaffoldBackgroundColor: Colors.black, // True AMOLED Black
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    splashColor: Colors.white.withValues(alpha: 0.05),
    highlightColor: Colors.white.withValues(alpha: 0.05),
    cardColor: Colors.black,
    dividerTheme: const DividerThemeData(color: Color(0xFF374151)),
    useMaterial3: true,
    extensions: [
      AppCustomStyles(
        headerBorder: Colors.white.withValues(alpha: 0.1),
        cardBorder: Colors.white.withValues(alpha: 0.1),
        success: Color(0xFF325240), // Pastel/dim green for dark mode
        warning: Color(0xFF7A542A), // Pastel/dim orange for dark mode
        error: Color(0xFF7A2A2A), // Pastel/dim red for dark mode
        shimmerBase: Color(0xFF0A0A0A),
        shimmerHighlight: Color(0xFF1A1A1A),
      ),
    ],
  );
}
