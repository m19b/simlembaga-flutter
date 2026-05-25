import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

class PraTahfidzPribadiCard extends StatelessWidget {
  final Map<String, dynamic> santri;
  final Map<String, dynamic> rekap;
  final List<dynamic> riwayat;

  const PraTahfidzPribadiCard({
    super.key,
    required this.santri,
    required this.rekap,
    required this.riwayat,
  });

  Widget _infoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;

    // Jika rekap kosong, hitung pointer dari riwayat terakhir
    String pointerText = '0';
    if (rekap.isNotEmpty && rekap['pointer_halaman'] != null) {
      pointerText = rekap['pointer_halaman'].toString();
    } else if (riwayat.isNotEmpty) {
      pointerText = riwayat.first['hal_akhir']?.toString() ?? '0';
    }

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
              Icon(Icons.person_outline_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Data Pribadi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(context, 'Nama', santri['nama_santri']?.toString() ?? '-'),
          _infoRow(context, 'NIS', santri['nis']?.toString() ?? '-'),
          _infoRow(context, 'Tingkat', santri['tingkat']?.toString() ?? '-'),
          _infoRow(context, 'Kelas', santri['nama_kelas']?.toString() ?? '-'),
          _infoRow(context, 'Pointer Saat Ini', 'Hal. ${double.tryParse(pointerText)?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}'),
        ],
      ),
    );
  }
}
