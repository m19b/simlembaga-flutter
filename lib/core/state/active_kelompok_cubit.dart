import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveKelompokState {
  final int activeId;
  final List<Map<String, dynamic>> allowedKelompok;

  ActiveKelompokState({
    required this.activeId,
    required this.allowedKelompok,
  });

  ActiveKelompokState copyWith({
    int? activeId,
    List<Map<String, dynamic>>? allowedKelompok,
  }) {
    return ActiveKelompokState(
      activeId: activeId ?? this.activeId,
      allowedKelompok: allowedKelompok ?? this.allowedKelompok,
    );
  }
}

class ActiveKelompokCubit extends Cubit<ActiveKelompokState> {
  // Static variable for synchronous access by Dio Interceptor
  static int activeKelompokId = 0; 
  static const String _prefKey = 'ACTIVE_KELOMPOK_ID';

  ActiveKelompokCubit() : super(ActiveKelompokState(activeId: 0, allowedKelompok: []));

  Future<void> initialize(List<Map<String, dynamic>> kelompokList) async {
    final prefs = await SharedPreferences.getInstance();
    int savedId = prefs.getInt(_prefKey) ?? 0;

    // Verify if savedId is still valid in the new allowed list
    if (kelompokList.isNotEmpty) {
      bool exists = kelompokList.any((k) => 
        k['id_kelompok'] == savedId || 
        k['id'] == savedId ||
        k['id_kelompok'].toString() == savedId.toString()
      );
      
      if (!exists || savedId == 0) {
        // Fallback to the first allowed kelompok
        var firstId = kelompokList.first['id_kelompok'] ?? kelompokList.first['id'] ?? 0;
        if (firstId is String) firstId = int.tryParse(firstId) ?? 0;
        savedId = firstId;
        await prefs.setInt(_prefKey, savedId);
      }
    } else {
      savedId = 0;
    }

    activeKelompokId = savedId;
    emit(state.copyWith(activeId: savedId, allowedKelompok: kelompokList));
  }

  Future<void> changeKelompok(int newId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, newId);
    activeKelompokId = newId;
    emit(state.copyWith(activeId: newId));
  }

  void clear() {
    activeKelompokId = 0;
    emit(ActiveKelompokState(activeId: 0, allowedKelompok: []));
  }
}
