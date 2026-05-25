import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';

class OfflineBannerSliver extends StatelessWidget {
  const OfflineBannerSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<LocalNetworkStatus>(
        initialData: LocalNetworkChecker().currentStatus,
        stream: LocalNetworkChecker().onStatusChange,
        builder: (context, snapshot) {
          if (snapshot.data == LocalNetworkStatus.offline) {
            return Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.orange.shade900,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda sedang offline. Menampilkan data lokal.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
