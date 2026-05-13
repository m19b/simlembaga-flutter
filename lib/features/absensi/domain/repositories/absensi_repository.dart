import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

/// Aturan Triage Offline (HARGA MATI):
/// - [getAbsenHarian]   → OFFLINE-FIRST (Cache-Then-Network)
/// - [getRekapAbsen]    → NETWORK-ONLY (100% real-time, dilarang Hive)
/// - [simpanAbsenMassal] / [scanAbsen] → Optimistic Queue Box
class AbsensiRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  AbsensiRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  // ── READ: CACHE-THEN-NETWORK ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getAbsenHarian(String tanggal, String idKelas) async {
    final cacheKey = 'absen_harian_${tanggal}_$idKelas';

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getAbsenHarian(
          tanggal: tanggal,
          idKelas: int.tryParse(idKelas),
        );
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (_) {
        final cached = await localDataSource.getCachedData(cacheKey);
        if (cached != null) return cached;
        throw Exception('Gagal memuat absensi dari server dan cache kosong.');
      }
    }

    final cached = await localDataSource.getCachedData(cacheKey);
    if (cached != null) return cached;
    throw Exception('Offline: Data absensi hari ini belum ada di cache.');
  }

  Future<Map<String, dynamic>> getStatusAbsenMandiri(int idKelompok) async {
    final cacheKey = 'status_absen_mandiri_$idKelompok';

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getStatusAbsenMandiri(idKelompok);
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (_) {
        final cached = await localDataSource.getCachedData(cacheKey);
        if (cached != null) return cached;
        throw Exception('Gagal memuat status absensi mandiri.');
      }
    }

    final cached = await localDataSource.getCachedData(cacheKey);
    if (cached != null) return cached;
    throw Exception('Offline: Status absensi mandiri belum tersedia di cache.');
  }

  // ── READ: NETWORK-ONLY (rekap pimpinan — DILARANG CACHE) ─────────────────

  Future<Map<String, dynamic>> getRekapAbsen(
    String tanggalAwal,
    String tanggalAkhir, {
    int? idKelas,
  }) async {
    if (!await networkInfo.isConnected) {
      throw Exception('Tidak ada koneksi ke server. Halaman rekap memerlukan data real-time.');
    }
    try {
      return await ApiService.getRekapAbsen(
        tglMulai: tanggalAwal,
        tglAkhir: tanggalAkhir,
        idKelas: idKelas,
      );
    } catch (e) {
      throw Exception('Gagal memuat rekap absensi dari server.');
    }
  }

  Future<Map<String, dynamic>> getFilterKelas() async {
    if (!await networkInfo.isConnected) {
      throw Exception('Tidak ada koneksi ke server.');
    }
    return ApiService.getFilterKelas();
  }

  // ── WRITE: OPTIMISTIC QUEUE BOX ───────────────────────────────────────────

  Future<bool> postAbsenMandiri({
    required String tipe,
    required int idKelompok,
    double? lat,
    double? lng,
  }) async {
    final payload = {
      'tipe': tipe,
      'id_kelompok': idKelompok,
      'lat': lat,
      'lng': lng,
    };
    if (await networkInfo.isConnected) {
      try {
        final res = await ApiService.postAbsenMandiri(
          tipe: tipe,
          idKelompok: idKelompok,
          lat: lat,
          lng: lng,
        );
        return res['status'] == 200 || res['success'] == true || res['message'] != null;
      } catch (e) {
        return _enqueuePayload('api/guru/absensi/mandiri', payload);
      }
    }
    return _enqueuePayload('api/guru/absensi/mandiri', payload);
  }

  Future<bool> simpanAbsenMassal(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final res = await ApiService.simpanAbsenMassal(payload);
        return res['status'] == 200 || res['success'] == true;
      } catch (_) {
        return _enqueuePayload('api/guru/absensi/simpan-massal', payload);
      }
    }
    return _enqueuePayload('api/guru/absensi/simpan-massal', payload);
  }

  Future<bool> scanAbsen(String cleanCode, String type) async {
    final payload = {'cleanCode': cleanCode, 'type': type};
    if (await networkInfo.isConnected) {
      try {
        await ApiService.scanAbsen(cleanCode, type);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/absensi/scan', payload);
      }
    }
    return _enqueuePayload('api/guru/absensi/scan', payload);
  }

  Future<bool> _enqueuePayload(String endpoint, Map<String, dynamic> payload) async {
    await localDataSource.enqueueRequest(endpoint, payload);
    return true;
  }
}
