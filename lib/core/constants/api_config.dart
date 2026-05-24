import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multicast_dns/multicast_dns.dart';

class ApiConfig {
  static const String _ipKey = 'SERVER_IP';

  // ─── TUGAS 2: KONFIGURASI URL SENTRAL ─────────────────────────────
  // HANYA UBAH IP DI SINI jika berpindah dari server Linux (Caddy) ke Windows Portable (XAMPP/PHP Spark).
  // Catatan: Anda tidak perlu menaruh "/api/" di belakang karena api_service.dart otomatis menambahkannya.
  // Contoh Caddy (Linux): 'http://192.168.100.19'
  // Contoh Spark (Windows): 'http://192.168.x.x:8080'
  static const String baseUrlSentral = 'http://192.168.1.37';
  // ──────────────────────────────────────────────────────────────────

  static const String defaultIp = '192.168.1.37';

  /// Mengambil base URL lengkap
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_ipKey);

    String url;
    // Jika user pernah save IP dari layar setting (dinamis), gunakan itu
    if (ip != null && ip.isNotEmpty) {
      url = 'http://$ip';
    } else {
      // Default ke baseUrl Sentral (Standar baru)
      url = baseUrlSentral;
    }

    // Pastikan selalu diakhiri slash agar Dio.get('path') tidak merusak subfolder
    if (!url.endsWith('/')) {
      url = '$url/';
    }
    return url;
  }

  /// Mengambil hanya IP yang tersimpan untuk ditampilkan di form pengaturan Server di halaman Login
  static Future<String> getRawIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ??
        baseUrlSentral.replaceAll("http://", "").replaceAll("https://", "");
  }

  /// Menyimpan input dari user di form pengaturan Server (LoginScreen)
  /// Mengembalikan String host yang berhasil di-resolve dan disimpan.
  static Future<String> setIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Bersihkan spasi kosong dan buang awalan http/https agar seragam
    String cleanHost = ip.trim().replaceAll(RegExp(r'^https?://'), '');

    // 2. Buang tanda garis miring '/' di akhir string jika ada
    if (cleanHost.endsWith('/')) {
      cleanHost = cleanHost.substring(0, cleanHost.length - 1);
    }

    // Buang suffix '/api' jika user tidak sengaja mengetiknya (agar tidak double nantinya)
    if (cleanHost.toLowerCase().endsWith('/api')) {
      cleanHost = cleanHost.substring(0, cleanHost.length - 4);
    }

    // Pisahkan hostname/IP, port asal, dan path
    int pathIndex = cleanHost.indexOf('/');
    String targetHostname = cleanHost;
    int? explicitPort;
    String remainingPath = '';

    if (pathIndex != -1) {
      remainingPath = cleanHost.substring(pathIndex);
      targetHostname = cleanHost.substring(0, pathIndex);
    }

    if (targetHostname.contains(':')) {
      List<String> parts = targetHostname.split(':');
      targetHostname = parts[0];
      explicitPort = int.tryParse(parts[1]);
    }

    String? resolvedIp;

    // 3. IDENTIFIKASI & RESOLVE HOSTNAME
    // Cek apakah input berupa IP Address Murni (IPv4)
    final bool isIp = RegExp(
      r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$',
    ).hasMatch(targetHostname);

    if (isIp) {
      resolvedIp = targetHostname;
    } else {
      debugPrint("🚀 Memulai proses resolusi hostname: $targetHostname");

      // -- STRATEGI 1: OS Resolver Standar (DNS/Hosts) --
      try {
        // Gunakan type IPv4 agar lebih cepat dan spesifik
        final ips = await InternetAddress.lookup(
          targetHostname,
          type: InternetAddressType.IPv4,
        ).timeout(const Duration(seconds: 4));
        if (ips.isNotEmpty) {
          resolvedIp = ips.first.address;
          debugPrint("✅ OS Resolver (S1): $targetHostname -> $resolvedIp");
        }
      } catch (e) {
        debugPrint("ℹ️ OS Resolver (S1) failed: $e");
      }

      // -- STRATEGI 2: OS Resolver dengan tambahan suffix .local (Banyak Windows handle ini otomatis) --
      if (resolvedIp == null && !targetHostname.contains('.')) {
        try {
          final ips = await InternetAddress.lookup(
            '$targetHostname.local',
            type: InternetAddressType.IPv4,
          );
          if (ips.isNotEmpty) {
            resolvedIp = ips.first.address;
            debugPrint(
              "✅ OS Resolver (.local): Found $targetHostname.local -> $resolvedIp",
            );
          }
        } catch (_) {}
      }

      // -- STRATEGI 3: OS Resolver dengan menghapus suffix .local (Jika ngetik .local tapi OS cuma kenal NetBIOS) --
      if (resolvedIp == null &&
          targetHostname.toLowerCase().endsWith('.local')) {
        try {
          final cleanName = targetHostname.substring(
            0,
            targetHostname.length - 6,
          );
          final ips = await InternetAddress.lookup(
            cleanName,
            type: InternetAddressType.IPv4,
          );
          if (ips.isNotEmpty) {
            resolvedIp = ips.first.address;
            debugPrint(
              "✅ OS Resolver (Stripped .local): Found $cleanName -> $resolvedIp",
            );
          }
        } catch (_) {}
      }

      // -- STRATEGI 4: mDNS Fallback Manual (Sangat penting buat Android nyari Laptop Windows/Linux) --
      if (resolvedIp == null) {
        String mdnsHost = targetHostname;
        if (!mdnsHost.toLowerCase().endsWith('.local')) {
          mdnsHost = '$mdnsHost.local';
        }

        debugPrint("rrrrrrrrrrrrrrrrrrrrrrr Mencoba mDNS manual untuk: $mdnsHost ...");

        // mDNS client dengan binding yang aman
        final MDnsClient client = MDnsClient(
          rawDatagramSocketFactory:
              (
                dynamic host,
                int port, {
                bool? reuseAddress,
                bool? reusePort,
                int? ttl,
              }) {
                // Android (Linux) seringkali gagal jika reusePort true. Kita paksa false di Android.
                bool safeReusePort = reusePort ?? false;
                if (Platform.isAndroid) safeReusePort = false;

                return RawDatagramSocket.bind(
                  host,
                  port,
                  reuseAddress: reuseAddress ?? true,
                  reusePort: safeReusePort,
                  ttl: ttl ?? 255,
                );
              },
        );

        try {
          await client.start();

          // Cari record IPv4 untuk host tersebut
          final results = client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(mdnsHost),
            timeout: const Duration(seconds: 4),
          );

          await for (final IPAddressResourceRecord record in results) {
            resolvedIp = record.address.address;
            debugPrint("✅ mDNS Manual: $mdnsHost -> $resolvedIp");
            break;
          }
        } catch (e) {
          debugPrint("⚠️ mDNS Manual Error: $e");
        } finally {
          client.stop();
        }
      }
    }

    if (resolvedIp == null) {
      throw Exception(
        "Gagal mencari IP dari laptop '$targetHostname'. Pastikan nama benar dan satu WiFi dengan server.",
      );
    }

    // 4. Deteksi otomatis Port (80 untuk Linux/Caddy, 8080 untuk Windows/Spark)
    Future<bool> checkPort(String ipToCheck, int portToCheck) async {
      try {
        final socket = await Socket.connect(
          ipToCheck,
          portToCheck,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }

    int? validPort = explicitPort;
    if (validPort != null) {
      // Kalo user secara eksplisit ketik port (misal biza:8080), kita hormati itu
      if (!await checkPort(resolvedIp, validPort)) {
        throw Exception(
          "Host $resolvedIp terhubung, tapi port $validPort ditolak/mati. Pastikan Firewall mengizinkan port $validPort.",
        );
      }
    }

    if (validPort == null) {
      if (await checkPort(resolvedIp, 8080)) {
        validPort = 8080; // Biza Server Windows jalan di port 8080
      } else if (await checkPort(resolvedIp, 80)) {
        validPort = null; // Caddy Linux jalan di port 80
      } else {
        throw Exception(
          "Host $resolvedIp terhubung, tapi server menolak (port 8080/80 mati). Pastikan Biza Server aktif dan Firewall mengizinkan.",
        );
      }
    }

    String finalHost = validPort == null
        ? resolvedIp
        : "$resolvedIp:$validPort";
    finalHost += remainingPath;

    debugPrint("Disimpan sebagai: $finalHost");
    await prefs.setString(_ipKey, finalHost);
    return finalHost;
  }
}
