import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'masalah_constants.dart';
import 'masalah_shared_widgets.dart';

class ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAdmin;
  final Future<void> Function(String action, String id, String? catatan) onAction;

  const ApprovalCard({
    super.key,
    required this.item,
    required this.isAdmin,
    required this.onAction,
  });

  String _fmtTgl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('d MMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = item['id_masalah']?.toString() ?? item['id']?.toString() ?? '';
    final nama = item['nama_santri']?.toString() ?? '-';
    final nis = item['nis']?.toString() ?? '';
    final kelas = item['tingkat']?.toString() ?? '';
    final jenis = item['jenis_masalah']?.toString();
    final ket = item['keterangan']?.toString() ?? '';
    final tgl = item['tgl_deteksi']?.toString() ?? item['tgl_masalah']?.toString() ?? '';
    final guru = item['nama_pembuat']?.toString() ?? item['username']?.toString() ?? '-';
    final barClr = masalahJenisColor(jenis);
    const kOrange = Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: barClr.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: barClr),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(nama,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: masalahText1Color)),
                          ),
                          JenisBadge(jenis: jenis),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          MasalahChip(icon: Icons.badge_outlined, text: nis),
                          if (kelas.isNotEmpty)
                            MasalahChip(icon: Icons.school_outlined, text: kelas),
                          MasalahChip(
                            icon: Icons.person_outline_rounded,
                            text: 'Oleh: $guru',
                          ),
                        ],
                      ),
                      if (ket.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 6),
                        Text(ket,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: masalahText2Color,
                                height: 1.4)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: masalahText2Color),
                          const SizedBox(width: 4),
                          Text(_fmtTgl(tgl),
                              style: const TextStyle(
                                  fontSize: 11, color: masalahText2Color)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kOrange.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_empty_rounded,
                                    size: 10, color: kOrange),
                                const SizedBox(width: 4),
                                const Text('Menunggu',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: kOrange,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Tombol aksi: hanya tampil jika isAdmin
                      if (isAdmin) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.red.shade300, width: 1),
                                  foregroundColor: Colors.red.shade600,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                onPressed: () =>
                                    _showTolakDialog(context, id),
                                icon: const Icon(Icons.cancel_outlined,
                                    size: 15),
                                label: const Text('Tolak',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: masalahAccentColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () =>
                                    _showSetujuiDialog(context, id, nama),
                                icon: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 15),
                                label: const Text('Setujui',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Guru: tampil info saja tanpa tombol aksi
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: kOrange.withAlpha(60)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 14, color: Color(0xFFF59E0B)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Menunggu persetujuan admin',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
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

  void _showSetujuiDialog(BuildContext context, String id, String namaSantri) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: masalahAccentColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: masalahAccentColor, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Setujui Masalah',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: masalahText1Color)),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: masalahText2Color),
            children: [
              const TextSpan(text: 'Masalah untuk '),
              TextSpan(
                  text: namaSantri,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: masalahText1Color)),
              const TextSpan(
                  text: ' akan disetujui dan menjadi aktif. Lanjutkan?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: masalahText2Color)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: masalahAccentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onAction('setujui', id, null);
            },
            child: const Text('Setujui',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(BuildContext context, String id) {
    final catatanCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.cancel_rounded,
                  color: Colors.red.shade600, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Tolak Masalah',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: masalahText1Color)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan alasan penolakan:',
                style: TextStyle(color: masalahText2Color, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: masalahText1Color),
              decoration: InputDecoration(
                hintText: 'Tulis alasan penolakan...',
                hintStyle: const TextStyle(color: masalahText2Color, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.red.shade400, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: masalahText2Color)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final catatan = catatanCtrl.text.trim();
              if (catatan.isEmpty) return;
              Navigator.pop(ctx);
              onAction('tolak', id, catatan);
            },
            child: const Text('Tolak',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
