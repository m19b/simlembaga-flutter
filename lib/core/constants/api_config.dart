import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _ipKey = 'SERVER_IP';
  static const String defaultIp = '192.168.1.100';

  // ─── Rumus URL Builder ──────────────────────────────────────────
  // Sistem 1 (Prefix)
  static const String _prefix = 'http://';

  // Sistem 2 (Suffix / Path Server)
  // Pastikan ini benar-benar sesuai dengan folder CI4 di laptopmu
  static const String _suffix = ':8080';
  // static const String _suffix = ':8080/api/';
  // ────────────────────────────────────────────────────────────────

  /// Mengambil base URL lengkap (Sistem1 + UserIP + Sistem2)
  /// Hasil: http://192.168.1.100:8080/silembaga/public
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_ipKey) ?? defaultIp;

    return '$_prefix$ip$_suffix';
  }

  /// Mengambil hanya IP yang tersimpan untuk ditampilkan di form (contoh: '192.168.1.100')
  static Future<String> getRawIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? defaultIp;
  }

  /// Menyimpan IP ke memori dengan pembersihan otomatis
  static Future<void> setIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Hapus spasi kosong dan awalan http/https jika user salah ketik
    String cleanIp = ip
        .trim()
        .replaceAll('http://', '')
        .replaceAll('https://', '');

    // 2. Jika user tidak sengaja mengetik port (misal: 192.168.1.100:8080), ambil IP-nya saja
    if (cleanIp.contains(':')) {
      cleanIp = cleanIp.split(':').first;
    }

    // 3. Jika user tidak sengaja mengetik garis miring (misal: 192.168.1.100/silembaga), ambil IP-nya saja
    if (cleanIp.contains('/')) {
      cleanIp = cleanIp.split('/').first;
    }

    // Simpan IP bersih ke memori
    await prefs.setString(_ipKey, cleanIp);
  }
}
