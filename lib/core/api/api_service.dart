import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'dio_client.dart';

/// Centralized API service. Menggunakan Dio dan Stateless Token Authentication.
class ApiService {
  static const String _userKey = 'LOGGED_IN_USER';
  static const _storage = FlutterSecureStorage();

  static void _handleDioError(DioException e) {
    // 1. Siapkan wadah untuk menampung semua rahasia error
    String debugMsg = "TIPE: ${e.type.name}\n";
    debugMsg += "PESAN: ${e.message}\n";

    // 2. Jika server CI4 sempat menjawab (meskipun error 500/404)
    if (e.response != null) {
      debugMsg += "STATUS: ${e.response?.statusCode}\n";

      // Ambil isi balasan CI4
      String rawData = e.response?.data.toString() ?? 'Tidak ada data';

      // Potong jika terlalu panjang agar muat di layar HP
      if (rawData.length > 200) {
        rawData = rawData.substring(0, 200) + '...';
      }
      debugMsg += "BALASAN: $rawData";
    } else {
      // 3. Jika server CI4 mati, salah IP, atau tidak merespon sama sekali
      debugMsg += "STATUS: Server tidak merespon sama sekali (Response Null).";
    }

    // MUNTAHKAN SEMUANYA KE LAYAR FLUTTER!
    throw Exception(debugMsg);
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static Future<UserModel> login(String identity, String password) async {
    try {
      final client = await DioClient.dio;
      final response = await client.post(
        '/api/login',
        data: {'identity': identity, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data as Map<String, dynamic>;
      final isSuccess = data['status'] == 200 || data['status'] == true;

      if (response.statusCode == 200 && isSuccess) {
        // Ambil token JWT dari respons (asumsi dikirim di properti 'token')
        // final token = data['token'];
        final token = data['data'] != null ? data['data']['token'] : null;
        if (token != null && token.toString().isNotEmpty) {
          await _storage.write(key: 'jwt_token', value: token.toString());
        }

        // Antisipasi mapping data sesuai standar baru
        final userData = data['data']['user'] ?? data['data'];
        final user = UserModel.fromJson(userData as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));

        return user;
      } else {
        throw Exception(
          data['message'] ?? 'Login gagal. Periksa kembali data Anda.',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<void> logout() async {
    try {
      final client = await DioClient.dio;
      // Opsional: beritahu server untuk mematikan token jika server mendukung blacklist token
      await client.post('/api/logout');
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      // Hapus token JWT lokal
      await _storage.delete(key: 'jwt_token');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      DioClient.reset(); // Reset Dio (misal user ganti server IP saat di login screen)
    }
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardGuru() async {
    return _get('guru/dashboard');
  }

  // ─── Absensi ───────────────────────────────────────────────────────────────

  /// POST /api/guru/absen/scan — Absen via Kamera/RFID/NIS
  static Future<Map<String, dynamic>> scanAbsen(
    String kode,
    String waktu,
  ) async {
    return _post('guru/absen/scan', {'kode': kode, 'waktu': waktu});
  }

  /// GET /api/guru/absen/rekap — Mengambil Rekap Absensi
  static Future<Map<String, dynamic>> getRekapAbsen({
    int? idKelompok,
    int? idKelas,
    String? tglMulai,
    String? tglAkhir,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (idKelompok != null && idKelompok > 0)
      queryParams['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) queryParams['id_kelas'] = idKelas;
    if (tglMulai != null && tglMulai.isNotEmpty)
      queryParams['tgl_mulai'] = tglMulai;
    if (tglAkhir != null && tglAkhir.isNotEmpty)
      queryParams['tgl_akhir'] = tglAkhir;

    return _get(
      'guru/absen/rekap',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  // ─── Fungsi Baru Untuk Tab Absen Massal ────────────────────────────────────

  static Future<Map<String, dynamic>> getAbsenHarian({
    String? tanggal,
    int? idKelas,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (tanggal != null) queryParams['tanggal'] = tanggal;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return _get(
      'guru/absen',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  static Future<Map<String, dynamic>> simpanAbsenMassal(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/absen/simpan', payload);
  }

  // ─── Progres Belajar ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getProgressList({String? cari}) async {
    final Map<String, dynamic> q = {};
    if (cari != null && cari.isNotEmpty) q['cari'] = cari;
    return _get('guru/progress', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getProgressDetail(String nis) async {
    return _get('guru/progress/detail/$nis');
  }

  static Future<Map<String, dynamic>> inputCepatProgress(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/progress/input-cepat', payload);
  }

  static Future<Map<String, dynamic>> inputMassalProgress(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/progress/input-massal', payload);
  }

  // ─── Data Santri ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getSantriList({String? cari}) async {
    final Map<String, dynamic> q = {};
    if (cari != null && cari.isNotEmpty) q['cari'] = cari;
    return _get('guru/santri', queryParameters: q.isEmpty ? null : q);
  }

  // PERBAIKAN: Tambahkan kata /show/ agar cocok dengan rute CI4
  static Future<Map<String, dynamic>> getSantriDetail(String nis) async {
    return _get('guru/santri/show/$nis');
  }

  // ── MASALAH SANTRI ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMasalahAktif() async {
    return _get('guru/masalah');
  }

  static Future<Map<String, dynamic>> getMasalahSelesai() async {
    return _get('guru/masalah/selesai');
  }

  static Future<Map<String, dynamic>> getMasalahPendingApproval() async {
    return _get('guru/masalah/pending');
  }

  static Future<Map<String, dynamic>> storeMasalah({
    required String nis,
    required String jenisMasalah,
    required String deskripsi,
    required String tglMasalah,
  }) async {
    return _post('guru/masalah/store', {
      'nis': nis,
      'jenis_masalah': jenisMasalah,
      'deskripsi': deskripsi,
      'tgl_masalah': tglMasalah,
    });
  }

  static Future<Map<String, dynamic>> updateMasalah({
    required String id,
    required String status,
    String? tglSelesai,
    String? catatanSelesai,
  }) async {
    return _post('guru/masalah/update', {
      'id_masalah': id,
      'status': status,
      if (tglSelesai != null) 'tgl_selesai': tglSelesai,
      if (catatanSelesai != null) 'catatan_selesai': catatanSelesai,
    });
  }

  static Future<Map<String, dynamic>> setujuiMasalah({
    required String id,
  }) async {
    return _post('guru/masalah/setujui', {'id_masalah': id});
  }

  static Future<Map<String, dynamic>> tolakMasalah({
    required String id,
    required String catatan,
  }) async {
    return _post('guru/masalah/tolak', {
      'id_masalah': id,
      'catatan_penolakan': catatan,
    });
  }

  // ─── HTTP Helpers (Internal via Dio) ─────────────────────────────────────────

  static Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final client = await DioClient.dio;
      final fullUrl = '${client.options.baseUrl}/api/$endpoint';
      debugPrint("📡 API_GET: $fullUrl");
      if (queryParameters != null) debugPrint("🔍 PARAMS: $queryParameters");

      final response = await client.get(
        '/api/$endpoint',
        queryParameters: queryParameters,
      );
      return _parseResponseData(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow; // _handleDioError generally throws, this satisfies return type
    }
  }

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final client = await DioClient.dio;
      final fullUrl = '${client.options.baseUrl}/api/$endpoint';
      debugPrint("📡 API_POST: $fullUrl");
      debugPrint("📦 BODY: $body");

      final response = await client.post('/api/$endpoint', data: body);
      return _parseResponseData(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  static Map<String, dynamic> _parseResponseData(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final isSuccess = data['status'] == 200 || data['status'] == true;
      if (!isSuccess || data['error'] == true) {
        throw Exception(data['message'] ?? 'Gagal memproses permintaan.');
      }
      return data;
    } else {
      throw Exception('Format respons tidak valid: Bukan JSON Object');
    }
  }

  // pencarian santri (untuk form Catat Masalah)
  static Future<List<Map<String, dynamic>>> cariSantri(String query) async {
    try {
      final result = await _get(
        'guru/santri/cari',
        queryParameters: {'q': query},
      );
      final data = result['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      return []; // Return fallback on search failure instead of throwing
    }
  }

  // =========================================================
  // DELETE: Hapus Data Progres
  // =========================================================
  static Future<Map<String, dynamic>> deleteProgress(int idPrestasi) async {
    // Sesuaikan endpoint ini dengan backend (contoh: guru/progress/delete)
    return _post('guru/progress/delete', {'id_prestasi': idPrestasi});
  }

  // =========================================================
  // UPDATE: Edit Data Progres
  // =========================================================
  static Future<Map<String, dynamic>> updateProgress(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    data['id_prestasi'] = idPrestasi;
    // Sesuaikan endpoint ini dengan backend (contoh: guru/progress/update)
    return _post('guru/progress/update', data);
  }
}
