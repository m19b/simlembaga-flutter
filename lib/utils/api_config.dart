import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _ipKey = 'SERVER_IP';
  static const String defaultIp = '192.168.1.100';

  /// Mengambil base URL lengkap berdasarkan IP yang tersimpan.
  /// Contoh IP '10.53.70.140' menjadi 'http://10.53.70.140:8080'
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_ipKey) ?? defaultIp;
    return 'http://$ip:8080';
  }

  /// Mengambil hanya IP yang tersimpan untuk ditampilkan di form (contoh: '10.53.70.140')
  static Future<String> getRawIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? defaultIp;
  }

  /// Menyimpan IP ke memori
  static Future<void> setIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    // Bersihkan jika user tidak sengaja memasukkan http:// atau :8080
    String cleanIp = ip.trim();
    cleanIp = cleanIp.replaceAll('http://', '').replaceAll('https://', '');
    if (cleanIp.contains(':')) {
      cleanIp = cleanIp.split(':').first;
    }
    await prefs.setString(_ipKey, cleanIp);
  }
}
