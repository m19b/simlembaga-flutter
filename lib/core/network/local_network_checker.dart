import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:manajemen_tahsin_app/core/api/services/auth_api_service.dart';

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

  Future<bool>? _activePing;

  Future<bool> checkConnection() async {
    if (_activePing != null) return await _activePing!;

    _activePing = _doPing();
    final result = await _activePing!;
    _activePing = null;
    return result;
  }

  Future<bool> _doPing() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!results.contains(ConnectivityResult.none) || results.isNotEmpty) {
        
        try {
          await AuthApiService.checkConnection();
          _updateStatus(LocalNetworkStatus.online);
          return true;
        } catch (e) {
          _updateStatus(LocalNetworkStatus.offline);
          return false;
        }

      } else {
        _updateStatus(LocalNetworkStatus.offline);
        return false;
      }
    } catch (e) {
      _updateStatus(LocalNetworkStatus.offline);
      return false;
    }
  }

  /// Bypass timer dan paksa ping sekarang (Manual Override)
  Future<void> checkNetworkNow() async {
    // Jalankan tanpa peduli _isPinging, abaikan timer, langsung ping
    try {
      final results = await Connectivity().checkConnectivity();
      if (!results.contains(ConnectivityResult.none) || results.isNotEmpty) {
        try {
          await AuthApiService.checkConnection(timeoutSeconds: 2);
          _updateStatus(LocalNetworkStatus.online);
        } catch (e) {
          _updateStatus(LocalNetworkStatus.offline);
        }
      } else {
        _updateStatus(LocalNetworkStatus.offline);
      }
    } catch (e) {
      _updateStatus(LocalNetworkStatus.offline);
    }
  }

  void _updateStatus(LocalNetworkStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
      debugPrint("rrrrrrrrrrrrrrrrrrrrrrr LocalNetworkChecker: Status berubah menjadi ${_currentStatus.name}");
    }
  }
}
