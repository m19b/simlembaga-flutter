import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';

class GlobalNetworkIndicator extends StatefulWidget {
  final Widget child;
  const GlobalNetworkIndicator({super.key, required this.child});

  @override
  State<GlobalNetworkIndicator> createState() => _GlobalNetworkIndicatorState();
}

class _GlobalNetworkIndicatorState extends State<GlobalNetworkIndicator> {
  bool _isOnline = true;
  bool _isChecking = false;
  late final NetworkInfo _networkInfo;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(LocalNetworkChecker());
    _checkConnection();

    // Polling setiap 10 detik dengan pengecekan agar tidak bertumpuk jika server unreachable
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final online = await _networkInfo.isConnected;
      if (mounted && _isOnline != online) {
        setState(() {
          _isOnline = online;
        });
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          // Posisi di area status bar (sejajar jam & notifikasi sistem Android)
          // Vertikal: center di dalam tinggi status bar
          top: ((MediaQuery.of(context).padding.top - 0) / 2).clamp(0.0, 20.0),
          left: 12,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isOnline ? Colors.green : Colors.red).withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
