import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/api/dio_client.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/app.dart';
import 'package:rxdart/rxdart.dart';

class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  StreamSubscription<LocalNetworkStatus>? _subscription;
  bool _isSyncing = false;
  
  Isar get _isar => IsarDb.instance;

  void startSyncMonitor() {
    _subscription = LocalNetworkChecker().onStatusChange
        .debounceTime(const Duration(seconds: 3))
        .listen((status) {
      if (status == LocalNetworkStatus.online) {
        _syncQueue();
      }
    });
  }

  void stopSyncMonitor() {
    _subscription?.cancel();
  }

  Future<void> syncQueueManual() async {
    await _syncQueue();
  }

  Future<void> _syncQueue() async {
    // Mutex Lock
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Tarik antrean dari Isar urut ID terkecil (FIFO)
      final queueItems = await _isar.offlineQueues.where().sortByTimestamp().findAll();
      if (queueItems.isEmpty) {
        return;
      }

      int successCount = 0;

      for (var item in queueItems) {
        try {
          final dio = await DioClient.dio;
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
          String endpoint = item.endpoint;
          bool isSuccess = false;

          // ---------------------------------------------------------
          // ROUTING ENDPOINT BERDASARKAN TIPE
          // ---------------------------------------------------------
          switch (item.type) {
            case 'absensi_harian':
            case 'absensi_massal':
            case 'progress_tahsin':
            case 'progress_pra_tahfidz':
            case 'progress_tahfidz':
            case 'daftar_tes':
            case 'catatan_masalah':
              if (!endpoint.startsWith('api/')) endpoint = 'api/$endpoint';
              endpoint = endpoint.replaceAll('api/api/', 'api/');
              if (item.type == 'progress_tahsin') {
                endpoint = endpoint.replaceAll('api/guru/tahsin/', 'api/guru/progress/');
              }
              break;
            default:
              if (endpoint.startsWith('tahfidz-quran/')) endpoint = 'api/guru/$endpoint';
              if (!endpoint.startsWith('api/')) endpoint = 'api/$endpoint';
              endpoint = endpoint.replaceAll('api/api/', 'api/');
              break;
          }

          debugPrint('🔄 SYNC [${item.type}] ID ${item.id} → $endpoint');
          final response = await dio.post(endpoint, data: payload);
          
          // A. HTTP 200/201 (Sukses) -> Hapus dari Isar
          if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
            isSuccess = true;
            if (response.data is Map) {
              final resData = response.data as Map;
              if (resData.containsKey('status')) {
                final status = resData['status'];
                if (status != 200 && status != true) {
                  isSuccess = false;
                  debugPrint("❌ API HTTP 200 tapi JSON status = $status");
                }
              }
            }
          }

          if (isSuccess) {
            await _isar.writeTxn(() async {
              await _isar.offlineQueues.delete(item.id);
            });
            successCount++;
          }
        } on DioException catch (e) {
          final statusCode = e.response?.statusCode;
          debugPrint('❌ SYNC GAGAL ID ${item.id} | HTTP $statusCode');
          
          // B. HTTP 400/422 (Error Validasi CI4) -> Hapus dari Isar (Data drop)
          if (statusCode == 400 || statusCode == 422) {
            await _isar.writeTxn(() async {
              await _isar.offlineQueues.delete(item.id);
            });
            debugPrint('🗑️ Antrean ID ${item.id} dihapus permanen karena HTTP $statusCode (Data Tidak Valid/Error Validasi)');
          }
          // C. Timeout/SocketException (Luring) -> Skip (Biarkan di Isar)
        } catch (e) {
          debugPrint('❌ SYNC ERROR ID ${item.id} (non-Dio): $e');
        }
      }

      if (successCount > 0) {
        // Notifikasi ke UI via navigatorKey jika ada yang sukses sinkron
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$successCount Data tertunda berhasil disinkronkan ke server.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      // Unlock Mutex
      _isSyncing = false;
    }
  }
}
