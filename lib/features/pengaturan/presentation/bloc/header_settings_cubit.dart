import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderImageConfig {
  final String id;
  final String label;
  final bool isVisible;

  HeaderImageConfig({
    required this.id,
    required this.label,
    required this.isVisible,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isVisible': isVisible,
      };

  factory HeaderImageConfig.fromJson(Map<String, dynamic> json) =>
      HeaderImageConfig(
        id: json['id'] as String,
        label: json['label'] as String,
        isVisible: json['isVisible'] as bool? ?? true,
      );

  HeaderImageConfig copyWith({
    String? id,
    String? label,
    bool? isVisible,
  }) {
    return HeaderImageConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class HeaderSettingsCubit extends Cubit<List<HeaderImageConfig>> {
  static const _prefsKey = 'HEADER_IMAGES_ORDER';

  static final List<HeaderImageConfig> _defaultConfig = [
    HeaderImageConfig(id: 'profil', label: 'Profil Guru', isVisible: true),
    HeaderImageConfig(id: 'metode', label: 'Logo Metode', isVisible: true),
    HeaderImageConfig(id: 'lembaga', label: 'Logo Lembaga', isVisible: true),
  ];

  HeaderSettingsCubit() : super(_defaultConfig) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_prefsKey);
      
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final loadedList = decoded
            .map((e) => HeaderImageConfig.fromJson(e as Map<String, dynamic>))
            .toList();
            
        // Validasi jika config lama tidak memiliki semua item (e.g. update versi)
        if (loadedList.length == _defaultConfig.length) {
          emit(loadedList);
          return;
        }
      }
    } catch (e) {
      // Abaikan error dan gunakan default
    }
    emit(_defaultConfig);
  }

  Future<void> _saveConfig(List<HeaderImageConfig> config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = config.map((e) => e.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(jsonList));
    } catch (e) {
      // Abaikan error
    }
  }

  void updateVisibility(String id, bool isVisible) {
    final newList = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isVisible: isVisible);
      }
      return item;
    }).toList();
    emit(newList);
    _saveConfig(newList);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newList = List<HeaderImageConfig>.from(state);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    emit(newList);
    _saveConfig(newList);
  }
}
