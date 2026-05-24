import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';

class PraTahfidzApiService {
  static Future<Map<String, dynamic>> getPraTahfidzList({
    String? tanggal,
    int? idKelompok,
    List<int>? kelasIds,
    int? sesi,
    String? filterKehadiran,
  }) async {
    final Map<String, dynamic> q = {};
    if (tanggal != null && tanggal.isNotEmpty) q['tanggal'] = tanggal;
    if (idKelompok != null) q['id_kelompok'] = idKelompok.toString();
    if (kelasIds != null && kelasIds.isNotEmpty) q['kelas_ids'] = kelasIds.join(',');
    if (sesi != null) q['sesi'] = sesi.toString();
    if (filterKehadiran != null && filterKehadiran.isNotEmpty) q['filter_kehadiran'] = filterKehadiran;
    
    return CoreApiClient.get('guru/pra-tahfidz', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getPraTahfidzDetail(String nis) async {
    return CoreApiClient.get('guru/pra-tahfidz/detail/$nis');
  }

  static Future<Map<String, dynamic>> getPraTahfidzDashboard(
    String nis, {
    String? tglDari,
    String? tglSampai,
  }) async {
    final Map<String, dynamic> q = {};
    if (tglDari != null) q['tgl_dari'] = tglDari;
    if (tglSampai != null) q['tgl_sampai'] = tglSampai;
    return CoreApiClient.get(
      'guru/pra-tahfidz/dashboard/$nis',
      queryParameters: q.isEmpty ? null : q,
    );
  }

  static Future<Map<String, dynamic>> inputCepatPraTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/pra-tahfidz/input-cepat', payload);
  }

  static Future<Map<String, dynamic>> inputMassalPraTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return CoreApiClient.post('guru/pra-tahfidz/input-massal', payload);
  }

  static Future<Map<String, dynamic>> updatePraTahfidz(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    return CoreApiClient.post('guru/pra-tahfidz/update/$idPrestasi', data);
  }

  static Future<Map<String, dynamic>> deletePraTahfidz(int idPrestasi) async {
    return CoreApiClient.post('guru/pra-tahfidz/delete/$idPrestasi', {});
  }
}
