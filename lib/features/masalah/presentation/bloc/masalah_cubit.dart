import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/domain/repositories/masalah_repository.dart';

// ─── States ───────────────────────────────────────────────────────────────────
abstract class MasalahState {}

class MasalahInitial extends MasalahState {}

class MasalahLoading extends MasalahState {}

class MasalahLoaded extends MasalahState {
  final List<Map<String, dynamic>> aktif;
  final List<Map<String, dynamic>> selesai;
  MasalahLoaded({required this.aktif, required this.selesai});
}

class MasalahError extends MasalahState {
  final String message;
  MasalahError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────
class MasalahCubit extends Cubit<MasalahState> {
  final MasalahRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSub;

  MasalahCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(MasalahInitial()) {
    // Multi-Tenancy: auto re-fetch saat kelompok aktif berubah
    _kelompokSub = activeKelompokCubit.stream.listen((state) {
      if (state.activeId > 0 && this.state is! MasalahInitial) {
        fetchMasalah(forceRefresh: true);
      }
    });
  }

  Future<void> fetchMasalah({bool forceRefresh = false}) async {
    emit(MasalahLoading());
    try {
      final data = await repository.getMasalahList(forceRefresh: forceRefresh);
      emit(MasalahLoaded(
        aktif:   data['aktif']   ?? [],
        selesai: data['selesai'] ?? [],
      ));
    } catch (e) {
      emit(MasalahError(e.toString()));
    }
  }

  /// Optimistic: langsung return true, sync via queue jika offline
  Future<bool> submitUpdateMasalah(Map<String, dynamic> payload) async {
    final ok = await repository.updateMasalah(payload);
    if (ok) fetchMasalah(forceRefresh: true);
    return ok;
  }

  Future<bool> submitTahapMasalah(Map<String, dynamic> payload) async {
    final ok = await repository.storeTahapMasalah(payload);
    if (ok) fetchMasalah(forceRefresh: true);
    return ok;
  }

  Future<bool> submitMasalahBaru(Map<String, dynamic> payload) async {
    final ok = await repository.storeMasalah(payload);
    if (ok) fetchMasalah(forceRefresh: true);
    return ok;
  }

  @override
  Future<void> close() {
    _kelompokSub.cancel();
    return super.close();
  }
}
