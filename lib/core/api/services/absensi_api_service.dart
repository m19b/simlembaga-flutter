import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';

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
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (tanggal != null) queryParams['tanggal'] = tanggal;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

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
}
