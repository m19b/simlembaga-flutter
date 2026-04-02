import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const Color _kHeader  = Color(0xFF0F4C2A);
const Color _kBg      = Color(0xFFF3F4F6);
const Color _kText1   = Color(0xFF111827);
const Color _kText2   = Color(0xFF6B7280);
const Color _kAccent  = Color(0xFF16A34A);
const Color _kWhite   = Colors.white;

// ─── Data Model per baris evaluasi ────────────────────────────────────────────
class _RowState {
  final Map<String, dynamic> santri;
  final int halAwal;
  final int targetHal;
  final String mode; // 'reguler' atau 'latihan'
  final bool siapTest;

  int halTotal = 1;
  bool lulus   = true;
  bool disimak = true;

  _RowState({
    required this.santri,
    required this.halAwal,
    required this.targetHal,
    required this.mode,
    required this.siapTest,
  });

  // Helper untuk JSON payload
  Map<String, dynamic> toPayload() => {
    'nis'          : santri['nis'],
    'id_kelas'     : santri['id_kelas'],
    'hal_awal'     : halAwal,
    'hal_total'    : halTotal,
    'mode_belajar' : mode,
    'lulus'        : lulus ? '1' : '0',
    'disimak'      : disimak ? '1' : '0',
  };
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ProgressInputScreen extends StatefulWidget {
  const ProgressInputScreen({super.key});
  @override
  State<ProgressInputScreen> createState() => _ProgressInputScreenState();
}

class _ProgressInputScreenState extends State<ProgressInputScreen> {
  // Data
  List<_RowState> _rows = [];
  bool _loading  = true;
  bool _saving   = false;
  String _error  = '';
  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSantri();
  }

