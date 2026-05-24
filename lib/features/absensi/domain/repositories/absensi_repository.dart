import 'dart:convert';

import 'package:manajemen_tahsin_app/core/api/services/absensi_api_service.dart';
import 'package:manajemen_tahsin_app/core/api/services/dashboard_api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

/// Aturan Triage Offline (HARGA MATI):
/// - [getAbsenHarian]    → OFFLINE-FIRST (Cache-Then-Network)
/// - [getRekapAbsen]     → NETWORK-ONLY (100% real-time, dilarang cache)
/// - [postAbsenMandiri]  → Optimistic Offline Queue (simpan ke Isar jika LAN mati)
/// - [simpanAbsenMassal] → Optimistic Queue Box
class AbsensiRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  AbsensiRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  // ── READ: CACHE-THEN-NETWORK ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getAbsenHarian(
    String tanggal,
    String idKelas, {
    String? kodeJalur,
  }) async {
    final String cacheKey = 'absen_harian_${tanggal}_${idKelas}_${kodeJalur ?? "all"}';

    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> data = await AbsensiApiService.getAbsenHarian(
          tanggal: tanggal,
          idKelas: int.tryParse(idKelas),
          kodeJalur: kodeJalur,
        );
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (_) {
        final Map<String, dynamic>? cached =
            await localDataSource.getCachedData(cacheKey);
        if (cached != null) return cached;
        throw Exception('Gagal memuat absensi dari server dan cache kosong.');
      }
    }

    final Map<String, dynamic>? cached =
        await localDataSource.getCachedData(cacheKey);
    if (cached != null) return cached;
    throw Exception('Offline: Data absensi hari ini belum ada di cache.');
  }

  Future<Map<String, dynamic>> getStatusAbsenMandiri(int idKelompok) async {
    final String cacheKey = 'status_absen_mandiri_$idKelompok';

    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> data =
            await AbsensiApiService.getStatusAbsenMandiri(idKelompok);
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (_) {
        final Map<String, dynamic>? cached =
            await localDataSource.getCachedData(cacheKey);
        if (cached != null) return cached;
        throw Exception('Gagal memuat status absensi mandiri.');
      }
    }

    final Map<String, dynamic>? cached =
        await localDataSource.getCachedData(cacheKey);
    if (cached != null) return cached;
    throw Exception('Offline: Status absensi mandiri belum tersedia di cache.');
  }

  // ── READ: NETWORK-ONLY (rekap pimpinan — DILARANG CACHE) ─────────────────

  Future<Map<String, dynamic>> getRekapAbsen(
    String tanggalAwal,
    String tanggalAkhir, {
    int? idKelas,
  }) async {
    final String cacheKey = 'rekap_absen_${tanggalAwal}_${tanggalAkhir}_$idKelas';

    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> data = await AbsensiApiService.getRekapAbsen(
          tglMulai: tanggalAwal,
          tglAkhir: tanggalAkhir,
          idKelas: idKelas,
        );
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (_) {
        final Map<String, dynamic>? cached = await localDataSource.getCachedData(cacheKey);
        if (cached != null) return cached;
        throw Exception('Gagal memuat rekap absensi dari server dan cache kosong.');
      }
    }

    final Map<String, dynamic>? cached = await localDataSource.getCachedData(cacheKey);
    if (cached != null) return cached;
    throw Exception('Offline: Data rekap absensi belum ada di cache.');
  }

  Future<Map<String, dynamic>> getFilterKelas() async {
    const String cacheKey = 'rekap_filter_kelas';
    if (await networkInfo.isConnected) {
      try {
        final data = await DashboardApiService.getFilterKelas();
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (_) {
        final cached = await localDataSource.getCachedData(cacheKey);
        if (cached != null) return cached;
        throw Exception('Gagal memuat filter kelas dan cache kosong.');
      }
    }
    
    final cached = await localDataSource.getCachedData(cacheKey);
    if (cached != null) return cached;
    throw Exception('Tidak ada koneksi ke server dan filter belum dicache.');
  }

  // ── WRITE: OPTIMISTIC QUEUE BOX ──────────────────────────────────────────

  /// Submit Absen Mandiri Guru dengan GPS.
  /// Payload wajib menyertakan [timestamp] dan koordinat GPS agar antrean
  /// offline tetap akurat saat disinkronkan ke server nanti.
  Future<AbsenMandiriResult> postAbsenMandiri({
    required String tipe,
    required int idKelompok,
    double? lat,
    double? lng,
  }) async {
    // Timestamp diambil saat tombol ditekan (bukan saat sync) — kritis untuk absensi
    final String timestamp = DateTime.now().toIso8601String();

    final Map<String, dynamic> payload = {
      'tipe': tipe,
      'id_kelompok': idKelompok,
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp,
    };

    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> res = await AbsensiApiService.postAbsenMandiri(
          tipe: tipe,
          idKelompok: idKelompok,
          lat: lat,
          lng: lng,
        );
        final bool ok =
            res['status'] == 200 ||
            res['success'] == true ||
            res['message'] != null;
        return AbsenMandiriResult(
          success: ok,
          savedOffline: false,
          message: res['message']?.toString() ??
              '✅ Berhasil absen ${tipe == 'datang' ? 'Masuk' : 'Pulang'}',
          isWarning: res['sudah_absen'] == true,
        );
      } catch (_) {
        // Server error → masuk ke offline queue
        await _enqueuePayload('api/guru/absen-guru/store', payload);
        return AbsenMandiriResult(
          success: true,
          savedOffline: true,
          message:
              '📥 Disimpan Offline: Absen ${tipe == 'datang' ? 'Masuk' : 'Pulang'} akan dikirim saat server aktif.',
        );
      }
    }

    // LAN mati → langsung masuk offline queue
    await _enqueuePayload('api/guru/absen-guru/store', payload);
    return AbsenMandiriResult(
      success: true,
      savedOffline: true,
      message:
          '📥 Disimpan Offline: Absen ${tipe == 'datang' ? 'Masuk' : 'Pulang'} akan dikirim saat server aktif.',
    );
  }

  Future<bool> simpanAbsenMassal(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> res =
            await AbsensiApiService.simpanAbsenMassal(payload);
        return res['status'] == 200 || res['success'] == true;
      } catch (_) {
        return _enqueuePayload('api/guru/absen-santri/simpan', payload);
      }
    }
    return _enqueuePayload('api/guru/absen-santri/simpan', payload);
  }

  Future<bool> scanAbsen(String cleanCode, String type) async {
    final Map<String, dynamic> payload = {
      'cleanCode': cleanCode,
      'type': type,
    };
    if (await networkInfo.isConnected) {
      try {
        await AbsensiApiService.scanAbsen(cleanCode, type);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/absen-santri/scan', payload);
      }
    }
    return _enqueuePayload('api/guru/absen-santri/scan', payload);
  }

  Future<bool> _enqueuePayload(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    // Encode ke JSON string agar aman disimpan di Isar (teks murni)
    final String payloadJson = jsonEncode(payload);
    await localDataSource.enqueueRequest(endpoint, {'__json': payloadJson});
    return true;
  }
}

// ── Value Object Hasil Submit ─────────────────────────────────────────────────
/// Membawa hasil submit absen mandiri secara eksplisit.
/// Menghindari parsing `bool` generik yang tidak informatif.
class AbsenMandiriResult {
  final bool success;
  final bool savedOffline;
  final String message;
  final bool isWarning;

  const AbsenMandiriResult({
    required this.success,
    required this.savedOffline,
    required this.message,
    this.isWarning = false,
  });
}
