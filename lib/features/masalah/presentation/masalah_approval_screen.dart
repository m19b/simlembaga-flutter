import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);
const Color _kOrange = Color(0xFFF59E0B); // warna khas halaman approval

Color _jenisColor(String? j) {
  switch (j) {
    case 'Kehadiran':
      return const Color(0xFFEF4444);
    case 'Keterlambatan Belajar':
      return const Color(0xFFF59E0B);
    case 'Tidak Disimak di Rumah':
      return const Color(0xFF8B5CF6);
    default:
      return const Color(0xFF6B7280);
  }
}

IconData _jenisIcon(String? j) {
  switch (j) {
    case 'Kehadiran':
      return Icons.event_busy_rounded;
    case 'Keterlambatan Belajar':
      return Icons.trending_down_rounded;
    case 'Tidak Disimak di Rumah':
      return Icons.hearing_disabled_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

// ─── Screen ────────────────────────────────────────────────────────────────────
class MasalahApprovalScreen extends StatefulWidget {
  const MasalahApprovalScreen({super.key});

  @override
  State<MasalahApprovalScreen> createState() => _MasalahApprovalScreenState();
}

class _MasalahApprovalScreenState extends State<MasalahApprovalScreen> {
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final resp = await ApiService.getMasalahPendingApproval();
      final raw = resp['data'];
      List<Map<String, dynamic>> list = [];
      if (raw is Map) {
        final r = raw['masalah'];
        if (r is List) {
          list = r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: _loading
          ? _buildSkeleton()
          : _error.isNotEmpty
          ? _buildError()
          : _buildBody(),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        // Gradient orange-to-green untuk membedakan dari halaman lain
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF92400E), Color(0xFF0F4C2A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Approval Masalah',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Badge pending count
                              if (!_loading && _list.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kOrange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_list.length}',
                                    style: GoogleFonts.dmMono(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            'Tinjau laporan masalah dari guru',
                            style: GoogleFonts.dmSans(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Refresh button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: _load,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deco(double size, double bw) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withAlpha(18), width: bw),
    ),
  );

  // ─── Skeleton ─────────────────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, i) => _ApprovalSkeletonCard(key: ValueKey(i)),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: _kText2),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kHeader,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
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
                  Icons.inbox_rounded,
                  color: _kAccent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tidak Ada Menunggu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kText1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Semua laporan masalah sudah ditinjau.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _kText2,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Info banner
        _InfoBanner(count: _list.length),
        // List
        Expanded(
          child: RefreshIndicator(
            color: _kAccent,
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: _list.length,
              itemBuilder: (_, i) => _ApprovalCard(
                item: _list[i],
                onAction: (action, id, catatan) async {
                  await _handleAction(action, id, catatan);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(String action, String id, String? catatan) async {
    try {
      if (action == 'setujui') {
        await ApiService.setujuiMasalah(id: id);
        _showSnack('Masalah berhasil disetujui', _kAccent);
      } else {
        await ApiService.tolakMasalah(id: id, catatan: catatan ?? '');
        _showSnack('Masalah ditolak', Colors.orange.shade600);
      }
      _load();
    } catch (e) {
      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
        Colors.red.shade600,
      );
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Info Banner ───────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final int count;
  const _InfoBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange.withAlpha(26), _kOrange.withAlpha(10)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kOrange.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions_rounded, color: _kOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count laporan menunggu persetujuan Anda',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Approval Card ─────────────────────────────────────────────────────────────
class _ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Future<void> Function(String action, String id, String? catatan)
  onAction;

  const _ApprovalCard({required this.item, required this.onAction});

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
    final tgl =
        item['tgl_deteksi']?.toString() ??
        item['tgl_masalah']?.toString() ??
        '';
    final guru =
        item['nama_pembuat']?.toString() ?? item['username']?.toString() ?? '-';
    final barClr = _jenisColor(jenis);

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
              // Left severity bar
              Container(width: 4, color: barClr),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: nama + jenis badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nama,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _kText1,
                              ),
                            ),
                          ),
                          _JenisBadge(jenis: jenis, barClr: barClr),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 2: chips
                      Wrap(
                        spacing: 6,
                        children: [
                          _Chip(icon: Icons.badge_outlined, text: nis),
                          if (kelas.isNotEmpty)
                            _Chip(icon: Icons.school_outlined, text: kelas),
                          _Chip(
                            icon: Icons.person_outline_rounded,
                            text: 'Oleh: $guru',
                          ),
                        ],
                      ),
                      if (ket.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 8),
                        Text(
                          ket,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: _kText2,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Tanggal
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: _kText2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _fmtTgl(tgl),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: _kText2,
                            ),
                          ),
                          const Spacer(),
                          // Status pending badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kOrange.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hourglass_empty_rounded,
                                  size: 10,
                                  color: _kOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Menunggu',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: _kOrange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      // Action buttons
                      Row(
                        children: [
                          // Tombol Tolak
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.red.shade300,
                                  width: 1,
                                ),
                                foregroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _showTolakDialog(context, id),
                              icon: const Icon(Icons.cancel_outlined, size: 16),
                              label: Text(
                                'Tolak',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Tombol Setujui
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () =>
                                  _showSetujuiDialog(context, id, nama),
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text(
                                'Setujui',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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
    );
  }

  void _showSetujuiDialog(BuildContext context, String id, String namaSantri) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kAccent.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _kAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Setujui Masalah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kText1,
                ),
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.dmSans(fontSize: 13, color: _kText2),
            children: [
              const TextSpan(text: 'Masalah untuk '),
              TextSpan(
                text: namaSantri,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _kText1,
                ),
              ),
              const TextSpan(
                text: ' akan disetujui dan menjadi aktif. Lanjutkan?',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.dmSans(color: _kText2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onAction('setujui', id, null);
            },
            child: Text(
              'Setujui',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_rounded,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Tolak Masalah',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _kText1,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Berikan alasan penolakan:',
              style: GoogleFonts.dmSans(color: _kText2, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              autofocus: true,
              style: GoogleFonts.dmSans(fontSize: 13, color: _kText1),
              decoration: InputDecoration(
                hintText: 'Tulis alasan penolakan…',
                hintStyle: GoogleFonts.dmSans(color: _kText2, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.dmSans(color: _kText2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final catatan = catatanCtrl.text.trim();
              if (catatan.isEmpty) return;
              Navigator.pop(ctx);
              onAction('tolak', id, catatan);
            },
            child: Text(
              'Tolak',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Jenis Badge ───────────────────────────────────────────────────────────────
class _JenisBadge extends StatelessWidget {
  final String? jenis;
  final Color barClr;
  const _JenisBadge({this.jenis, required this.barClr});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: barClr.withAlpha(20),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_jenisIcon(jenis), size: 11, color: barClr),
        const SizedBox(width: 5),
        Text(
          jenis ?? 'Lainnya',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: barClr,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─── Info Chip ─────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: _kText2),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.dmMono(
            fontSize: 10,
            color: _kText2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Skeleton Card ─────────────────────────────────────────────────────────────
class _ApprovalSkeletonCard extends StatefulWidget {
  const _ApprovalSkeletonCard({super.key});

  @override
  State<_ApprovalSkeletonCard> createState() => _ApprovalSkeletonCardState();
}

class _ApprovalSkeletonCardState extends State<_ApprovalSkeletonCard>
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
        final op = 0.06 + 0.08 * _anim.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
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
                            _S(w: 130, h: 14, op: op),
                            const Spacer(),
                            _S(w: 80, h: 22, op: op, r: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _S(w: 60, h: 22, op: op, r: 6),
                            const SizedBox(width: 8),
                            _S(w: 50, h: 22, op: op, r: 6),
                            const SizedBox(width: 8),
                            _S(w: 80, h: 22, op: op, r: 6),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _S(w: double.infinity, h: 12, op: op),
                        const SizedBox(height: 6),
                        _S(w: 200, h: 12, op: op),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _S(
                                w: double.infinity,
                                h: 44,
                                op: op,
                                r: 10,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _S(
                                w: double.infinity,
                                h: 44,
                                op: op,
                                r: 10,
                              ),
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
        );
      },
    );
  }
}

class _S extends StatelessWidget {
  final double w, h, op;
  final double r;
  const _S({required this.w, required this.h, required this.op, this.r = 6});

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(op),
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
