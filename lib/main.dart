import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:manajemen_tahsin_app/app.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/utils/sync_manager.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';

void main() async {
  // 1. Pastikan mesin Flutter sudah menyala sebelum menjalankan perintah lain
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi locale Indonesia agar DateFormat(..., 'id_ID') tidak error
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Isar Database untuk Offline-First Architecture
  await IsarDb.init();

  // Mulai network checker berkala
  LocalNetworkChecker().startChecking();

  // Mulai Sync Manager di background
  OfflineSyncManager().startSyncMonitor();

  // 3. Pasang "CCTV" untuk menangkap layar putih (Render Crash) di APK
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.red[900], // Background merah agar terlihat jelas
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Text(
              'Terjadi Kesalahan UI:\n\n\${details.exceptionAsString()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  };

  // 4. Jalankan aplikasi utama
  runApp(const MyApp());
}
