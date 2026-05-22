import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JadwalKelasScreen extends StatelessWidget {
  final List<dynamic> jadwalList;

  const JadwalKelasScreen({
    super.key,
    required this.jadwalList,
  });

  String _getDayName(int day) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    if (day >= 0 && day <= 7) return days[day];
    return 'Hari $day';
  }

  String _mapSesi(String? sesi) {
    switch (sesi) {
      case '1':
        return 'Sesi Pagi';
      case '2':
        return 'Sesi Siang';
      case '3':
        return 'Sesi Sore';
      case '4':
        return 'Sesi Malam';
      default:
        return 'Sesi ${sesi ?? '-'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Jadwal Kelas',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.black : const Color(0xFF0F4C2A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: jadwalList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Jadwal Kelas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                final item = jadwalList[index];
                final hari = int.tryParse(item['hari']?.toString() ?? '0') ?? 0;
                final name = '${_getDayName(hari)}, ${_mapSesi(item['sesi']?.toString())}';
                final toleransi = item['toleransi_terlambat'] ?? '0';
                final start =
                    item['jam_masuk']?.toString().substring(0, 5) ?? '00:00';
                final end =
                    item['jam_pulang']?.toString().substring(0, 5) ?? '00:00';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isDark ? 0 : 2,
                  color: isDark
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDark
                        ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.class_,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toleransi: $toleransi Menit',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.teal.shade600.withValues(alpha: 0.2)
                                : Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.teal.shade700
                                  : Colors.teal.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                size: 18,
                                color: isDark
                                    ? Colors.tealAccent
                                    : Colors.teal.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$start - $end',
                                style: GoogleFonts.dmMono(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.tealAccent
                                      : Colors.teal.shade800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
