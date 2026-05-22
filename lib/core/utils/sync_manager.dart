import 'dart:async';
import 'dart:convert';
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
          
          // Fix old wrong endpoints from TahsinRepository (tahsin -> progress)
          if (endpoint.contains('api/guru/tahsin/')) {
            endpoint = endpoint.replaceAll('api/guru/tahsin/', 'api/guru/progress/');
          }
          // Fix old wrong endpoints from TahfidzRepository (missing api/guru/)
          if (endpoint.startsWith('tahfidz-quran/')) {
            endpoint = 'api/guru/$endpoint';
          }
          // Ensure it starts with api/ 
          if (!endpoint.startsWith('api/')) {
            endpoint = 'api/$endpoint';
          }
          endpoint = endpoint.replaceAll('api/api/', 'api/');

          final response = await dio.post(endpoint, data: payload);
          
          bool isSuccess = false;
          // Cek HTTP Status Code
          if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
            isSuccess = true;
            // Cek detail payload balikan dari server (CI4 sering kembalikan HTTP 200 tapi isinya error 400)
            if (response.data is Map) {
              final resData = response.data as Map;
              if (resData.containsKey('status')) {
                final status = resData['status'];
                if (status != 200 && status != true) {
                  isSuccess = false;
                  debugPrint("❌ API mengembalikan HTTP 200 tapi JSON status = $status");
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
        } catch (e) {
          // Gagal sync (4xx/5xx atau error lain), biarkan di antrean untuk di-retry
          debugPrint('Gagal sinkronisasi antrean ID ${item.id}: $e');
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
