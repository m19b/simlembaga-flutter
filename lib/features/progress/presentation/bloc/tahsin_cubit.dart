import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';

abstract class TahsinState {}

class TahsinInitial extends TahsinState {}

class TahsinLoading extends TahsinState {}

class TahsinLoaded extends TahsinState {
  final Map<String, dynamic> data;
  TahsinLoaded(this.data);
}

class TahsinError extends TahsinState {
  final String message;
  TahsinError(this.message);
}

class TahsinCubit extends Cubit<TahsinState> {
  final TahsinRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSubscription;
  
  // Track parameters for auto re-fetch
  int? _lastIdKelompok;
  int? _lastIdKelas;

  TahsinCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(TahsinInitial()) {
    // Listen to Kelompok changes (Multi-Tenancy)
    _kelompokSubscription = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0 && _lastIdKelompok != null) {
        // Trigger re-fetch otomatis dengan filter yang sama
        fetchProgressList(idKelompok: kelompokState.activeId, idKelas: _lastIdKelas, forceRefresh: true);
      }
    });
  }

  Future<void> fetchProgressList({int? idKelompok, int? idKelas, bool forceRefresh = false}) async {
    _lastIdKelompok = idKelompok;
    _lastIdKelas = idKelas;
    emit(TahsinLoading());
    try {
      final data = await repository.getProgressList(idKelompok: idKelompok, idKelas: idKelas, forceRefresh: forceRefresh);
      emit(TahsinLoaded(data));
    } catch (e) {
      emit(TahsinError(e.toString()));
    }
  }

  Future<bool> submitInputMassal(Map<String, dynamic> payload) async {
    // Karena optimistic UI, kita tidak mengubah state list jadi loading penuh
    // melainkan hanya mengembalikan status.
    final result = await repository.inputMassalProgress(payload);
    if (result) {
      // Reload setelah submit sukses atau masuk antrean
      fetchProgressList(idKelompok: _lastIdKelompok, idKelas: _lastIdKelas, forceRefresh: true);
    }
    return result;
  }

  @override
  Future<void> close() {
    _kelompokSubscription.cancel();
    return super.close();
  }
}
