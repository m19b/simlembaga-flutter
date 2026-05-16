import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

class PraTahfidzSantriCard extends StatelessWidget {
  final Map<String, dynamic> santri;
  final VoidCallback onTap;

  const PraTahfidzSantriCard({
    super.key,
    required this.santri,
    required this.onTap,
  });

  /// Format halaman: hilangkan desimal jika bernilai .0
  String _fmtHal(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Bangun teks posisi bacaan dari data quran page
  String _buildPosisiText() {
    final juz = santri['juz'];
    final surah = santri['surah_mulai']?.toString();
    final ayat = santri['ayat_mulai'];
    final pointer = double.tryParse(santri['pointer_halaman']?.toString() ?? '0') ?? 0;

    if (juz == null || surah == null || surah.isEmpty) {
      return 'Hal. ${_fmtHal(pointer)}';
    }
    final ayatStr = ayat != null ? ':$ayat' : '';
    return 'Juz $juz · $surah$ayatStr · Hal. ${_fmtHal(pointer)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nama = santri['nama_santri']?.toString() ?? '-';
    final nis = santri['nis']?.toString() ?? '-';
    final tingkat = santri['tingkat']?.toString() ?? '-';

    final bool sudahSetor = santri['sudah_setor'] == true ||
        santri['sudah_setor']?.toString() == '1' ||
        santri['sudah_setor']?.toString() == 'true';
    final int totalSetoran =
        int.tryParse(santri['total_setoran']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sudahSetor
              ? styles.success.withValues(alpha: 0.5)
              : styles.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama
                      Text(
                        nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      // NIS + Tingkat badge
                      Row(
                        children: [
                          Text(nis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.indigo.withValues(alpha: 0.2)
                                  : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tingkat,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: isDark
                                      ? Colors.indigo.shade300
                                      : Colors.indigo,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Posisi Bacaan (Juz · Surah:Ayat · Hal)
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 12, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _buildPosisiText(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge Setor
                if (sudahSetor)
                  _Badge(
                    label: '$totalSetoran✕ Setor',
                    icon: Icons.check_circle_rounded,
                    color: styles.success,
                  )
                else
                  _Badge(
                    label: 'Belum',
                    icon: Icons.pending_actions_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    bgColor: colorScheme.onSurface.withValues(alpha: 0.08),
                    textColor: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final Color? textColor;

  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? color)),
        ],
      ),
    );
  }
}
