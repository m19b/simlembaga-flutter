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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F4C2A), // Simpan/Submit
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4B5563), // Batal/Tutup
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4B5563),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
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
      surfaceContainer: Color(0xFF121212), // Elevated surface
      surfaceContainerHigh: Color(0xFF1A1A1A),
      surfaceContainerHighest: Color(0xFF242424),
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
    cardTheme: CardThemeData(
      color: const Color(0xFF121212),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF121212),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF121212),
      surfaceTintColor: Colors.transparent,
    ),
    splashColor: Colors.white.withValues(alpha: 0.05),
    highlightColor: Colors.white.withValues(alpha: 0.05),
    cardColor: const Color(0xFF121212),
    dividerTheme: const DividerThemeData(color: Color(0xFF242424)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F4C2A), // Green for submit
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF9CA3AF),
        side: const BorderSide(color: Color(0xFF374151)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9CA3AF),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    useMaterial3: true,
    extensions: [
      AppCustomStyles(
        headerBorder: Colors.white.withValues(alpha: 0.08),
        cardBorder: Colors.white.withValues(alpha: 0.05),
        success: Color(0xFF325240), // Pastel/dim green for dark mode
        warning: Color(0xFF7A542A), // Pastel/dim orange for dark mode
        error: Color(0xFF7A2A2A), // Pastel/dim red for dark mode
        shimmerBase: Color(0xFF0A0A0A),
        shimmerHighlight: Color(0xFF1A1A1A),
      ),
    ],
  );
}
