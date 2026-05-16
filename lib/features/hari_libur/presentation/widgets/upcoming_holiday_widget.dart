import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';

/// Widget ringkasan libur terdekat untuk Dashboard.
/// Menampilkan maks 2 hari libur terdekat (>= hari ini).
/// Jika tidak ada, menampilkan SizedBox.shrink().
class UpcomingHolidayWidget extends StatelessWidget {
  final List<HariLiburModel> allHolidays;

  const UpcomingHolidayWidget({super.key, required this.allHolidays});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final upcoming = allHolidays
        .where((h) {
          final dt = h.tanggalDt;
          return dt != null && !dt.isBefore(todayStart);
        })
        .toList()
      ..sort((a, b) => a.tanggalMulai.compareTo(b.tanggalMulai));

    final display = upcoming.take(2).toList();

    if (display.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Icon(Icons.event_available_rounded,
                      color: Colors.red.shade400, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Libur Terdekat',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...display.map((item) {
              final dt = item.tanggalDt;
              final isToday = dt != null &&
                  dt.year == now.year &&
                  dt.month == now.month &&
                  dt.day == now.day;
              final diff = dt != null
                  ? dt.difference(todayStart).inDays
                  : 0;
              final diffText = isToday
                  ? 'Hari ini'
                  : (diff == 1 ? 'Besok' : '$diff hari lagi');

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.amber.withValues(alpha: 0.15)
                            : Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dt != null ? '${dt.day}' : '-',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.amber.shade700
                                    : Colors.red.shade400),
                          ),
                          Text(
                            dt != null
                                ? DateFormat('MMM', 'id_ID')
                                    .format(dt)
                                    .toUpperCase()
                                : '',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? Colors.amber.shade700
                                    : Colors.red.shade400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaLibur,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            diffText,
                            style: TextStyle(
                                fontSize: 11,
                                color: isToday
                                    ? Colors.amber.shade700
                                    : cs.onSurfaceVariant,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
