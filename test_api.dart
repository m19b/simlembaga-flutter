import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script kecil untuk mengetes secara langsung respons dari server CI4 Anda.
/// Simpan di d:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\test_api.dart
/// Jalankan via Terminal dengan: dart test_api.dart "username_guru" "password_guru"

void main(List<String> args) async {
  if (args.length < 2) {
    print('❌ MAAF: Anda harus memasukkan username dan password guru saat menjalankan script ini.');
    print('🟢 Cara Pakai: dart test_api.dart "username_anda" "password_anda"');
    print('   (Ganti dengan username & password guru yang asli)\n');
    return;
  }

  final identity = args[0];
  final password = args[1];
  
  // HARAP SESUAIKAN DENGAN IP ANDA
  final baseUrl = 'http://localhost:8080';

  print('⏳ Sedang mencoba Login ke $baseUrl...');
  final loginRes = await http.post(
    Uri.parse('$baseUrl/api/login'),
    headers: {'Accept': 'application/json'},
    body: {'identity': identity, 'password': password},
  );

  final cookie = loginRes.headers['set-cookie']?.split(';').first;

  if (cookie == null) {
    print('❌ Login Gagal!');
    print('Response Code: ${loginRes.statusCode}');
    print('Pesan Asli: ${loginRes.body}');
    return;
  }

  print('✅ Login Berhasil! Mendapatkan Cookie: $cookie\n');
  print('⏳ Sedang menarik data Daftar Santri (GET /api/guru/absen)...');

  final res = await http.get(
    Uri.parse('$baseUrl/api/guru/absen'),
    headers: {
      'Accept': 'application/json',
      'Cookie': cookie,
    },
  );

  print('====================================================');
  print('STATUS CODE : ${res.statusCode}');
  print('RAW JSON RESPONSE :');
  try {
    // Memformat JSON agar rapi
    final map = json.decode(res.body);
    const encoder = JsonEncoder.withIndent('  ');
    print(encoder.convert(map));
  } catch(e) {
    // Jika BUKAN JSON, tampilkan mentahnya
    print(res.body);
  }
  print('====================================================');
  
  if (res.statusCode == 200) {
    print('\n✅ Pengecekan Selesai! Jika array "santri" [ ] kosong, berart server memang melempar data kosong.');
  } else {
    print('\n❌ Pengecekan Selesai. Terdapat error dari server CI4.');
  }
}