  // ─── Load santri via existing getProgressList ─────────────────────────────
  Future<void> _loadSantri() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = ''; _rows = []; });
    try {
      final resp = await ApiService.getProgressList();
      final raw  = resp['data'];
      List<Map<String, dynamic>> list = [];
      if (raw is Map) {
        final rawList = raw['santri_list'];
        if (rawList is List && rawList.isNotEmpty) {
          list = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } else if (raw is List) {
        list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      final rows = <_RowState>[];
      for (final s in list) {
        final int capai    = int.tryParse(s['capai_hal']?.toString()      ?? '0') ?? 0;
        final int totalHal = int.tryParse(s['total_hal']?.toString()       ?? '40') ?? 40;
        final int latSek   = int.tryParse(s['lat_sek']?.toString()         ?? '0') ?? 0;
        final int targetLat= int.tryParse(s['target_latihan']?.toString()  ?? '8') ?? 8;
        final bool isLat   = capai >= totalHal && totalHal > 0;
        final bool siap    = isLat && targetLat > 0 && latSek >= targetLat;
        final int halAwal  = isLat ? latSek : capai;
        final int target   = isLat ? targetLat : totalHal;
        final String modeStr = isLat ? 'latihan' : 'reguler';

        final row = _RowState(
          santri   : s,
          halAwal  : halAwal,
          targetHal: target,
          mode     : modeStr,
          siapTest : siap,
        );
        rows.add(row);
      }

      if (!mounted) return;
      setState(() { _rows = rows; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  // ─── Save ─────────────────────────────────────────────────────────────────
  Future<void> _simpan() async {
    final aktif = _rows.where((r) => !r.siapTest && r.halTotal > 0).toList();
    if (aktif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk disimpan.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        'tanggal'  : DateFormat('yyyy-MM-dd').format(_tanggal),
        'evaluasi' : aktif.map((r) => r.toPayload()).toList(),
      };
      final res = await ApiService.inputMassalProgress(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Evaluasi berhasil disimpan!'),
          backgroundColor: _kAccent,
        ),
      );
      Navigator.pop(context, true); // kembali + refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── UI Helpers ───────────────────────────────────────────────────────────
  void _lulusSemua()  { setState(() { for (final r in _rows) { if (!r.siapTest) r.lulus  = true;  } }); }
  void _ulangSemua()  { setState(() { for (final r in _rows) { if (!r.siapTest) r.lulus  = false; } }); }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: _loading ? _buildLoader() : _error.isNotEmpty ? _buildError() : _buildBody(),
      bottomNavigationBar: _loading || _error.isNotEmpty ? null : _buildBottom(),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        color: _kHeader,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kWhite, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Input Evaluasi', style: GoogleFonts.plusJakartaSans(
                              color: _kWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Catat capaian belajar harian seluruh santri',
                              style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    // Pill Tanggal
                    GestureDetector(
                      onTap: _pickTanggal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 13),
                          const SizedBox(width: 5),
                          Text(DateFormat('d MMM y').format(_tanggal),
                              style: GoogleFonts.dmMono(color: Colors.white, fontSize: 11)),
                        ]),
                      ),
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

  Widget _deco(double size, double borderW) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withAlpha(20), width: borderW),
    ),
  );

  // ─── Date Picker ─────────────────────────────────────────────────────────
  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _kHeader)),
        child: child!,
      ),
    );
    if (picked != null && picked != _tanggal) setState(() => _tanggal = picked);
  }

  // ─── Toolbar (Lulus Semua / Ulang Semua) ──────────────────────────────────
  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text('${_rows.where((r) => !r.siapTest).length} santri aktif',
              style: GoogleFonts.dmSans(fontSize: 12, color: _kText2)),
          const Spacer(),
          _toolChip('Lulus Semua', Colors.green, Icons.check_circle_outline_rounded, _lulusSemua),
          const SizedBox(width: 8),
          _toolChip('Ulang Semua', Colors.orange, Icons.refresh_rounded, _ulangSemua),
        ],
      ),
    );
  }

  Widget _toolChip(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  // ─── Main Body ────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: _rows.length,
            itemBuilder: (_, i) => _buildCard(_rows[i], i),
          ),
        ),
      ],
    );
  }

  // ─── Card per Santri ──────────────────────────────────────────────────────
  Widget _buildCard(_RowState row, int idx) {
    final s = row.santri;
    final nama  = s['nama_santri']?.toString() ?? '-';
    final nis   = s['nis']?.toString()         ?? '-';
    final kelas = s['kelas']?.toString()       ?? '-';

    if (row.siapTest) {
      // Card khusus SIAP TEST — tidak bisa diinput
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Text(nama[0].toUpperCase(), style: GoogleFonts.plusJakartaSans(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
          ),
          title: Text(nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(nis, style: GoogleFonts.dmMono(fontSize: 10, color: _kText2)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(20)),
            child: Text('SIAP TEST', style: GoogleFonts.plusJakartaSans(color: _kWhite, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // ── Card input normal ──
    return StatefulBuilder(
      builder: (_, setRow) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: row.lulus
              ? Border.all(color: Colors.green.shade200, width: 1.5)
              : Border.all(color: Colors.orange.shade300, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header santri ─────────────────────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _kAccent.withValues(alpha: 0.1),
                    child: Text(nama[0].toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: _kAccent)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: _kText1)),
                      Row(children: [
                        Text(nis, style: GoogleFonts.dmMono(fontSize: 10, color: _kText2)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text(kelas, style: GoogleFonts.dmSans(fontSize: 9, color: Colors.indigo, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: row.mode == 'latihan' ? Colors.blue.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(row.mode == 'latihan' ? 'Latihan' : 'Reguler',
                              style: GoogleFonts.dmSans(fontSize: 9, color: row.mode == 'latihan' ? Colors.blue : _kText2, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ]),
                  ),
                  // Jumlah tertulis
                  Text('Awal: ${row.halAwal}', style: GoogleFonts.dmMono(fontSize: 11, color: _kText2)),
                ],
              ),

              const SizedBox(height: 12),

              // ── Stepper Halaman ────────────────────────────────────────────
              Row(
                children: [
                  // Minus
                  _stepBtn(Icons.remove, onTap: () => setRow(() {
                    if (row.halTotal > 0) row.halTotal--;
                  })),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${row.halTotal} hal',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18, fontWeight: FontWeight.bold, color: _kText1),
                        ),
                      ),
                    ),
                  ),
                  // Plus
                  _stepBtn(Icons.add, isPlus: true, onTap: () => setRow(() {
                    row.halTotal++;
                  })),

                  const SizedBox(width: 12),

                  // Akhir
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Akhir', style: GoogleFonts.dmSans(fontSize: 9, color: Colors.blue.shade600)),
                      Text('${row.halAwal + row.halTotal}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Toggle Lulus & Disimak ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setRow(() => row.lulus = !row.lulus),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 44,
                        decoration: BoxDecoration(
                          color: row.lulus ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(row.lulus ? Icons.check_rounded : Icons.refresh_rounded, color: _kWhite, size: 18),
                          const SizedBox(width: 6),
                          Text(row.lulus ? 'Lulus' : 'Ulang',
                              style: GoogleFonts.plusJakartaSans(color: _kWhite, fontWeight: FontWeight.bold, fontSize: 13)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setRow(() => row.disimak = !row.disimak),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 44,
                        decoration: BoxDecoration(
                          color: row.disimak ? Colors.teal : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(row.disimak ? Icons.library_books_rounded : Icons.book_outlined, color: _kWhite, size: 18),
                          const SizedBox(width: 6),
                          Text(row.disimak ? 'Disimak' : 'Tidak Disimak',
                              style: GoogleFonts.plusJakartaSans(color: _kWhite, fontWeight: FontWeight.bold, fontSize: 12)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step button helper ─────────────────────────────────────────────────────
  Widget _stepBtn(IconData icon, {bool isPlus = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: isPlus ? _kAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isPlus ? _kWhite : _kText1, size: 22),
      ),
    );
  }

  // ─── Bottom Bar Simpan ────────────────────────────────────────────────────
  Widget _buildBottom() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton(
          onPressed: _saving ? null : _simpan,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kHeader,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _saving
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: _kWhite))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.save_rounded, color: _kWhite, size: 20),
                  const SizedBox(width: 8),
                  Text('Simpan Semua Evaluasi',
                      style: GoogleFonts.plusJakartaSans(color: _kWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
        ),
      ),
    );
  }

  // ─── Loading / Error ──────────────────────────────────────────────────────
  Widget _buildLoader() => const Center(child: CircularProgressIndicator(color: _kAccent));

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(_error, textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: _kText2, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadSantri,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
          ),
        ]),
      ),
    );
  }
}
