import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';

class TahsinApiService {
  static Future<Map<String, dynamic>> getDeltaProgress({
    int? idKelompok,
    int? idKelas,
    String? lastSync,
    List<String>? existingNis,
  }) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    
    final payload = {
      'existing_nis': existingNis ?? [],
      if (lastSync != null && lastSync.isNotEmpty) 'last_sync': lastSync,
    };
    
    return CoreApiClient.post(
      'guru/progress/getDeltaProgress',
      payload,
      queryParameters: q.isEmpty ? null : q,
    );
  }

  static Future<Map<String, dynamic>> getProgressList({
    String? cari,
    int? idKelompok,
    int? idKelas,
    int page = 1,
    int limit = 20,
    String? filterKehadiran,
    String? tanggal,
    int? sesi,
  }) async {
    final Map<String, dynamic> q = {
      'page': page,
      'limit': limit,
    };
    if (cari != null && cari.isNotEmpty) q['cari'] = cari;
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    if (filterKehadiran != null && filterKehadiran.isNotEmpty && filterKehadiran != 'semua') {
      q['filter_kehadiran'] = filterKehadiran;
    }
    if (tanggal != null && tanggal.isNotEmpty) q['tanggal'] = tanggal;
    if (sesi != null) q['sesi'] = sesi;
    return CoreApiClient.get('guru/progress', queryParameters: q);
  }

  static Future<Map<String, dynamic>> getProgressDetail(String nis) async {
    return CoreApiClient.get('guru/progress/detail/$nis');
  }

  static Future<Map<String, dynamic>> inputCepatProgress(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/progress/input-cepat', payload);
  }

  static Future<Map<String, dynamic>> inputMassalProgress(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/progress/input-massal', payload);
  }

  static Future<Map<String, dynamic>> deleteProgress(int idPrestasi) async {
    return CoreApiClient.post('guru/progress/delete', {'id_prestasi': idPrestasi});
  }

  static Future<Map<String, dynamic>> updateProgress(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    data['id_prestasi'] = idPrestasi;
    return CoreApiClient.post('guru/progress/update', data);
  }

  static Future<Map<String, dynamic>> getRiwayatGlobal(
    String tanggal, {
    int page = 1,
    int limit = 20,
    int? idKelompok,
  }) async {
    final Map<String, dynamic> q = {
      'tanggal': tanggal,
      'page': page,
      'limit': limit,
    };
    if (idKelompok != null) {
      q['id_kelompok'] = idKelompok;
    }
    return CoreApiClient.get(
      'guru/riwayat-global',
      queryParameters: q,
    );
  }

  static Future<Map<String, dynamic>> getRiwayatGlobalChart(
    String tglMulai,
    String tglAkhir,
  ) async {
    return CoreApiClient.get(
      'guru/riwayat-global/chart',
      queryParameters: {'tgl_mulai': tglMulai, 'tgl_akhir': tglAkhir},
    );
  }

  static Future<Map<String, dynamic>> getLaporanPrestasi({
    String? tglMulai,
    String? tglAkhir,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> q = {
      'page': page,
      'limit': limit,
    };
    if (tglMulai != null && tglMulai.isNotEmpty) q['tgl_mulai'] = tglMulai;
    if (tglAkhir != null && tglAkhir.isNotEmpty) q['tgl_akhir'] = tglAkhir;
    return CoreApiClient.get('guru/laporan', queryParameters: q);
  }

  static Future<Map<String, dynamic>> getLaporanDetail(String nis) async {
    return CoreApiClient.get('guru/laporan/detail/$nis');
  }

  static Future<Map<String, dynamic>> getPrediksiKhataman() async {
    return CoreApiClient.get('guru/prediksi');
  }

  static Future<Map<String, dynamic>> sendWaReport({
    required String nis,
    required String target,
  }) async {
    return CoreApiClient.post('guru/progress/send-wa', {'nis': nis, 'target': target});
  }

  static Future<Map<String, dynamic>> sendKolektifWaReport({
    required String tglMulai,
    required String tglAkhir,
    int? idKelompok,
  }) async {
    return CoreApiClient.post('guru/progress/send-kolektif-wa', {
      'tgl_mulai': tglMulai,
      'tgl_akhir': tglAkhir,
      if (idKelompok != null) 'id_kelompok': idKelompok,
    });
  }
}
