import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';

class SantriCatatanApiService {
  // ─── Data Santri ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getSantriList({
    String? cari,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> q = {
      'page': page,
      'limit': limit,
    };
    if (cari != null && cari.isNotEmpty) q['cari'] = cari;
    return CoreApiClient.get('guru/santri', queryParameters: q);
  }

  static Future<Map<String, dynamic>> getSantriDetail(String nis) async {
    return CoreApiClient.get('guru/santri/show/$nis');
  }

  static Future<List<Map<String, dynamic>>> cariSantri(String query) async {
    try {
      final response = await CoreApiClient.get('guru/santri', queryParameters: {'cari': query, 'limit': 100});
      final data = response['data'] ?? response;
      if (data is Map && data['santri_list'] != null) {
        return (data['santri_list'] as List).whereType<Map>().map((e) {
          final Map<String, dynamic> safeMap = {};
          e.forEach((key, value) => safeMap[key.toString()] = value);
          return safeMap;
        }).toList();
      } else if (data is List) {
        return data.whereType<Map>().map((e) {
          final Map<String, dynamic> safeMap = {};
          e.forEach((key, value) => safeMap[key.toString()] = value);
          return safeMap;
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── DAFTAR TES ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCalonTes({String? kodeJalur}) async {
    final Map<String, dynamic> q = {};
    if (kodeJalur != null && kodeJalur.isNotEmpty) q['kode_jalur'] = kodeJalur;
    return CoreApiClient.get('guru/tes/calon', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> daftarkanTes({
    required String nis,
    required String idKelas,
    required String idKelompok,
    required String kodeJalur,
  }) async {
    return CoreApiClient.post('guru/tes/daftarkan', {
      'nis': nis,
      'id_kelas': idKelas,
      'id_kelompok': idKelompok,
      'kode_jalur': kodeJalur,
    });
  }

  static Future<Map<String, dynamic>> getAntrianTes({String? kodeJalur}) async {
    final Map<String, dynamic> q = {};
    if (kodeJalur != null && kodeJalur.isNotEmpty) q['kode_jalur'] = kodeJalur;
    return CoreApiClient.get('guru/tes/antrian', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> batalkanTes({
    required String idDaftar,
  }) async {
    return CoreApiClient.post('guru/tes/batalkan', {'id_daftar': idDaftar});
  }

  static Future<Map<String, dynamic>> getRiwayatTes({
    String? status,
    required String tglMulai,
    required String tglAkhir,
    String? kodeJalur,
  }) async {
    final Map<String, dynamic> q = {
      'tgl_mulai': tglMulai,
      'tgl_akhir': tglAkhir,
    };
    if (status != null && status.isNotEmpty) q['status'] = status;
    if (kodeJalur != null && kodeJalur.isNotEmpty) q['kode_jalur'] = kodeJalur;
    return CoreApiClient.get('guru/tes/riwayat', queryParameters: q);
  }

  // ── MASALAH SANTRI ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMasalahAktif({
    int? idKelompok,
    int? idKelas,
  }) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    return CoreApiClient.get('guru/masalah', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getMasalahSelesai({
    int? idKelompok,
    int? idKelas,
  }) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    return CoreApiClient.get('guru/masalah/selesai', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getMasalahPendingApproval() async {
    return CoreApiClient.get('guru/masalah/pending');
  }

  static Future<Map<String, dynamic>> storeMasalah({
    required String nis,
    required String jenisMasalah,
    required String keterangan,
    required String tglMasalah,
  }) async {
    final payload = {
      'nis': nis,
      'jenis_masalah': jenisMasalah,
      'keterangan': keterangan,
      'tgl_deteksi': tglMasalah,
    };
    return CoreApiClient.post('guru/masalah/store', payload);
  }

  static Future<Map<String, dynamic>> updateMasalah({
    required String id,
    required String status,
    String? tglSelesai,
    String? catatanSelesai,
  }) async {
    return CoreApiClient.post('guru/masalah/update', {
      'id_masalah': id,
      'status': status,
      if (tglSelesai != null) 'tgl_selesai': tglSelesai,
      if (catatanSelesai != null) 'catatan_selesai': catatanSelesai,
    });
  }

  static Future<Map<String, dynamic>> storeTahapMasalah({
    required String idMasalah,
    required String jenisPenyelesaian,
    required String tglPenyelesaian,
    required String keterangan,
    required String hasilTahap,
  }) async {
    return CoreApiClient.post('guru/masalah/storeTahap', {
      'id_masalah': idMasalah,
      'jenis_penyelesaian': jenisPenyelesaian,
      'tgl_penyelesaian': tglPenyelesaian,
      'keterangan': keterangan,
      'hasil_tahap': hasilTahap,
    });
  }

  static Future<Map<String, dynamic>> setujuiMasalah({
    required String id,
  }) async {
    return CoreApiClient.post('guru/masalah/setujui', {'id_masalah': id});
  }

  static Future<Map<String, dynamic>> tolakMasalah({
    required String id,
    required String catatan,
  }) async {
    return CoreApiClient.post('guru/masalah/tolak', {
      'id_masalah': id,
      'catatan_penolakan': catatan,
    });
  }

  // ─── Catatan Master ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCatatanMaster({
    int? idKelompok,
    int? idKelas,
    int? idKategori,
  }) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    if (idKategori != null && idKategori > 0) q['id_kategori'] = idKategori;
    return CoreApiClient.get('guru/catatan-master', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> storeCatatanMaster(
    Map<String, dynamic> data,
  ) async {
    return CoreApiClient.post('guru/catatan-master/store', data);
  }

  static Future<Map<String, dynamic>> updateCatatanMaster(
    Map<String, dynamic> data,
  ) async {
    return CoreApiClient.post('guru/catatan-master/update', data);
  }

  static Future<Map<String, dynamic>> deleteCatatanMaster(int idCatatan) async {
    return CoreApiClient.post('guru/catatan-master/hapus', {'id_catatan': idCatatan});
  }
}
