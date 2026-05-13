import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';

class ConnectionStatusBadge extends StatefulWidget {
  const ConnectionStatusBadge({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge> {
  bool _isOnline = true;
  late Stream<void> _queueStream;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    LocalNetworkChecker().onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          _isOnline = status == LocalNetworkStatus.online;
        });
      }
    });

    _queueStream = IsarDb.instance.offlineQueues.watchLazy(fireImmediately: true);
  }

  Future<void> _checkInitialConnection() async {
    final hasConn = LocalNetworkChecker().currentStatus == LocalNetworkStatus.online;
    if (mounted) {
      setState(() {
        _isOnline = hasConn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: _queueStream,
      builder: (context, snapshot) {
        // Query current count synchronously when stream fires
        final pendingCount = IsarDb.instance.offlineQueues.countSync();

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indikator Antrean & Sinkronisasi
                if (pendingCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.blue.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isOnline ? Colors.blue.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isOnline) ...[
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Menyinkronkan...',
                            style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ] else ...[
                          const Icon(Icons.hourglass_empty, size: 12, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '$pendingCount tertunda',
                            style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Indikator Koneksi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                        if (!_isOnline) ...[
                        const SizedBox(width: 4),
                        const Text(
                          'Offline',
                          style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
      },
    );
  }
}
