import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndicatorSettings {
  final double opacity;
  final Color onlineColor;
  final Color offlineColor;
  final Color backgroundColor;
  final double borderWidth;
  final String onlineText;
  final String offlineText;
  final double? initialX;
  final double? initialY;

  IndicatorSettings({
    this.opacity = 1.0,
    this.onlineColor = Colors.green,
    this.offlineColor = Colors.red,
    this.backgroundColor = Colors.transparent, // Default transparent matching original `cardColor.withValues(alpha: 0.0)` logic
    this.borderWidth = 1.0,
    this.onlineText = "Online",
    this.offlineText = "Offline",
    this.initialX,
    this.initialY,
  });

  IndicatorSettings copyWith({
    double? opacity,
    Color? onlineColor,
    Color? offlineColor,
    Color? backgroundColor,
    double? borderWidth,
    String? onlineText,
    String? offlineText,
    double? initialX,
    double? initialY,
  }) {
    return IndicatorSettings(
      opacity: opacity ?? this.opacity,
      onlineColor: onlineColor ?? this.onlineColor,
      offlineColor: offlineColor ?? this.offlineColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderWidth: borderWidth ?? this.borderWidth,
      onlineText: onlineText ?? this.onlineText,
      offlineText: offlineText ?? this.offlineText,
      initialX: initialX ?? this.initialX,
      initialY: initialY ?? this.initialY,
    );
  }
}

class IndicatorSettingsCubit extends Cubit<IndicatorSettings> {
  static const _keyOpacity = 'ind_opacity';
  static const _keyOnlineColor = 'ind_onlineColor';
  static const _keyOfflineColor = 'ind_offlineColor';
  static const _keyBgColor = 'ind_bgColor';
  static const _keyBorderWidth = 'ind_borderWidth';
  static const _keyOnlineText = 'ind_onlineText';
  static const _keyOfflineText = 'ind_offlineText';
  static const _keyX = 'ind_x';
  static const _keyY = 'ind_y';

  IndicatorSettingsCubit() : super(IndicatorSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final x = prefs.getDouble(_keyX);
    final y = prefs.getDouble(_keyY);

    emit(IndicatorSettings(
      opacity: prefs.getDouble(_keyOpacity) ?? 1.0,
      onlineColor: Color(prefs.getInt(_keyOnlineColor) ?? Colors.green.value),
      offlineColor: Color(prefs.getInt(_keyOfflineColor) ?? Colors.red.value),
      backgroundColor: Color(prefs.getInt(_keyBgColor) ?? Colors.transparent.value),
      borderWidth: prefs.getDouble(_keyBorderWidth) ?? 1.0,
      onlineText: prefs.getString(_keyOnlineText) ?? "Online",
      offlineText: prefs.getString(_keyOfflineText) ?? "Offline",
      initialX: x,
      initialY: y,
    ));
  }

  Future<void> updateSettings(IndicatorSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble(_keyOpacity, newSettings.opacity);
    await prefs.setInt(_keyOnlineColor, newSettings.onlineColor.value);
    await prefs.setInt(_keyOfflineColor, newSettings.offlineColor.value);
    await prefs.setInt(_keyBgColor, newSettings.backgroundColor.value);
    await prefs.setDouble(_keyBorderWidth, newSettings.borderWidth);
    await prefs.setString(_keyOnlineText, newSettings.onlineText);
    await prefs.setString(_keyOfflineText, newSettings.offlineText);
    if (newSettings.initialX != null) await prefs.setDouble(_keyX, newSettings.initialX!);
    if (newSettings.initialY != null) await prefs.setDouble(_keyY, newSettings.initialY!);

    emit(newSettings);
  }

  Future<void> savePosition(double x, double y) async {
    final newSettings = state.copyWith(initialX: x, initialY: y);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyX, x);
    await prefs.setDouble(_keyY, y);
    emit(newSettings);
  }

  Future<void> resetToDefault() async {
    final defaultSettings = IndicatorSettings();
    await updateSettings(defaultSettings);
  }
}
