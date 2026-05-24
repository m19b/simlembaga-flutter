import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color _kAccent = Color(0xFF16A34A);
const Color _kText1  = Color(0xFF111827);

Color masalahJenisColor(String? jenis) {
  switch (jenis) {
    case 'Kehadiran':                  return const Color(0xFFEF4444);
    case 'Keterlambatan Belajar':      return const Color(0xFFF59E0B);
    case 'Tidak Disimak di Rumah':     return const Color(0xFF8B5CF6);
    default:                           return const Color(0xFF6B7280);
  }
}

IconData masalahJenisIcon(String? jenis) {
  switch (jenis) {
    case 'Kehadiran':                  return Icons.event_busy_rounded;
    case 'Keterlambatan Belajar':      return Icons.trending_down_rounded;
    case 'Tidak Disimak di Rumah':     return Icons.hearing_disabled_rounded;
    default:                           return Icons.info_outline_rounded;
  }
}

String masalahJenisLabel(String? jenis) => jenis ?? 'Lainnya';

class MasalahTogglePill extends StatelessWidget {
  final bool isAktif;
  final int aktifCount;
  final int selesaiCount;
  final void Function(bool) onSwitch;

  const MasalahTogglePill({
    required this.isAktif,
    required this.aktifCount,
    required this.selesaiCount,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          MasalahPill(
            label: 'Aktif',
            count: aktifCount,
            selected: isAktif,
            dotColor: Colors.red.shade400,
            onTap: () => onSwitch(true),
          ),
          MasalahPill(
            label: 'Selesai',
            count: selesaiCount,
            selected: !isAktif,
            dotColor: _kAccent,
            onTap: () => onSwitch(false),
          ),
        ],
      ),
    );
  }
}

class MasalahPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color dotColor;
  final VoidCallback onTap;

  const MasalahPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(24),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? _kText1 : Colors.white70,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? dotColor.withAlpha(26)
                        : Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selected ? dotColor : Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- Masalah Card --------------------------------------------------------------
class MasalahCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAktif;
  final VoidCallback onTap;

  const MasalahCard({
    required this.item,
    required this.isAktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nama = item['nama_santri']?.toString() ?? '-';
    final nis = item['nis']?.toString() ?? '';
    final kelas =
        item['kelas']?.toString() ?? item['tingkat']?.toString() ?? '';
    final jenis = item['jenis_masalah']?.toString();
    final keterangan =
        item['deskripsi']?.toString() ?? item['keterangan']?.toString() ?? '';
    final tgl =
        item['tgl_masalah']?.toString() ??
        item['tgl_deteksi']?.toString() ??
        '';
    final tglSelesai = item['tgl_selesai']?.toString() ?? '';
    final status = item['status']?.toString() ?? '';

    final barClr = masalahJenisColor(jenis);

    // Format tanggal
    String _fmtTgl(String raw) {
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
        color: Theme.of(context).cardColor,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              MasalahJenisBadge(jenis: jenis),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row 2: chips NIS & kelas
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (status.toLowerCase() == 'pending approval')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text('Pending', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                                ),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Row 3: tanggal + status selesai
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmtTgl(tgl),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const Spacer(),
                              if (!isAktif && tglSelesai.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 11,
                                      color: _kAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Selesai ${_fmtTgl(tglSelesai)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _kAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              if (isAktif)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

// --- Jenis Badge ---------------------------------------------------------------
class MasalahJenisBadge extends StatelessWidget {
  final String? jenis;
  const MasalahJenisBadge({this.jenis});

  @override
  Widget build(BuildContext context) {
    final clr = masalahJenisColor(jenis);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: clr.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(masalahJenisIcon(jenis), size: 11, color: clr),
          const SizedBox(width: 5),
          Text(
            masalahJenisLabel(jenis),
            style: TextStyle(
              fontSize: 11,
              color: clr,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Info Chip -----------------------------------------------------------------
class MasalahChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const MasalahChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withValues(alpha: 0.1) 
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Skeleton Card -------------------------------------------------------------
class MasalahSkeletonCard extends StatefulWidget {
  const MasalahSkeletonCard({super.key});

  @override
  State<MasalahSkeletonCard> createState() => _MasalahSkeletonCardState();
}

class _MasalahSkeletonCardState extends State<MasalahSkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.06 + 0.08 * _anim.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MasalahSkelBox(w: 140, h: 14, opacity: opacity),
                            const Spacer(),
                            MasalahSkelBox(w: 80, h: 22, opacity: opacity, r: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            MasalahSkelBox(w: 70, h: 22, opacity: opacity, r: 6),
                            const SizedBox(width: 8),
                            MasalahSkelBox(w: 60, h: 22, opacity: opacity, r: 6),
                          ],
                        ),
                        const SizedBox(height: 10),
                        MasalahSkelBox(w: double.infinity, h: 12, opacity: opacity),
                        const SizedBox(height: 6),
                        MasalahSkelBox(w: 200, h: 12, opacity: opacity),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MasalahSkelBox extends StatelessWidget {
  final double w, h, opacity;
  final double r;
  const MasalahSkelBox({
    required this.w,
    required this.h,
    required this.opacity,
    this.r = 6,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(r),
    ),
  );
}

// --- Detail Bottom Sheet --------------------------------------------------------