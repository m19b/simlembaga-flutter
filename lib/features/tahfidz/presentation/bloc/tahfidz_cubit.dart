import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/domain/repositories/tahfidz_repository.dart';

// =============================================================================
// STATES
// =============================================================================

abstract class TahfidzState {}

class TahfidzInitial extends TahfidzState {}

class TahfidzLoading extends TahfidzState {}

class TahfidzLoaded extends TahfidzState {
  final Map<String, dynamic> data;
  TahfidzLoaded(this.data);
}

class TahfidzError extends TahfidzState {
  final String message;
  TahfidzError(this.message);
}

// Detail states
class TahfidzDetailLoading extends TahfidzState {}

class TahfidzDetailLoaded extends TahfidzState {
  final Map<String, dynamic> data;
  TahfidzDetailLoaded(this.data);
}

class TahfidzDetailError extends TahfidzState {
  final String message;
  TahfidzDetailError(this.message);
}

// =============================================================================
// CUBIT
// =============================================================================

class TahfidzCubit extends Cubit<TahfidzState> {
  final TahfidzRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription<dynamic> _kelompokSub;

  int? _lastIdKelompok;
  String? _lastTanggal;

  TahfidzCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(TahfidzInitial()) {
    // Auto re-fetch saat kelompok aktif berganti
    _kelompokSub = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0 && _lastIdKelompok != null) {
        fetchProgressList(
          idKelompok: kelompokState.activeId,
          tanggal: _lastTanggal,
          forceRefresh: true,
        );
      }
    });
  }

  /// Ambil daftar santri + evaluasi hari ini.
  /// Hanya emit [TahfidzLoading] pada kunjungan pertama atau pull-to-refresh.
  Future<void> fetchProgressList({
    int? idKelompok,
    String? tanggal,
    bool forceRefresh = false,
  }) async {
    _lastIdKelompok = idKelompok;
    _lastTanggal = tanggal;

    final isFirstLoad = state is TahfidzInitial;
    if (forceRefresh || isFirstLoad) {
      emit(TahfidzLoading());
    }

    try {
      final data = await repository.getProgressList(
        idKelompok: idKelompok,
        tanggal: tanggal,
        forceRefresh: forceRefresh,
      );
      emit(TahfidzLoaded(data));
    } catch (e) {
      emit(TahfidzError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Reset state ke Initial agar fetchProgressList berikutnya tampilkan loading spinner.
  void resetToInitial() => emit(TahfidzInitial());

  /// Ambil detail santri (Buku Prestasi)
  Future<void> fetchDetail(String nis, {bool forceRefresh = false}) async {
    emit(TahfidzDetailLoading());
    try {
      final data = await repository.getDetail(nis, forceRefresh: forceRefresh);
      emit(TahfidzDetailLoaded(data));
    } catch (e) {
      emit(TahfidzDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Simpan setoran tunggal + auto reload list setelah sukses
  Future<bool> submitInputCepat(Map<String, dynamic> payload) async {
    final ok = await repository.inputCepat(payload);
    if (ok) {
      fetchProgressList(
        idKelompok: _lastIdKelompok,
        tanggal: _lastTanggal,
        forceRefresh: true,
      );
    }
    return ok;
  }

  /// Simpan setoran massal + auto reload list setelah sukses
  Future<bool> submitInputMassal(Map<String, dynamic> payload) async {
    final ok = await repository.inputMassal(payload);
    if (ok) {
      fetchProgressList(
        idKelompok: _lastIdKelompok,
        tanggal: _lastTanggal,
        forceRefresh: true,
      );
    }
    return ok;
  }

  /// Update riwayat setoran
  Future<bool> updateRiwayat(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    return repository.updateRiwayat(idPrestasi, data);
  }

  /// Hapus riwayat setoran
  Future<bool> hapusRiwayat(int idPrestasi, String nis) async {
    return repository.hapusRiwayat(idPrestasi, nis);
  }

  @override
  Future<void> close() {
    _kelompokSub.cancel();
    return super.close();
  }
}
