import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:manajemen_tahsin_app/core/api/dio_client.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/app.dart';
import 'package:flutter/material.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  late final NetworkInfo _networkInfo;
  late final LocalDataSource _localDataSource;
  StreamSubscription<InternetConnectionStatus>? _subscription;
  bool _isSyncing = false;

  void init({
    NetworkInfo? networkInfo,
    LocalDataSource? localDataSource,
  }) {
    _networkInfo = networkInfo ?? NetworkInfoImpl(InternetConnectionChecker.instance);
    _localDataSource = localDataSource ?? LocalDataSourceImpl();
  }

  void startSyncMonitor() {
    init();
    _subscription = _networkInfo.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        _syncQueue();
      }
    });
  }

  void stopSyncMonitor() {
    _subscription?.cancel();
  }

  Future<void> _syncQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = await _localDataSource.getQueue();
      if (queue.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (var item in queue) {
        final endpoint = item['endpoint'] as String;
        final payload = item['payload'] as Map<String, dynamic>;
        final index = item['index'] as int;

        try {
          final dio = await DioClient.dio;
          final response = await dio.post(endpoint, data: payload);
          if (response.statusCode == 200) {
            // Berhasil disinkronisasi, hapus dari antrean
            await _localDataSource.removeFromQueue(index);
          }
        } catch (e) {
          // Gagal sync satu item (mungkin error server), lewati dulu.
          // Bisa dikembangkan untuk menyimpan retry count.
        }
      }

      // Cek apakah semua antrean sudah berhasil disinkronkan
      final finalQueue = await _localDataSource.getQueue();
      if (finalQueue.isEmpty) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Data tertunda berhasil disinkronkan ke server.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      _isSyncing = false;
    }
  }
}
