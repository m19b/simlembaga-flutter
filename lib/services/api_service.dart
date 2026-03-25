import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';

/// Centralized API service. Menggunakan session cookie (standar CI4 Shield).
class ApiService {
  // In-memory session cookie (bertahan selama app berjalan)
  static String? _sessionCookie;
  static const String _userKey = 'LOGGED_IN_USER';

  // ─── Auth ──────────────────────────────────────────────────────────────────

  /// Login — menyimpan session cookie dari Set-Cookie header jika sukses,
  /// serta menyimpan data UserModel ke SharedPreferences.
  static Future<UserModel> login(String identity, String password) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: {'Accept': 'application/json'},
            body: {'identity': identity, 'password': password},
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        // Ambil session cookie (value sebelum tanda ';' pertama)
        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          _sessionCookie = rawCookie.split(';').first;
        }

        final user = UserModel.fromJson(data['data'] as Map<String, dynamic>);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));
        
        return user;
      } else {
        throw Exception(data['message'] ?? 'Login gagal. Periksa kembali data Anda.');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Respons server tidak valid. Pastikan IP Remote Server benar.');
      }
      rethrow;
    }
  }

  /// Logout (bersihkan sesi dan SharedPreferences)
  static Future<void> logout() async {
    _sessionCookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  /// GET /api/guru/dashboard — butuh session cookie aktif
  static Future<Map<String, dynamic>> getDashboardGuru() async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/guru/dashboard'),
          headers: {
            'Accept': 'application/json',
            if (_sessionCookie != null) 'Cookie': _sessionCookie!,
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) {
      throw Exception('Sesi telah habis. Silakan login kembali.');
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['status'] != true) {
      throw Exception(data['message'] ?? 'Gagal memuat data dashboard.');
    }
    return data;
  }

  // ─── Absensi ───────────────────────────────────────────────────────────────

  /// POST /api/absen/scan — requires active session cookie
  static Future<Map<String, dynamic>> scanAbsen(String uniqueCode, String waktu) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/absen/scan'),
          headers: {
            'Accept': 'application/json',
            if (_sessionCookie != null) 'Cookie': _sessionCookie!,
          },
          body: {'unique_code': uniqueCode, 'waktu': waktu},
        )
        .timeout(const Duration(seconds: 15));

    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 401) throw Exception('Sesi telah habis. Silakan login kembali.');
    if (data['status'] != true) throw Exception(data['message'] ?? 'Gagal memproses absen.');
    return data;
  }

  /// GET /api/absen/rekap — requires active session cookie
  static Future<Map<String, dynamic>> getRekapAbsen({
    int? idKelompok,
    int? idKelas,
    String? tglMulai,
    String? tglAkhir,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    
    // Bangun URL dengan query parameters
    final Map<String, String> queryParams = {};
    if (idKelompok != null && idKelompok > 0) queryParams['id_kelompok'] = idKelompok.toString();
    if (idKelas != null && idKelas > 0) queryParams['id_kelas'] = idKelas.toString();
    if (tglMulai != null && tglMulai.isNotEmpty) queryParams['tgl_mulai'] = tglMulai;
    if (tglAkhir != null && tglAkhir.isNotEmpty) queryParams['tgl_akhir'] = tglAkhir;

    final uri = Uri.parse('$baseUrl/api/absen/rekap').replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (_sessionCookie != null) 'Cookie': _sessionCookie!,
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) throw Exception('Sesi telah habis. Silakan login kembali.');
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['status'] != true) throw Exception(data['message'] ?? 'Gagal memuat rekap absensi.');
    return data;
  }
}
