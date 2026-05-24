import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/santri_binaan_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/santri_universal_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/guru_universal_cache.dart';

class AbsensiApiService {
  static Future<Map<String, dynamic>> scanAbsen(
    String kode,
    String waktu,
  ) async {
    return CoreApiClient.post('guru/absen-santri/scan', {'kode': kode, 'waktu': waktu});
  }

  static Future<Map<String, dynamic>> getRekapAbsen({
    int? idKelompok,
    int? idKelas,
    String? tglMulai,
    String? tglAkhir,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (idKelompok != null && idKelompok > 0) queryParams['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) queryParams['id_kelas'] = idKelas;
    if (tglMulai != null && tglMulai.isNotEmpty) queryParams['tgl_mulai'] = tglMulai;
    if (tglAkhir != null && tglAkhir.isNotEmpty) queryParams['tgl_akhir'] = tglAkhir;

    return CoreApiClient.get(
      'guru/absen-santri/rekap',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  static Future<Map<String, dynamic>> getStatusAbsenMandiri(
    int idKelompok,
  ) async {
    return CoreApiClient.get(
      'guru/absen-guru',
      queryParameters: idKelompok > 0 ? {'id_kelompok': idKelompok} : null,
    );
  }

  static Future<Map<String, dynamic>> postAbsenMandiri({
    required String tipe,
    required int idKelompok,
    double? lat,
    double? lng,
  }) async {
    return CoreApiClient.post('guru/absen-guru/store', {
      'tipe': tipe,
      'id_kelompok': idKelompok,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  static Future<Map<String, dynamic>> getAbsenHarian({
    String? tanggal,
    int? idKelas,
    String? kodeJalur,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (tanggal != null) queryParams['tanggal'] = tanggal;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;
    if (kodeJalur != null) queryParams['kode_jalur'] = kodeJalur;

    return CoreApiClient.get(
      'guru/absen-santri',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  static Future<Map<String, dynamic>> simpanAbsenMassal(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/absen-santri/simpan', payload);
  }

  static Future<void> syncSantriBinaan() async {
    try {
      final res = await CoreApiClient.get('guru/absen-santri/binaan');
      final listSantri = (res['data']?['santri'] as List?) ?? [];
      
      final isar = IsarDb.instance;
      await isar.writeTxn(() async {
        await isar.santriBinaanCaches.clear();
        
        final insertList = <SantriBinaanCache>[];
        for (var s in listSantri) {
          insertList.add(SantriBinaanCache()
            ..nis = s['nis']?.toString() ?? ''
            ..nama = s['nama_santri'] ?? ''
            ..tingkatKelas = s['tingkat']
            ..kodeJalur = s['kode_jalur']
            ..idKelas = int.tryParse(s['id_kelas']?.toString() ?? '0') ?? 0
          );
        }
        await isar.santriBinaanCaches.putAll(insertList);
      });
    } catch (_) {
      // Abaikan error (fail silently di background)
    }
  }

  static Future<int> syncSemuaSantri() async {
    final res = await CoreApiClient.get('guru/absen-santri/all-santri');
    final listSantri = (res['data']?['santri'] as List?) ?? [];
    
    final isar = IsarDb.instance;
    await isar.writeTxn(() async {
      await isar.santriUniversalCaches.clear();
      
      final insertList = <SantriUniversalCache>[];
      for (var s in listSantri) {
        insertList.add(SantriUniversalCache()
          ..nis = s['nis']?.toString() ?? ''
          ..nama = s['nama_santri'] ?? ''
          ..tingkatKelas = s['tingkat']
          ..kodeJalur = s['kode_jalur']
          ..idKelas = int.tryParse(s['id_kelas']?.toString() ?? '0') ?? 0
        );
      }
      await isar.santriUniversalCaches.putAll(insertList);
    });

    return listSantri.length;
  }

  static Future<int> syncSemuaGuru() async {
    final res = await CoreApiClient.get('guru/absen-santri/all-guru');
    final listGuru = (res['data']?['guru'] as List?) ?? [];
    
    final isar = IsarDb.instance;
    await isar.writeTxn(() async {
      await isar.guruUniversalCaches.clear();
      
      final insertList = <GuruUniversalCache>[];
      for (var s in listGuru) {
        insertList.add(GuruUniversalCache()
          ..nig = s['nig']?.toString() ?? ''
          ..nama = s['nama_guru'] ?? ''
        );
      }
      await isar.guruUniversalCaches.putAll(insertList);
    });

    return listGuru.length;
  }
}
