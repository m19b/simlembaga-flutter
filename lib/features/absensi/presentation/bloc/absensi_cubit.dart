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
/// Membawa state saat ini agar UI tidak blank selama proses.
class AbsensiActionLoading extends AbsensiState {
  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> riwayat;

  AbsensiActionLoading({required this.status, required this.riwayat});
}

/// State saat GPS sedang diambil — tombol menampilkan spinner GPS.
class AbsensiGpsLoading extends AbsensiState {
  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> riwayat;

  AbsensiGpsLoading({required this.status, required this.riwayat});
}

/// State setelah submit absen mandiri berhasil — membawa pesan sukses.
class AbsenMandiriSubmitSuccess extends AbsensiState {
  final String message;
  final bool isWarning;

  /// [savedOffline] = true → data tersimpan di Isar, menunggu sinkronisasi.
  final bool savedOffline;

  AbsenMandiriSubmitSuccess({
    required this.message,
    this.isWarning = false,
    this.savedOffline = false,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

class AbsensiCubit extends Cubit<AbsensiState> {
  final AbsensiRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription<dynamic> _kelompokSub;

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
        if (_lastTanggal.isNotEmpty && _lastIdKelas.isNotEmpty) {
          fetchAbsenHarian(_lastTanggal, _lastIdKelas);
        }
        if (_lastIdKelompok > 0) {
          fetchAbsenMandiri(_lastIdKelompok);
        }
      }
    });
  }

  // ── Absen Mandiri (Offline-First + GPS-Safe) ──────────────────────────────

  Future<void> fetchAbsenMandiri(int idKelompok) async {
    _lastIdKelompok = idKelompok;
    emit(AbsensiLoading());
    try {
      final Map<String, dynamic> resp =
          await repository.getStatusAbsenMandiri(idKelompok);
      final Map<String, dynamic> data =
          (resp['data'] as Map<String, dynamic>?) ?? {};
      final Map<String, dynamic> status =
          (data['status_absen'] as Map<String, dynamic>?) ?? {};
      final List<Map<String, dynamic>> riwayat =
          _parseRiwayat(data['riwayat_absen']);
      emit(AbsenMandiriLoaded(status: status, riwayat: riwayat));
    } catch (e) {
      emit(AbsensiError(_cleanMessage(e)));
    }
  }

  /// Dipanggil oleh UI sebelum mengambil GPS, agar tombol langsung berubah
  /// menjadi spinner tanpa menunggu proses async GPS selesai.
  void setActionLoading({
    required Map<String, dynamic> status,
    required List<Map<String, dynamic>> riwayat,
  }) {
    emit(AbsensiActionLoading(status: status, riwayat: riwayat));
  }

  /// Submit absen mandiri dengan dukungan:
  /// - GPS Loading State (tombol spinner aktif, UI tidak freeze)
  /// - Optimistic Offline Queue (jika LAN mati, tetap "Berhasil" di UI)
  /// - GPS Timeout: jika > 5 detik, lanjut tanpa koordinat
  Future<void> submitAbsenMandiri({
    required String tipe,
    required int idKelompok,
    // GPS position dilewatkan dari UI setelah diambil dengan timeout
    double? lat,
    double? lng,
    required Map<String, dynamic> currentStatus,
    required List<Map<String, dynamic>> currentRiwayat,
  }) async {
    emit(AbsensiActionLoading(status: currentStatus, riwayat: currentRiwayat));

    try {
      final AbsenMandiriResult result = await repository.postAbsenMandiri(
        tipe: tipe,
        idKelompok: idKelompok,
        lat: lat,
        lng: lng,
      );

      if (!result.success) {
        emit(AbsensiError('Gagal menyimpan absen. Silakan coba lagi.'));
        return;
      }

      if (!result.savedOffline) {
        // Online sukses → refresh dari server
        await fetchAbsenMandiri(idKelompok);
      }

      emit(AbsenMandiriSubmitSuccess(
        message: result.message,
        isWarning: result.isWarning,
        savedOffline: result.savedOffline,
      ));
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
      final Map<String, dynamic> data =
          await repository.getAbsenHarian(tanggal, idKelas);
      emit(AbsensiLoaded(data));
    } catch (e) {
      emit(AbsensiError(_cleanMessage(e)));
    }
  }

  Future<bool> submitAbsenMassal(Map<String, dynamic> payload) async {
    final bool result = await repository.simpanAbsenMassal(payload);
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
      final Map<String, dynamic> data = await repository.getRekapAbsen(
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
