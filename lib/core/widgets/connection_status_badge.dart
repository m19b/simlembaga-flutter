import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionStatusBadge extends StatefulWidget {
  const ConnectionStatusBadge({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          _isOnline = status == InternetConnectionStatus.connected;
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final hasConn = await InternetConnectionChecker.instance.hasConnection;
    if (mounted) {
      setState(() {
        _isOnline = hasConn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('queueBox').listenable(),
      builder: (context, box, _) {
        final pendingCount = box.length;

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
                            '\$pendingCount tertunda',
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
