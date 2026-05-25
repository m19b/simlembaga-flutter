import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'masalah_constants.dart';
import 'masalah_shared_widgets.dart';

class MasalahCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAktif;
  final VoidCallback onTap;

  const MasalahCard({
    super.key,
    required this.item,
    required this.isAktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nama = item['nama_santri']?.toString() ?? '-';
    final nis = item['nis']?.toString() ?? '';
    final kelas = item['kelas']?.toString() ?? item['tingkat']?.toString() ?? '';
    final jenis = item['jenis_masalah']?.toString();
    final keterangan = item['deskripsi']?.toString() ?? item['keterangan']?.toString() ?? '';
    final tgl = item['tgl_masalah']?.toString() ?? item['tgl_deteksi']?.toString() ?? '';
    final tglSelesai = item['tgl_selesai']?.toString() ?? '';

    final barClr = masalahJenisColor(jenis);

    // Format tanggal
    String fmtTgl(String raw) {
      if (raw.isEmpty) return '';
      try {
        final d = DateTime.parse(raw);
        return DateFormat('d MMM yyyy', 'id_ID').format(d);
      } catch (_) {
        return raw;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: barClr.withAlpha(40), width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Severity bar kiri
                  Container(width: 4, color: barClr),
                  // Konten
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Nama + badge jenis
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nama,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: masalahText1Color,
                                  ),
                                ),
                              ),
                              JenisBadge(jenis: jenis),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row 2: chips NIS & kelas
                          Wrap(
                            spacing: 6,
                            children: [
                              MasalahChip(icon: Icons.badge_outlined, text: nis),
                              if (kelas.isNotEmpty)
                                MasalahChip(icon: Icons.school_outlined, text: kelas),
                            ],
                          ),
                          if (keterangan.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 8),
                            Text(
                              keterangan,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: masalahText2Color,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Row 3: tanggal + status selesai
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: masalahText2Color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                fmtTgl(tgl),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: masalahText2Color,
                                ),
                              ),
                              const Spacer(),
                              if (!isAktif && tglSelesai.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 11,
                                      color: masalahAccentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Selesai ${fmtTgl(tglSelesai)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: masalahAccentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              if (isAktif)
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: masalahText2Color,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
