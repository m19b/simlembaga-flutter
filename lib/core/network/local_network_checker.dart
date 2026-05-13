import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

enum LocalNetworkStatus { online, offline }

class LocalNetworkChecker {
  static final LocalNetworkChecker _instance = LocalNetworkChecker._internal();
  factory LocalNetworkChecker() => _instance;
  LocalNetworkChecker._internal();

  Timer? _timer;
  LocalNetworkStatus _currentStatus = LocalNetworkStatus.offline;
  final _statusController = StreamController<LocalNetworkStatus>.broadcast();

  Stream<LocalNetworkStatus> get onStatusChange => _statusController.stream;
  LocalNetworkStatus get currentStatus => _currentStatus;

  /// Memulai pengecekan berkala (interval default 10 detik)
  void startChecking({int intervalSeconds = 10}) {
    checkConnection(); // Cek langsung saat start
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      checkConnection();
    });
  }

  void stopChecking() {
    _timer?.cancel();
  }

  Future<bool> checkConnection() async {
    try {
      // Menggunakan fungsi ping dari ApiService yang menggunakan timeout 2 detik (getNewInstanceWithShortTimeout)
      await ApiService.checkConnection();
      _updateStatus(LocalNetworkStatus.online);
      return true;
    } catch (e) {
      _updateStatus(LocalNetworkStatus.offline);
      return false;
    }
  }

  void _updateStatus(LocalNetworkStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
      debugPrint("📡 LocalNetworkChecker: Status berubah menjadi ${_currentStatus.name}");
    }
  }
}
