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
          // HANDLER KHUSUS progress_tahsin
          // ---------------------------------------------------------
          if (item.type == 'progress_tahsin') {
            // Fix old wrong endpoints jika tersisa
            if (endpoint.contains('api/guru/tahsin/')) {
              endpoint = endpoint.replaceAll('api/guru/tahsin/', 'api/guru/progress/');
            }
            if (!endpoint.startsWith('api/')) {
              endpoint = 'api/$endpoint';
            }
            endpoint = endpoint.replaceAll('api/api/', 'api/');

            final payloadKeys = payload.keys.toList();
            debugPrint('🔄 SYNC TAHSIN ID ${item.id} → $endpoint | keys=$payloadKeys');

            final response = await dio.post(endpoint, data: payload);
            
            if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
              isSuccess = true;
              if (response.data is Map) {
                final resData = response.data as Map;
                if (resData.containsKey('status')) {
                  final status = resData['status'];
                  if (status != 200 && status != true) {
                    isSuccess = false;
                    debugPrint("❌ TAHSIN API HTTP 200 tapi JSON status = $status");
                  }
                }
              }
            }
          } else {
            // ---------------------------------------------------------
            // HANDLER UMUM/LEGACY
            // ---------------------------------------------------------
            if (endpoint.startsWith('tahfidz-quran/')) {
              endpoint = 'api/guru/$endpoint';
            }
            if (!endpoint.startsWith('api/')) {
              endpoint = 'api/$endpoint';
            }
            endpoint = endpoint.replaceAll('api/api/', 'api/');

            debugPrint('🔄 SYNC ID ${item.id} → $endpoint');
            final response = await dio.post(endpoint, data: payload);
            
            if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
              isSuccess = true;
              if (response.data is Map) {
                final resData = response.data as Map;
                if (resData.containsKey('status')) {
                  final status = resData['status'];
                  if (status != 200 && status != true) {
                    isSuccess = false;
                  }
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
          final responseBody = e.response?.data;
          final statusCode = e.response?.statusCode;
          debugPrint('❌ SYNC GAGAL ID ${item.id} | HTTP $statusCode');
          debugPrint('   ↳ CI4 Response Body: $responseBody');

          // JIKA API me-return HTTP 400 (Error Validasi Backend, contoh: melampaui Checkpoint)
          // Hapus item tersebut dari OfflineQueue karena data cacat secara logika dan tak akan pernah diterima.
          if (statusCode == 400) {
            await _isar.writeTxn(() async {
              await _isar.offlineQueues.delete(item.id);
            });
            debugPrint('🗑️ Antrean ID ${item.id} dihapus permanen karena HTTP 400 (Data Tidak Valid)');
          }
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
