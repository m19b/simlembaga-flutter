import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';
import 'package:manajemen_tahsin_app/features/auth/data/general_settings_model.dart';

class DashboardApiService {
  static Future<Map<String, dynamic>> getDashboardGuru({
    int? idKategori,
  }) async {
    final Map<String, dynamic> query = {};
    if (idKategori != null && idKategori > 0) query['id_kategori'] = idKategori;
    return CoreApiClient.get(
      'guru/dashboard',
      queryParameters: query.isEmpty ? null : query,
    );
  }

  static Future<GeneralSettings> getGeneralSettings() async {
    try {
      final result = await CoreApiClient.get('guru/settings');
      return GeneralSettings.fromJson(result['data']);
    } catch (e) {
      return GeneralSettings(namaAplikasi: 'SIM Lembaga', namaLembaga: '');
    }
  }

  static Future<Map<String, dynamic>> getFilterKelas({int? idKelompok}) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    return CoreApiClient.get('guru/filter/kelas', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getHariLibur({
    required int tahun,
    required int idKelompok,
  }) async {
    return CoreApiClient.get(
      'guru/hari-libur',
      queryParameters: {'tahun': tahun, 'id_kelompok': idKelompok},
    );
  }
}
