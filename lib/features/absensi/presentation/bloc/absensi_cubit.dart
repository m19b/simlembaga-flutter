import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════════════════

abstract class AbsensiState {}

class AbsensiInitial extends AbsensiState {}

class AbsensiLoading extends AbsensiState {}

/// State yang dibawa saat data Absen Mandiri berhasil dimuat.
class AbsenMandiriLoaded extends AbsensiState {
  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> riwayat;
  AbsenMandiriLoaded({required this.status, required this.riwayat});
}

/// State generik untuk data berbentuk [Map] (digunakan Absen Harian & Rekap).
class AbsensiLoaded extends AbsensiState {
  final Map<String, dynamic> data;
  AbsensiLoaded(this.data);
}

class AbsensiError extends AbsensiState {
  final String message;
  AbsensiError(this.message);
}

/// State aksi sedang berjalan (submit/post), bukan loading awal.
class AbsensiActionLoading extends AbsensiState {
  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> riwayat;
  AbsensiActionLoading({required this.status, required this.riwayat});
}

/// State setelah submit absen mandiri berhasil — membawa pesan sukses.
class AbsenMandiriSubmitSuccess extends AbsensiState {
  final String message;
  final bool isWarning;
  AbsenMandiriSubmitSuccess({required this.message, this.isWarning = false});
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class AbsensiCubit extends Cubit<AbsensiState> {
  final AbsensiRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSub;

  // Simpan parameter terakhir agar bisa re-fetch saat kelompok berubah
  String _lastTanggal = '';
  String _lastIdKelas = '';
  int _lastIdKelompok = 0;

  AbsensiCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(AbsensiInitial()) {
    _kelompokSub = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0) {
        // Re-fetch absen harian jika parameter tersedia
        if (_lastTanggal.isNotEmpty && _lastIdKelas.isNotEmpty) {
          fetchAbsenHarian(_lastTanggal, _lastIdKelas);
        }
        // Re-fetch mandiri jika parameter tersedia
        if (_lastIdKelompok > 0) {
          fetchAbsenMandiri(_lastIdKelompok);
        }
      }
    });
  }

  // ── Absen Mandiri (Offline-First) ─────────────────────────────────────────

  Future<void> fetchAbsenMandiri(int idKelompok) async {
    _lastIdKelompok = idKelompok;
    emit(AbsensiLoading());
    try {
      final resp = await repository.getStatusAbsenMandiri(idKelompok);
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      final status = (data['status_absen'] as Map<String, dynamic>?) ?? {};
      final rawRiwayat = data['riwayat_absen'];
      final riwayat = _parseRiwayat(rawRiwayat);
      emit(AbsenMandiriLoaded(status: status, riwayat: riwayat));
    } catch (e) {
      emit(AbsensiError(_cleanMessage(e)));
    }
  }

  Future<void> submitAbsenMandiri({
    required String tipe,
    required int idKelompok,
    double? lat,
    double? lng,
    // State saat ini diperlukan agar UI tidak blank saat action loading
    required Map<String, dynamic> currentStatus,
    required List<Map<String, dynamic>> currentRiwayat,
  }) async {
    emit(AbsensiActionLoading(status: currentStatus, riwayat: currentRiwayat));
    try {
      final resp = await repository.postAbsenMandiri(
        tipe: tipe,
        idKelompok: idKelompok,
        lat: lat,
        lng: lng,
      );

      // Refresh data dari server setelah berhasil
      await fetchAbsenMandiri(idKelompok);

      final msg = resp
          ? '✅ Berhasil absen ${tipe == 'datang' ? 'Masuk' : 'Pulang'}'
          : '✅ Berhasil absen ${tipe == 'datang' ? 'Masuk' : 'Pulang'}';
      emit(AbsenMandiriSubmitSuccess(message: msg));
    } catch (e) {
      emit(AbsensiError(_cleanMessage(e)));
    }
  }

  // ── Absen Harian Massal (Offline-First) ───────────────────────────────────

  Future<void> fetchAbsenHarian(String tanggal, String idKelas) async {
    _lastTanggal = tanggal;
    _lastIdKelas = idKelas;
    emit(AbsensiLoading());
    try {
      final data = await repository.getAbsenHarian(tanggal, idKelas);
      emit(AbsensiLoaded(data));
    } catch (e) {
      emit(AbsensiError(_cleanMessage(e)));
    }
  }

  Future<bool> submitAbsenMassal(Map<String, dynamic> payload) async {
    final result = await repository.simpanAbsenMassal(payload);
    if (result) fetchAbsenHarian(_lastTanggal, _lastIdKelas);
    return result;
  }

  // ── Rekap Absen (Network-Only) ────────────────────────────────────────────

  Future<void> fetchRekapAbsen(
    String tanggalAwal,
    String tanggalAkhir, {
    int? idKelas,
  }) async {
    emit(AbsensiLoading());
    try {
      final data = await repository.getRekapAbsen(
        tanggalAwal,
        tanggalAkhir,
        idKelas: idKelas,
      );
      emit(AbsensiLoaded(data));
    } catch (e) {
      emit(AbsensiError(_cleanMessage(e)));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _parseRiwayat(dynamic rawRiwayat) {
    if (rawRiwayat is! List) return [];
    return rawRiwayat.whereType<Map>().map((e) {
      final Map<String, dynamic> m = {};
      e.forEach((k, v) => m[k.toString()] = v);
      return m;
    }).toList();
  }

  String _cleanMessage(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  @override
  Future<void> close() {
    _kelompokSub.cancel();
    return super.close();
  }
}
