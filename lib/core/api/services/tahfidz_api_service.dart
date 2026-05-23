import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';

/// Domain service khusus untuk Tahfidz Al-Qur'an
class TahfidzApiService {
  static Future<Map<String, dynamic>> getTahfidzList({
    String? tanggal,
    int? sesi,
    String? filterKehadiran,
  }) async {
    final Map<String, dynamic> q = {};
    if (tanggal != null && tanggal.isNotEmpty) q['tanggal'] = tanggal;
    if (sesi != null) q['sesi'] = sesi;
    if (filterKehadiran != null && filterKehadiran.isNotEmpty) {
      q['filter_kehadiran'] = filterKehadiran;
    }
    return CoreApiClient.get('guru/tahfidz-quran', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getTahfidzDetail(String nis) async {
    return CoreApiClient.get('guru/tahfidz-quran/detail/$nis');
  }

  static Future<Map<String, dynamic>> getTahfidzDashboard(
    String nis, {
    String? tglDari,
    String? tglSampai,
  }) async {
    final Map<String, dynamic> q = {};
    if (tglDari != null) q['tgl_dari'] = tglDari;
    if (tglSampai != null) q['tgl_sampai'] = tglSampai;
    return CoreApiClient.get(
      'guru/tahfidz-quran/dashboard/$nis',
      queryParameters: q.isEmpty ? null : q,
    );
  }

  static Future<Map<String, dynamic>> inputCepatTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/tahfidz-quran/input-cepat', payload);
  }

  static Future<Map<String, dynamic>> inputMassalTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/tahfidz-quran/input-massal', payload);
  }

  static Future<Map<String, dynamic>> updateTahfidz(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    return CoreApiClient.post('guru/tahfidz-quran/update/$idPrestasi', data);
  }

  static Future<Map<String, dynamic>> deleteTahfidz(
    int idPrestasi,
    String nis,
  ) async {
    return CoreApiClient.post('guru/tahfidz-quran/delete/$idPrestasi', {'nis': nis});
  }
}
