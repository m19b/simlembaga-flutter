import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

class PraTahfidzRekapCard extends StatelessWidget {
  final Map<String, dynamic> rekap;
  final List<dynamic> riwayat;

  const PraTahfidzRekapCard({
    super.key,
    required this.rekap,
    required this.riwayat,
  });

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final colorScheme = Theme.of(context).colorScheme;

    // Menghitung kumulatif halaman: pakai rekap jika ada, jika tidak jumlahkan manual dari riwayat
    double totalHal = 0;
    if (rekap.isNotEmpty && rekap['kumulatif_halaman'] != null) {
      totalHal = double.tryParse(rekap['kumulatif_halaman']?.toString() ?? '0') ?? 0;
    } else {
      for (final r in riwayat) {
        totalHal += double.tryParse(r['total_hal']?.toString() ?? '0') ?? 0;
      }
    }
    final totalSetoran = riwayat.length;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Statistik Progres',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  'Total Setoran',
                  '$totalSetoran✕',
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  'Total Halaman',
                  '${totalHal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} Hal',
                  styles.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
