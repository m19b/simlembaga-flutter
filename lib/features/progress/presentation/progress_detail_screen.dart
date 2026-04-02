import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'bottom_edit.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);

class ProgressDetailScreen extends StatefulWidget {
  final Map<String, dynamic> santri;
  const ProgressDetailScreen({super.key, required this.santri});

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  Map<String, dynamic>? _detail;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final nis = widget.santri['nis']?.toString() ?? '';
      final data = await ApiService.getProgressDetail(nis);
      setState(() {
        _detail = data['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  // =========================================================
  // FUNGSI BARU: HAPUS & EDIT DATA
  // =========================================================

  void _hapusData(int idPrestasi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus riwayat progres ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                // Panggil endpoint delete di ApiService
                await ApiService.deleteProgress(idPrestasi);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil dihapus")),
                );
                _load(); // Refresh data dari server
              } catch (e) {
                if (!mounted) return;
                setState(() => _loading = false);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _tampilkanBottomSheetEdit(Map<dynamic, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return BottomEdit(
          dataPrestasi: Map<String, dynamic>.from(item),
          onSave: (updatedItem) async {
            setState(() => _loading = true);
            try {
              // Panggil endpoint update di ApiService
              await ApiService.updateProgress(
                int.tryParse(
                      updatedItem['id']?.toString() ??
                          updatedItem['id_prestasi']?.toString() ??
                          '0',
                    ) ??
                    0,
                updatedItem,
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil diperbarui")),
              );
              _load(); // Refresh data dari server
            } catch (e) {
              if (!mounted) return;
              setState(() => _loading = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Gagal memperbarui: $e")));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = widget.santri['nama_santri'] ?? 'Detail Santri';
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kHeader,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nama,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'NIS: ${widget.santri['nis'] ?? '-'}',
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF22C55E),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Riwayat'),
            Tab(text: 'Input'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : _error.isNotEmpty
          ? _buildError()
          : TabBarView(
              controller: _tabs,
              children: [_buildRingkasan(), _buildRiwayat(), _buildInput()],
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: _kText2),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            onPressed: _load,
            icon: const Icon(Icons.refresh, color: Colors.white),
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
    );
  }

  // ─── TAB 1: Ringkasan ─────────────────────────────────────────────────────
  Widget _buildRingkasan() {
    final santri = Map<String, dynamic>.from(_detail?['santri'] ?? {});
    final prediksi = Map<String, dynamic>.from(_detail?['prediksi'] ?? {});
    final masalah = (_detail?['masalah_aktif'] as List? ?? [])
        .cast<Map<dynamic, dynamic>>();

    final int halReg =
        int.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final int totReg =
        int.tryParse(santri['total_hal']?.toString() ?? '604') ?? 604;
    final double pctReg = totReg > 0 ? (halReg / totReg).clamp(0.0, 1.0) : 0.0;

    final int halLat = int.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;
    final int totLat =
        int.tryParse(santri['target_latihan']?.toString() ?? '0') ?? 0;
    final double pctLat = totLat > 0 ? (halLat / totLat).clamp(0.0, 1.0) : 0.0;

    final int halTot = halReg + halLat;
    final int maxTot = totReg + totLat;
    final double pctTot = maxTot > 0 ? (halTot / maxTot).clamp(0.0, 1.0) : 0.0;

    final String kLabel = santri['kLabel']?.toString() ?? '-';
    final Color kColor = _getColor(santri['kClr']?.toString());

    return RefreshIndicator(
      color: _kAccent,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            '🎯 Progres Khotaman',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _progressBar('Reguler (Halaman)', halReg, totReg, pctReg),
                if (totLat > 0) ...[
                  const SizedBox(height: 12),
                  _progressBar('Latihan', halLat, totLat, pctLat),
                  const SizedBox(height: 12),
                  _progressBar('Total Keseluruhan', halTot, maxTot, pctTot),
                ],
                const Divider(height: 30),
                Text(
                  '⚡ Kecepatan Belajar',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _kText1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rasio Aktual vs Baku',
                      style: GoogleFonts.dmSans(fontSize: 13, color: _kText2),
                    ),
                    Text(
                      '${santri['rasioTotal'] ?? '0'}%',
                      style: GoogleFonts.dmMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _kText1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori Performa',
                      style: GoogleFonts.dmSans(fontSize: 13, color: _kText2),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (prediksi['tersedia'] == true)
            _section(
              '📅 Prediksi Khatam',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Lembaga',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _kText1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _predDetailedRow(
                    'Reguler',
                    prediksi['baku_reg_tgl'],
                    prediksi['baku_reg_hari'],
                  ),
                  if (totLat > 0)
                    _predDetailedRow(
                      'Latihan',
                      prediksi['baku_lat_tgl'],
                      prediksi['baku_lat_hari'],
                    ),
                  _predDetailedRow(
                    'Total',
                    prediksi['baku_tot_tgl'],
                    prediksi['baku_tot_hari'],
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  Text(
                    'Target Aktual',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _kText1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _predDetailedRow(
                    'Reguler',
                    prediksi['akt_reg_tgl'],
                    prediksi['akt_reg_hari'],
                  ),
                  if (totLat > 0)
                    _predDetailedRow(
                      'Latihan',
                      prediksi['akt_lat_tgl'],
                      prediksi['akt_lat_hari'],
                    ),
                  _predDetailedRow(
                    'Total',
                    prediksi['akt_tot_tgl'],
                    prediksi['akt_tot_hari'],
                    isBold: true,
                    highlight: true,
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selisih Waktu',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _kText1,
                        ),
                      ),
                      Text(
                        '${prediksi['selisih_hari']} Sesi',
                        style: GoogleFonts.dmMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              (int.tryParse(
                                        prediksi['selisih_hari']?.toString() ??
                                            '0',
                                      ) ??
                                      0) >
                                  0
                              ? Colors.red.shade600
                              : _kAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dasar Hitung: ',
                        style: GoogleFonts.dmSans(fontSize: 11, color: _kText2),
                      ),
                      Expanded(
                        child: Text(
                          prediksi['dasar_hitung']?.toString() ?? '-',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _kText2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            _section(
              '📅 Prediksi Khatam',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  prediksi['pesan']?.toString() ?? 'Belum ada data prediksi.',
                  style: GoogleFonts.dmSans(color: _kText2),
                ),
              ),
            ),
          const SizedBox(height: 14),

          _section(
            '👤 Identitas',
            child: Column(
              children: [
                _infoRow('Tingkat Jilid', santri['tingkat']?.toString() ?? '-'),
                _infoRow(
                  'Kelompok',
                  santri['nama_kelompok']?.toString() ?? '-',
                ),
                _infoRow('NIS', santri['nis']?.toString() ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _section(
            '⚠️ Masalah Aktif',
            child: masalah.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: _kAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tidak ada masalah yang aktif',
                          style: GoogleFonts.dmSans(color: _kAccent),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: masalah.map((m) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['jenis_masalah']?.toString() ?? '-',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  if ((m['deskripsi']?.toString() ?? '')
                                      .isNotEmpty)
                                    Text(
                                      m['deskripsi']!.toString(),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: _kText2,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _progressBar(String label, int val, int maxVal, double pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _kText2,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$val / $maxVal',
              style: GoogleFonts.dmMono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _kText1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: _kAccent.withAlpha(26),
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 1.0 ? Colors.amber.shade600 : _kAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _speedRow(
    String label,
    dynamic rasio,
    dynamic aktual,
    dynamic baku, {
    bool isBold = false,
  }) {
    String act =
        double.tryParse(aktual?.toString() ?? '0')?.toStringAsFixed(2) ??
        '0.00';
    String bak =
        double.tryParse(baku?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00';
    String pct = rasio?.toString() ?? '0';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: _kText2,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$pct% ($act / $bak)',
            style: GoogleFonts.dmMono(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 14 : 13,
              color: _kText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _predDetailedRow(
    String label,
    dynamic tgl,
    dynamic hari, {
    bool isBold = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label',
            style: GoogleFonts.dmSans(color: _kText2, fontSize: 12),
          ),
          Text(
            '${tgl ?? '-'} (${hari ?? 0} Sesi)',
            style: GoogleFonts.dmMono(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              color: highlight ? _kAccent : _kText1,
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: Riwayat ───────────────────────────────────────────────────────
  Widget _buildRiwayat() {
    final riwayat = (_detail?['riwayat'] as List? ?? [])
        .cast<Map<dynamic, dynamic>>();

    if (riwayat.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat simakan',
              style: GoogleFonts.dmSans(color: _kText2),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: riwayat.length,
      itemBuilder: (_, i) {
        final r = riwayat[i];
        final String tglOnly = (r['tgl_simak']?.toString() ?? '-')
            .split(' ')
            .first;
        final status = r['status']?.toString().toLowerCase() ?? '';
        final isLulus = status == 'lulus';
        final Color nilaiColor = isLulus ? _kAccent : Colors.red.shade500;
        final String modeStr =
            r['mode_belajar']?.toString().toUpperCase() ?? '-';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: nilaiColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isLulus ? 'L' : 'M',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: nilaiColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tglOnly,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _kText1,
                          ),
                        ),
                        Text(
                          modeStr,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _kText2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${r['halaman'] ?? 0} hal',
                    style: GoogleFonts.dmMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _kText1,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 14,
                    bottom: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      _infoRow('Status', isLulus ? 'Lulus' : 'Mengulang'),
                      _infoRow(
                        'Rentang Hal.',
                        '${r['hal_awal'] ?? 0} s/d ${r['hal_akhir'] ?? 0}',
                      ),
                      _infoRow(
                        'Catatan',
                        r['catatan']?.toString() == ''
                            ? '-'
                            : r['catatan'].toString(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // --- TOMBOL HAPUS ---
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                            ),
                            onPressed: () {
                              if (i != 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Tidak boleh dihapus karena ada progres terbaru!",
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              int id =
                                  int.tryParse(
                                    r['id']?.toString() ??
                                        r['id_prestasi']?.toString() ??
                                        '0',
                                  ) ??
                                  0;
                              if (id != 0) _hapusData(id);
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(
                              'Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // --- TOMBOL EDIT ---
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (i != 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Tidak boleh diubah karena ada progres terbaru!",
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              _tampilkanBottomSheetEdit(r);
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Edit',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── TAB 3: Form Input Cepat ──────────────────────────────────────────────
  // ─── TAB 3: Form Input Cepat ──────────────────────────────────────────────
  Widget _buildInput() {
    final santri = Map<String, dynamic>.from(_detail?['santri'] ?? {});
    final int totalHal =
        int.tryParse(santri['total_hal']?.toString() ?? '0') ?? 0;
    final int targetLat =
        int.tryParse(santri['target_latihan']?.toString() ?? '0') ?? 0;
    final int capaiReg =
        int.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final int capaiLat =
        int.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;

    final bool isLatihan = capaiReg >= totalHal && totalHal > 0;
    final int sisaHal = isLatihan
        ? (targetLat - capaiLat)
        : (totalHal - capaiReg);
    final String modeLabel = isLatihan ? 'latihan' : 'reguler';
    final int halAwalAsli = isLatihan
        ? capaiLat
        : capaiReg; // 🔴 Menentukan default hal_awal

    return _InputForm(
      nis: widget.santri['nis']?.toString() ?? '',
      sisaHal: sisaHal > 0 ? sisaHal : 0,
      modeBelajar: modeLabel,
      initialHalAwal: halAwalAsli,
      onSuccess: _load,
    );
  }

  Widget _section(String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _kText1,
            ),
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _predRow(String label, String val, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: _kText2, fontSize: 13)),
          Text(
            val,
            style: GoogleFonts.dmMono(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              fontSize: highlight ? 15 : 13,
              color: highlight ? _kAccent : _kText1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String val) => _predRow(label, val);

  Color _getColor(String? kClr) {
    switch (kClr) {
      case 'success':
        return Colors.green.shade600;
      case 'primary':
        return Colors.blue.shade600;
      case 'info':
        return Colors.cyan.shade600;
      case 'warning':
        return Colors.orange.shade600;
      case 'danger':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade400;
    }
  }
}

// ─── Form Input Cepat ─────────────────────────────────────────────────────────
class _InputForm extends StatefulWidget {
  final String nis;
  final int sisaHal;
  final String modeBelajar;
  final int initialHalAwal;
  final VoidCallback onSuccess;

  const _InputForm({
    required this.nis,
    required this.sisaHal,
    required this.modeBelajar,
    required this.initialHalAwal,
    required this.onSuccess,
  });

  @override
  State<_InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<_InputForm> {
  final _formKey = GlobalKey<FormState>();

  // 🔴 Controller untuk 3 kotak halaman
  final _halAwalCtrl = TextEditingController();
  final _halTotalCtrl = TextEditingController();
  final _halAkhirCtrl = TextEditingController();

  final _ketCtrl = TextEditingController();

  bool _isLulus = true;
  bool _isDisimak = true;

  DateTime _tgl = DateTime.now();
  bool _saving = false;
  String _msg = '';
  bool _success = false;

  @override
  void initState() {
    super.initState();
    // Mengisi default nilai Hal Awal sesuai progress santri
    _halAwalCtrl.text = widget.initialHalAwal.toString();
    _halTotalCtrl.text = '1';
    _recalc(from: 'total');
  }

  @override
  void dispose() {
    _halAwalCtrl.dispose();
    _halTotalCtrl.dispose();
    _halAkhirCtrl.dispose();
    _ketCtrl.dispose();
    super.dispose();
  }

  // 🔴 Logika Reactive saat 3 kotak diedit
  void _recalc({required String from}) {
    int awal = int.tryParse(_halAwalCtrl.text) ?? 0;
    int total = int.tryParse(_halTotalCtrl.text) ?? 0;
    int akhir = int.tryParse(_halAkhirCtrl.text) ?? 0;

    if (from == 'awal' || from == 'total') {
      int newAkhir = ((awal + total) - 1) + 1;
      _halAkhirCtrl.text = newAkhir > 0 ? newAkhir.toString() : '';
    } else if (from == 'akhir') {
      int newTotal = ((akhir - awal) + 1) + 1;
      if (newTotal < 0) newTotal = 0;
      _halTotalCtrl.text = newTotal > 0 ? newTotal.toString() : '';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tgl,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _kAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tgl = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔴 VALIDASI SISA HALAMAN
    int inputTotal = int.tryParse(_halTotalCtrl.text.trim()) ?? 0;
    if (inputTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Total halaman minimal 1!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }
    if (inputTotal > widget.sisaHal && widget.sisaHal > 0) {
      setState(() {
        _success = false;
        _msg =
            'Maksimal input: ${widget.sisaHal} halaman (Sisa ${widget.modeBelajar})';
      });
      return;
    }

    setState(() {
      _saving = true;
      _msg = '';
      _success = false;
    });
    try {
      final tglStr =
          '${_tgl.year.toString().padLeft(4, '0')}-${_tgl.month.toString().padLeft(2, '0')}-${_tgl.day.toString().padLeft(2, '0')}';

      await ApiService.inputCepatProgress({
        'nis': widget.nis,
        'tgl_simak': tglStr,
        'hal_awal':
            int.tryParse(_halAwalCtrl.text.trim()) ?? 0, // 🔴 Hal Awal dikirim
        'hal_total': int.tryParse(_halTotalCtrl.text.trim()) ?? 0,
        'status_halaman': _isLulus ? 'Lulus' : 'Mengulang',
        'catatan_guru': _ketCtrl.text.trim(),
        'mode_belajar': widget.modeBelajar,
        'disimak': _isDisimak ? '1' : '0',
      });

      setState(() {
        _saving = false;
        _success = true;
      });

      _halTotalCtrl.clear();
      _halAkhirCtrl.clear();
      _ketCtrl.clear();

      // 🔴 Notifikasi Hijau yang cantik
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Data berhasil disimpan!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: _kAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      widget.onSuccess();
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'].toString();
        }
      }
      setState(() {
        _saving = false;
        _msg = errorMsg;
      });
    }
  }

  Widget _buildBox({
    required String label,
    required TextEditingController ctrl,
    bool isPrimary = false,
    Color? textColor,
    Function(String)? onChanged,
    VoidCallback? onAdd,
    VoidCallback? onMinus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: isPrimary ? Colors.red.shade600 : _kText2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? _kText1,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isPrimary ? Colors.white : _kBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isPrimary ? _kAccent : Colors.grey.shade400,
              ),
            ),
            prefixIcon: onMinus != null
                ? IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    onPressed: onMinus,
                    splashRadius: 16,
                  )
                : null,
            suffixIcon: onAdd != null
                ? IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    onPressed: onAdd,
                    splashRadius: 16,
                  )
                : null,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelesai = widget.sisaHal == 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Simakan Cepat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _kText1,
              ),
            ),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelesai
                    ? Colors.amber.shade100
                    : _kAccent.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isSelesai
                    ? 'SANTRI SUDAH SIAP TEST (100% Selesai)'
                    : 'Fase: ${widget.modeBelajar.toUpperCase()} | Sisa Target: ${widget.sisaHal} Hal',
                style: GoogleFonts.plusJakartaSans(
                  color: isSelesai ? Colors.amber.shade800 : _kAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label('Tanggal Simak'),
            GestureDetector(
              onTap: isSelesai ? null : _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelesai ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: isSelesai ? Colors.grey : _kAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_tgl.day.toString().padLeft(2, '0')}/${_tgl.month.toString().padLeft(2, '0')}/${_tgl.year}',
                      style: GoogleFonts.dmMono(
                        fontSize: 14,
                        color: isSelesai ? Colors.grey : _kText1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 🔴 3 KOTAK HALAMAN (Awal, Total, Akhir)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildBox(
                    label: 'Hal Awal',
                    ctrl: _halAwalCtrl,
                    onChanged: (v) => _recalc(from: 'awal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBox(
                    label: 'Hal Total *',
                    ctrl: _halTotalCtrl,
                    isPrimary: true,
                    onChanged: (v) => _recalc(from: 'total'),
                    onAdd: () {
                      int val = int.tryParse(_halTotalCtrl.text) ?? 0;
                      _halTotalCtrl.text = (val + 1).toString();
                      _recalc(from: 'total');
                    },
                    onMinus: () {
                      int val = int.tryParse(_halTotalCtrl.text) ?? 0;
                      if (val > 1) {
                        _halTotalCtrl.text = (val - 1).toString();
                        _recalc(from: 'total');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBox(
                    label: 'Hal Akhir',
                    ctrl: _halAkhirCtrl,
                    textColor: Colors.indigo.shade600,
                    onChanged: (v) => _recalc(from: 'akhir'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _label('Status Simakan'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isSelesai
                        ? null
                        : () => setState(() => _isLulus = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isLulus ? _kAccent : Colors.white,
                        border: Border.all(
                          color: _isLulus ? _kAccent : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Lulus',
                        style: GoogleFonts.plusJakartaSans(
                          color: _isLulus ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: isSelesai
                        ? null
                        : () => setState(() => _isLulus = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isLulus ? Colors.red.shade500 : Colors.white,
                        border: Border.all(
                          color: !_isLulus
                              ? Colors.red.shade500
                              : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Mengulang',
                        style: GoogleFonts.plusJakartaSans(
                          color: !_isLulus ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _label('Disimak di Rumah?'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isSelesai
                        ? null
                        : () => setState(() => _isDisimak = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isDisimak ? Colors.blue.shade600 : Colors.white,
                        border: Border.all(
                          color: _isDisimak
                              ? Colors.blue.shade600
                              : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Ya, Disimak',
                        style: GoogleFonts.plusJakartaSans(
                          color: _isDisimak ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: isSelesai
                        ? null
                        : () => setState(() => _isDisimak = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isDisimak
                            ? Colors.orange.shade600
                            : Colors.white,
                        border: Border.all(
                          color: !_isDisimak
                              ? Colors.orange.shade600
                              : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tidak',
                        style: GoogleFonts.plusJakartaSans(
                          color: !_isDisimak ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _label('Keterangan (opsional)'),
            TextFormField(
              controller: _ketCtrl,
              enabled: !isSelesai,
              maxLines: 3,
              style: GoogleFonts.dmSans(fontSize: 14),
              decoration: _inputDeco('Catatan tambahan…'),
            ),
            const SizedBox(height: 24),

            if (_msg.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_rounded,
                      color: Colors.red.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _msg,
                        style: GoogleFonts.dmSans(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelesai ? Colors.grey : _kAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (_saving || isSelesai) ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Simpan Simakan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: _kText1,
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
