import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kHeaderColor = Color(0xFF0F4C2A);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

/// Tampilkan bottom sheet Perlu Perhatian
void showUrgentListSheet(
  BuildContext context,
  List<Map<String, dynamic>> urgentList,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UrgentListSheet(urgentList: urgentList),
  );
}

class UrgentListSheet extends StatelessWidget {
  final List<Map<String, dynamic>> urgentList;
  const UrgentListSheet({super.key, required this.urgentList});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _SheetHandle(),
          _SheetHeader(count: urgentList.length),
          const SizedBox(height: 4),
          Expanded(
            child: urgentList.isEmpty
                ? const _EmptyState()
                : _UrgentList(items: urgentList),
          ),
        ],
      ),
    );
  }
}

// ── Drag Handle ──────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final int count;
  const _SheetHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF2F2), Color(0xFFFFF7ED)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Title & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perlu Perhatian',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count > 0
                      ? '$count santri memerlukan tindakan segera'
                      : 'Semua santri dalam kondisi baik',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Count badge
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.dmMono(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── List ─────────────────────────────────────────────────────────────────────

class _UrgentList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _UrgentList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _UrgentCard(item: items[index], index: index);
      },
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _UrgentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  const _UrgentCard({required this.item, required this.index});

  // Tentukan severity berdasarkan jenis_masalah
  _SeverityLevel _getSeverity(String? jenis) {
    if (jenis == null) return _SeverityLevel.medium;
    final j = jenis.toLowerCase();
    if (j.contains('tidak disimak')) return _SeverityLevel.low;
    if (j.contains('keterlambatan') || j.contains('lambat')) {
      return _SeverityLevel.medium;
    }
    return _SeverityLevel.high;
  }

  @override
  Widget build(BuildContext context) {
    final nama = item['nama_santri']?.toString() ?? '-';
    final nis = item['nis']?.toString() ?? '';
    final kelas =
        item['tingkat']?.toString() ?? item['kelas']?.toString() ?? '';
    final jenisMasalah =
        item['jenis_masalah']?.toString() ??
        item['keterangan_masalah']?.toString() ??
        'Perlu Perhatian';
    final keterangan = item['keterangan']?.toString() ?? '';
    final tgl = item['tgl_deteksi']?.toString() ?? '';

    final severity = _getSeverity(jenisMasalah);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: severity.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left severity bar
              Container(width: 4, color: severity.barColor),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: nomor urut + nama + badge severity
                      Row(
                        children: [
                          // Nomor urut
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: severity.barColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.dmMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: severity.barColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Nama
                          Expanded(
                            child: Text(
                              nama,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                          ),
                          // Badge severity
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: severity.badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  severity.icon,
                                  size: 10,
                                  color: severity.barColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  severity.label,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: severity.barColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // NIS & Kelas chips
                      Row(
                        children: [
                          _InfoChip(icon: Icons.badge_outlined, text: nis),
                          if (kelas.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _InfoChip(icon: Icons.school_outlined, text: kelas),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Divider
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 10),
                      // Jenis masalah
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: severity.barColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jenisMasalah,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: severity.barColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Keterangan (jika ada)
                      if (keterangan.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                keterangan,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: kTextSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Tanggal deteksi (jika ada)
                      if (tgl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Terdeteksi: $tgl',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: kTextSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.dmMono(
              fontSize: 10,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Alhamdulillah!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada santri yang perlu perhatian khusus saat ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: kTextSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Severity Level ────────────────────────────────────────────────────────────

enum _SeverityLevel { low, medium, high }

extension _SeverityProps on _SeverityLevel {
  Color get barColor {
    switch (this) {
      case _SeverityLevel.low:
        return const Color(0xFFF59E0B); // amber
      case _SeverityLevel.medium:
        return const Color(0xFFEF4444); // red
      case _SeverityLevel.high:
        return const Color(0xFF7C3AED); // purple/urgent
    }
  }

  Color get borderColor => barColor.withOpacity(0.2);
  Color get badgeBg => barColor.withOpacity(0.08);

  String get label {
    switch (this) {
      case _SeverityLevel.low:
        return 'Perhatikan';
      case _SeverityLevel.medium:
        return 'Segera';
      case _SeverityLevel.high:
        return 'Kritis';
    }
  }

  IconData get icon {
    switch (this) {
      case _SeverityLevel.low:
        return Icons.info_outline_rounded;
      case _SeverityLevel.medium:
        return Icons.warning_amber_rounded;
      case _SeverityLevel.high:
        return Icons.priority_high_rounded;
    }
  }
}
