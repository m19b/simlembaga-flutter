import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

class PraTahfidzRiwayatItem extends StatelessWidget {
  final Map<String, dynamic> riwayat;
  final VoidCallback onHapus;

  const PraTahfidzRiwayatItem({
    super.key,
    required this.riwayat,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;

    final tglStr = riwayat['tanggal']?.toString() ?? '';
    final tgl = DateTime.tryParse(tglStr) ?? DateTime.now();

    final halAwal = double.tryParse(riwayat['hal_awal']?.toString() ?? '0') ?? 0;
    final halAkhir = double.tryParse(riwayat['hal_akhir']?.toString() ?? '0') ?? 0;
    final totalHal = double.tryParse(riwayat['total_hal']?.toString() ?? '0') ?? 0;
    final status = riwayat['status_bacaan']?.toString() ?? '';

    Color statusColor;
    if (status == 'Lebih') {
      statusColor = styles.success;
    } else if (status == 'Kurang') {
      statusColor = styles.warning;
    } else {
      statusColor = colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Box
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(tgl),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(tgl),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sesi ${riwayat['sesi'] ?? '-'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Hal. ${halAwal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} → ${halAkhir.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${totalHal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} hal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: styles.error),
            onPressed: onHapus,
          ),
        ],
      ),
    );
  }
}
