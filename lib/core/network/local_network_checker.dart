import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

enum LocalNetworkStatus { online, offline }

class LocalNetworkChecker {
  static final LocalNetworkChecker _instance = LocalNetworkChecker._internal();
  factory LocalNetworkChecker() => _instance;
  LocalNetworkChecker._internal();

  LocalNetworkStatus _currentStatus = LocalNetworkStatus.offline;
  final _statusController = StreamController<LocalNetworkStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _timer;

  Stream<LocalNetworkStatus> get onStatusChange => _statusController.stream;
  LocalNetworkStatus get currentStatus => _currentStatus;

  /// Memulai pengecekan menggunakan Connectivity & Ping
  void startChecking({int intervalSeconds = 15}) {
    checkConnection(); // Cek langsung saat start
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      checkConnection();
    });
    
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Saat koneksi perangkat berubah, cek ulang jangkauan server
      checkConnection();
    });
  }

  void stopChecking() {
    _timer?.cancel();
    _connectivitySubscription?.cancel();
  }

  bool _isPinging = false;

  Future<bool> checkConnection() async {
    if (_isPinging) return _currentStatus == LocalNetworkStatus.online;
    _isPinging = true;

    try {
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi) || 
          results.contains(ConnectivityResult.ethernet)) {
        
        // Walaupun WiFi / Mobile terhubung, pastikan server CI4 BENAR-BENAR bisa dijangkau
        try {
          await ApiService.checkConnection();
          _updateStatus(LocalNetworkStatus.online);
          _isPinging = false;
          return true;
        } catch (e) {
          // Server mati atau salah jaringan
          _updateStatus(LocalNetworkStatus.offline);
          _isPinging = false;
          return false;
        }

      } else {
        _updateStatus(LocalNetworkStatus.offline);
        _isPinging = false;
        return false;
      }
    } catch (e) {
      _updateStatus(LocalNetworkStatus.offline);
      _isPinging = false;
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
