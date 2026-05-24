import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/domain/repositories/pra_tahfidz_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class PraTahfidzState {}

class PraTahfidzInitial extends PraTahfidzState {}

class PraTahfidzLoading extends PraTahfidzState {}

class PraTahfidzLoaded extends PraTahfidzState {
  final Map<String, dynamic> data;
  final bool isOffline;
  PraTahfidzLoaded(this.data, {this.isOffline = false});
}

class PraTahfidzError extends PraTahfidzState {
  final String message;
  PraTahfidzError(this.message);
}

// Detail states
class PraTahfidzDetailLoading extends PraTahfidzState {}

class PraTahfidzDetailLoaded extends PraTahfidzState {
  final Map<String, dynamic> data;
  PraTahfidzDetailLoaded(this.data);
}

// Submit states (tidak mereset list agar Optimistic UI)
class PraTahfidzSubmitting extends PraTahfidzState {
  final Map<String, dynamic> currentData;
  PraTahfidzSubmitting(this.currentData);
}

class PraTahfidzSubmitSuccess extends PraTahfidzState {
  final Map<String, dynamic> data;
  final String message;
  PraTahfidzSubmitSuccess(this.data, {this.message = 'Berhasil disimpan.'});
}

class PraTahfidzConfirmationRequired extends PraTahfidzState {
  final String message;
  final Map<String, dynamic> payload;
  PraTahfidzConfirmationRequired(this.message, this.payload);
}

class PraTahfidzSubmitError extends PraTahfidzState {
  final Map<String, dynamic> currentData;
  final String message;
  PraTahfidzSubmitError(this.currentData, this.message);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class PraTahfidzCubit extends Cubit<PraTahfidzState> {
  final PraTahfidzRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription<dynamic> _kelompokSubscription;

  // Track parameter terakhir untuk auto re-fetch
  int? _lastIdKelompok;
  String? _lastTanggal;

  PraTahfidzCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(PraTahfidzInitial()) {
    // Auto re-fetch saat user berpindah kelompok (Multi-Tenancy)
    _kelompokSubscription = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0 && _lastIdKelompok != null) {
        fetchSantriList(
          idKelompok: kelompokState.activeId,
          tanggal: _lastTanggal,
          forceRefresh: true,
        );
      }
    });
  }

  // ── READ: List Santri ─────────────────────────────────────────────────────

  Future<void> fetchSantriList({
    String? tanggal,
    int? idKelompok,
    List<int>? kelasIds,
    int? sesi,
    String? filterKehadiran,
    bool forceRefresh = false,
  }) async {
    if (state is PraTahfidzLoading) return;

    final activeId = idKelompok ?? activeKelompokCubit.state.activeId;
    if (activeId <= 0) {
      print('xxxxxxxxxxxxxxxxxxxxxxx BLOKIR: idKelompok tidak valid ($activeId). Dibatalkan.');
      emit(PraTahfidzError("Silakan pilih Kelompok/Cabang terlebih dahulu di menu utama."));
      return;
    }

    _lastIdKelompok = activeId;
    _lastTanggal = tanggal;
    emit(PraTahfidzLoading());
    try {
      final data = await repository.getSantriList(
        tanggal: tanggal,
        idKelompok: activeId,
        kelasIds: kelasIds,
        sesi: sesi,
        filterKehadiran: filterKehadiran,
        forceRefresh: forceRefresh,
      );
      if (isClosed) return;
      emit(PraTahfidzLoaded(data));
    } catch (e, stacktrace) {
      print('xxxxxxxxxxxxxxxxxxxxxxx ERROR PRA-TAHFIDZ CUBIT: $e');
      print('xxxxxxxxxxxxxxxxxxxxxxx STACKTRACE: $stacktrace');
      if (isClosed) return;
      emit(PraTahfidzError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── READ: Detail Santri ──────────────────────────────────────────────────

  Future<void> fetchDetail(String nis, {bool forceRefresh = false}) async {
    emit(PraTahfidzDetailLoading());
    try {
      final data = await repository.getDetail(nis, forceRefresh: forceRefresh);
      if (isClosed) return;
      emit(PraTahfidzDetailLoaded(data));
    } catch (e) {
      if (isClosed) return;
      emit(PraTahfidzError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── WRITE: Input Cepat ───────────────────────────────────────────────────

  Future<bool> submitInputCepat(Map<String, dynamic> payload) async {
    final currentState = state;
    final currentData = currentState is PraTahfidzLoaded
        ? currentState.data
        : <String, dynamic>{};

    emit(PraTahfidzSubmitting(currentData));
    try {
      final ok = await repository.inputCepat(payload);
      if (ok) {
        // Re-fetch di background (tidak blocking UI)
        fetchSantriList(
          idKelompok: _lastIdKelompok,
          tanggal: _lastTanggal,
          forceRefresh: true,
        );
        return true;
      }
      emit(PraTahfidzLoaded(currentData));
      return false;
    } catch (e) {
      emit(PraTahfidzSubmitError(currentData, e.toString()));
      return false;
    }
  }

  // ── WRITE: Input Massal ──────────────────────────────────────────────────

  Future<bool> submitInputMassal(Map<String, dynamic> payload, {bool forceSave = false}) async {
    final currentState = state;
    final currentData = currentState is PraTahfidzLoaded
        ? currentState.data
        : <String, dynamic>{};

    try {
      payload['force_save'] = forceSave;
      print('xxxxxxxxxxxxxxxxxxxxxxx PAYLOAD RAW DARI UI: $payload');
      emit(PraTahfidzSubmitting(currentData));
      
      final result = await repository.inputMassal(payload);
      
      if (result['require_confirmation'] == true) {
        emit(PraTahfidzConfirmationRequired(result['message'], payload));
        return false;
      }
      
      if (result['success'] == true) {
        emit(PraTahfidzSubmitSuccess(currentData, message: result['message'] ?? 'Berhasil disimpan.'));
        fetchSantriList(
          idKelompok: _lastIdKelompok,
          tanggal: _lastTanggal,
          forceRefresh: true,
        );
        return true;
      }
      emit(PraTahfidzSubmitError(currentData, result['message'] ?? 'Gagal menyimpan data.'));
      return false;
    } catch (e, stacktrace) {
      print('xxxxxxxxxxxxxxxxxxxxxxx CRASH SAAT SIMPAN: $e');
      print('xxxxxxxxxxxxxxxxxxxxxxx STACKTRACE SIMPAN: $stacktrace');
      emit(PraTahfidzError(e.toString()));
      return false;
    }
  }

  // ── WRITE: Hapus Riwayat ─────────────────────────────────────────────────

  Future<bool> hapusRiwayat(int idPrestasi) async {
    try {
      final ok = await repository.hapusRiwayat(idPrestasi);
      if (ok) {
        fetchSantriList(
          idKelompok: _lastIdKelompok,
          tanggal: _lastTanggal,
          forceRefresh: true,
        );
      }
      return ok;
    } catch (e) {
      return false;
    }
  }

  // ── WRITE: Update Riwayat ────────────────────────────────────────────────

  Future<bool> updateRiwayat(
      int idPrestasi, Map<String, dynamic> payload) async {
    try {
      final ok = await repository.updateRiwayat(idPrestasi, payload);
      if (ok) {
        fetchSantriList(
          idKelompok: _lastIdKelompok,
          tanggal: _lastTanggal,
          forceRefresh: true,
        );
      }
      return ok;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _kelompokSubscription.cancel();
    return super.close();
  }
}
