import 'widgets/detail_input_form_widget.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'bottom_edit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:manajemen_tahsin_app/shared/widgets/multi_segment_progress_bar.dart';

import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';


// --- Design Tokens ------------------------------------------------------------
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);

String _f(num? v) =>
    v == null ? '0' : v.toString().replaceAll(RegExp(r'\.0$'), '');

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
  List<Map<String, dynamic>> _catatanMaster = [];
  bool _loading = true;
  bool _sendingWa = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
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
      if (!mounted) return;
      setState(() {
        _detail = data['data'] as Map<String, dynamic>?;
        if (_detail != null && _detail!['riwayat'] is List) {
          final List riwayatRaw = List.from(_detail!['riwayat']);
          // Urutkan DESC berdasarkan tanggal
          riwayatRaw.sort((a, b) {
            final dateA =
                DateTime.tryParse(a['tgl_simak']?.toString() ?? '') ??
                DateTime(2000);
            final dateB =
                DateTime.tryParse(b['tgl_simak']?.toString() ?? '') ??
                DateTime(2000);
            return dateB.compareTo(dateA);
          });
          _detail!['riwayat'] = riwayatRaw;
        }

        if (_detail != null && _detail!['catatan_master'] is List) {
          _catatanMaster = (_detail!['catatan_master'] as List)
              .whereType<Map>()
              .map((e) {
                final Map<String, dynamic> safeMap = {};
                e.forEach((k, v) => safeMap[k.toString()] = v);
                return safeMap;
              })
              .toList();
        }
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

  void _tampilkanBottomSheetEdit(
    Map<dynamic, dynamic> item, {
    bool onlyEditDate = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return BottomEdit(
          dataPrestasi: Map<String, dynamic>.from(item),
          onlyEditDate: onlyEditDate,
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


  Future<void> _openWaOrangTua(
    String phoneRaw, {
    String? customMsg,
    String? linkGroup,
  }) async {
    if (phoneRaw.trim().isEmpty || phoneRaw == '-') {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nomor WA tidak tersedia')));
      return;
    }

    String phone = phoneRaw.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) phone = '62${phone.substring(1)}';

    final nama =
        _detail?['santri']?['nama_santri']?.toString() ??
        widget.santri['nama_santri']?.toString() ??
        '-';

    // Bangun pesan
    String pesan =
        customMsg ??
        'Assalamualaikum Wr. Wb., Wali ananda *$nama*. Kami ingin menyampaikan informasi.';
    if (linkGroup != null && linkGroup.isNotEmpty) {
      pesan += '\n\nLink Group WA: $linkGroup';
    }

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(pesan)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
      );
    }
  }

  Widget _waButton(String phone, dynamic customMsg, dynamic linkGroup) {
    if (phone.isEmpty || phone == '-') return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _openWaOrangTua(
        phone,
        customMsg: customMsg?.toString(),
        linkGroup: linkGroup?.toString(),
      ),
      child: Icon(Icons.chat, color: Colors.green, size: 18),
    );
  }

  Future<void> _confirmSendWaReport(String target) async {
    final isParent = target == 'parent';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isParent ? 'Kirim ke Orang Tua?' : 'Kirim ke Saya?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isParent
              ? 'Apakah Anda yakin ingin mengirim laporan perkembangan santri ini ke nomor WhatsApp orang tua?'
              : 'Apakah Anda yakin ingin mengirim laporan perkembangan santri ini ke nomor WhatsApp Anda sendiri?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isParent ? _kAccent : const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Yakin, Kirim',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _sendWaReport(target);
    }
  }

  Widget _buildBottomActions() {
    if (_tabs.index == 0) {
      // Tombol khusus untuk Tab Ringkasan
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _sendingWa
                      ? null
                      : () => _confirmSendWaReport('parent'),
                  child: _sendingWa
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Laporan ke Orang Tua',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _sendingWa
                      ? null
                      : () => _confirmSendWaReport('self'),
                  child: _sendingWa
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Laporan ke Saya',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tombol dihapus sesuai permintaan
    return const SizedBox.shrink();
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'NIS: ${widget.santri['nis'] ?? '-'}',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF22C55E),
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Riwayat'),
            Tab(text: 'Input'),
          ],
        ),
      ),
      body: _loading
          ? const Padding(padding: EdgeInsets.all(16.0), child: SkeletonListWidget(itemCount: 5, itemHeight: 120))
          : _error.isNotEmpty
          ? _buildError()
          : TabBarView(
              controller: _tabs,
              children: [_buildRingkasan(), _buildRiwayat(), _buildInput()],
            ),
      bottomNavigationBar: (_loading || _error.isNotEmpty)
          ? null
          : _buildBottomActions(),
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
            style: TextStyle(color: _kText2),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            onPressed: _load,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Coba Lagi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: Ringkasan -----------------------------------------------------
  Widget _buildRingkasan() {
    final santriRaw = _detail?['santri'];
    final Map<String, dynamic> santri = {};
    if (santriRaw is Map) santriRaw.forEach((k, v) => santri[k.toString()] = v);

    final prediksiRaw = _detail?['prediksi'];
    final Map<String, dynamic> prediksi = {};
    if (prediksiRaw is Map) {
      prediksiRaw.forEach((k, v) => prediksi[k.toString()] = v);
    }

    final masalahList = _detail?['masalah_aktif'] ?? [];
    final masalah = (masalahList is List ? masalahList : [])
        .whereType<Map>()
        .map((e) {
          final Map<dynamic, dynamic> safeMap = {};
          e.forEach((k, v) => safeMap[k] = v);
          return safeMap;
        })
        .toList();

    final rekapRaw = _detail?['rekap_absensi'];
    final Map<String, dynamic> rekapAbsensi = {};
    if (rekapRaw is Map) {
      rekapRaw.forEach((k, v) => rekapAbsensi[k.toString()] = v);
    }

    final weeklyList = _detail?['weekly'] ?? [];
    final weekly = (weeklyList is List ? weeklyList : []).whereType<Map>().map((
      e,
    ) {
      final Map<String, dynamic> safeMap = {};
      e.forEach((k, v) => safeMap[k.toString()] = v);
      return safeMap;
    }).toList();

    return RefreshIndicator(
      color: _kAccent,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAbsensiCard(rekapAbsensi),
          const SizedBox(height: 14),
          _buildProgressCard(
            santri,
            Map<String, dynamic>.from(_detail?['kec'] ?? {}),
            aksHistory: _detail?['aks_history'] is List
                ? _detail!['aks_history']
                : [],
            nextCheckpoint: _detail?['nextCheckpoint'],
          ),
          const SizedBox(height: 14),
          _buildPredictionCard(prediksi, santri),
          const SizedBox(height: 14),
          _buildWeeklyTableCard(weekly),
          const SizedBox(height: 14),
          _buildDataPribadiCard(santri),
          const SizedBox(height: 14),

          _buildMasalahCard(masalah),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDataPribadiCard(Map<String, dynamic> santri) {
    // Format TTL
    final tglLahir = santri['tanggal_lahir']?.toString() ?? '';
    final tmpLahir = santri['tempat_lahir']?.toString() ?? '';
    String ttl = '-';
    if (tglLahir.isNotEmpty) {
      final parts = tglLahir.split('-');
      if (parts.length == 3) {
        const bln = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agt',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        final m = int.tryParse(parts[1]) ?? 0;
        final umur = DateTime.now().year - (int.tryParse(parts[0]) ?? 0);
        ttl =
            '${tmpLahir.isNotEmpty ? "$tmpLahir, " : ""}${parts[2]} ${m > 0 && m < 13 ? bln[m] : parts[1]} ${parts[0]} ($umur th)';
      }
    } else if (tmpLahir.isNotEmpty) {
      ttl = tmpLahir;
    }

    return _section(
      'Data Pribadi & Orang Tua',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data Pribadi
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: _kAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Data Pribadi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _kAccent,
                  ),
                ),
              ],
            ),
          ),
          _infoRow('Nama Santri', santri['nama_santri']?.toString() ?? '-'),
          _infoRow('NIS', santri['nis']?.toString() ?? '-'),
          _infoRow(
            'Kelas/Kelompok',
            '${santri["tingkat"] ?? "-"}  ${santri["nama_kelompok"] ?? "-"}',
          ),
          _infoRow('TTL', ttl),
          _infoRow('Alamat', santri['alamat_lengkap']?.toString() ?? '-'),
          _infoRow('No. HP Santri', santri['no_hp_santri']?.toString() ?? '-'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          // Data Orang Tua
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.family_restroom_rounded,
                  size: 14,
                  color: _kAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Data Orang Tua',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _kAccent,
                  ),
                ),
              ],
            ),
          ),
          _infoRow('Ayah', santri['nama_ayah']?.toString() ?? '-'),
          _infoRow(
            'HP Ayah',
            santri['hp_ayah']?.toString() ?? '-',
            trailing: _waButton(
              santri['hp_ayah']?.toString() ?? '',
              santri['pesanwa'],
              santri['linkgroupwa'],
            ),
          ),
          _infoRow('Ibu', santri['nama_ibu']?.toString() ?? '-'),
          _infoRow(
            'HP Ibu',
            santri['hp_ibu']?.toString() ?? '-',
            trailing: _waButton(
              santri['hp_ibu']?.toString() ?? '',
              santri['pesanwa'],
              santri['linkgroupwa'],
            ),
          ),
          _infoRow(
            'WA Group (${santri["wa_group"] ?? "-"})',
            santri['no_wa_group']?.toString() ?? '-',
            trailing: _waButton(
              santri['no_wa_group']?.toString() ?? '',
              santri['pesanwa'],
              santri['linkgroupwa'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiCard(Map<String, dynamic> rekap) {
    // Data integrasi baru: Hadir, Sakit, Izin, Alpa (T)
    final h = rekap['H']?.toString() ?? '0';
    final s = rekap['S']?.toString() ?? '0';
    final i = rekap['I']?.toString() ?? '0';
    final a = rekap['T']?.toString() ?? '0';

    return _section(
      'Rekapitulasi Absensi Total',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _absensiMetric('Hadir', h, Colors.green),
          _absensiMetric('Sakit', s, Colors.orange),
          _absensiMetric('Izin', i, Colors.blue),
          _absensiMetric('Alpa', a, Colors.red),
        ],
      ),
    );
  }

  Widget _absensiMetric(String label, String value, Color color) {
    return Container(
      width: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Hari',
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    Map<String, dynamic> santri,
    Map<String, dynamic> kec, {
    List<dynamic> aksHistory = const [],
    Map<String, dynamic>? nextCheckpoint,
  }) {
    final double halReg =
        double.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final double totReg =
        double.tryParse(santri['total_hal']?.toString() ?? '604') ?? 604;

    final double halLat =
        double.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;
    final double parsedTotLat =
        double.tryParse(santri['target_latihan']?.toString() ?? '0') ?? 0;
    final double totLat = parsedTotLat > 0 ? parsedTotLat : totReg;

    final double halTot = halReg + halLat;
    final double maxTot = totReg + totLat;
    final double pctTot = maxTot > 0 ? (halTot / maxTot).clamp(0.0, 1.0) : 0.0;

    final double halAks =
        double.tryParse(santri['capai_aks']?.toString() ?? '0') ?? 0;
    final int jmlTes = int.tryParse(santri['jml_tes']?.toString() ?? '0') ?? 0;

    final rasioTotal = kec['rasioTotal'] ?? 0;
    final int cntLulus = int.tryParse(kec['cntLulus']?.toString() ?? '0') ?? 0;
    final double kecAktTotal =
        double.tryParse(kec['kecAktTotal']?.toString() ?? '0') ?? 0.0;
    final double kecBakuTotal =
        double.tryParse(kec['kecBakuTotal']?.toString() ?? '0') ?? 0.0;

    bool isSelesai =
        pctTot >= 1.0 ||
        (santri['status']?.toString().toLowerCase().contains('khotam') ??
            false) ||
        (santri['status']?.toString().toLowerCase().contains('siap test') ??
            false);

    bool hasCepat = cntLulus >= 3 && kecAktTotal > 0 && kecBakuTotal > 0;

    String kLabel = 'BELUM TERUKUR';
    Color kColor = Colors.grey.shade600;

    if (isSelesai) {
      kLabel = 'Siap Test / Khotam';
      kColor = Colors.green;
    } else if (hasCepat) {
      if (rasioTotal >= 140) {
        kLabel = 'SANGAT CEPAT';
        kColor = Colors.green;
      } else if (rasioTotal >= 110) {
        kLabel = 'CEPAT';
        kColor = Colors.green;
      } else if (rasioTotal >= 102) {
        kLabel = 'SEDIKIT CEPAT';
        kColor = Colors.lightBlue;
      } else if (rasioTotal >= 99) {
        kLabel = 'STANDAR';
        kColor = Colors.blue;
      } else if (rasioTotal >= 90) {
        kLabel = 'SEDIKIT LAMBAT';
        kColor = Colors.orange;
      } else if (rasioTotal >= 70) {
        kLabel = 'LAMBAT';
        kColor = Colors.orange;
      } else {
        kLabel = 'SANGAT LAMBAT';
        kColor = Colors.red;
      }
    }

    return _section(
      'Progres Khotaman & Kecepatan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Pencapaian: ${_f(halReg)} Hal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _kText1,
                    ),
                  ),
                  if (!hasCepat)
                    Text(
                      '(Butuh min. 3 sesi lulus)',
                      style: TextStyle(
                        fontSize: 10,
                        color: _kText2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          MultiSegmentProgressBar(
            title: 'Progres Jilid',
            icon: Icons.menu_book_rounded,
            capai: halReg,
            total: totReg,
            checkpoints:
                widget.santri['checkpoints'] ??
                widget.santri['checkpoint'] ??
                widget.santri['t_kelas_checkpoint'] ??
                widget.santri['check_points'],
            baseColor: const Color(0xFF6610F2),
          ),
          if (totLat > 0) ...[
            const SizedBox(height: 12),
            MultiSegmentProgressBar(
              title: 'Progres Latihan',
              icon: Icons.edit_note_rounded,
              capai: halLat,
              total: totLat,
              checkpoints:
                  widget.santri['checkpoints'] ??
                  widget.santri['checkpoint'] ??
                  widget.santri['t_kelas_checkpoint'] ??
                  widget.santri['check_points'],
              baseColor: const Color(0xFF14B8A6),
            ),
          ],
          if (nextCheckpoint != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: Colors.orange.shade800,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkpoint: Halaman ${nextCheckpoint["halaman_target"]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextCheckpoint['keterangan'] ?? 'Mid-Test',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (aksHistory.isNotEmpty) ...[
            for (var item in aksHistory) ...[
              Builder(
                builder: (context) {
                  final int sCycle =
                      int.tryParse(item['jml_tes']?.toString() ?? '0') ?? 0;
                  final double sHal =
                      double.tryParse(item['hal_aks']?.toString() ?? '0') ?? 0;

                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      MultiSegmentProgressBar(
                        title: 'Akselerasi $sCycle',
                        icon: Icons.rocket_launch_rounded,
                        capai: sHal,
                        total: totReg,
                        baseColor: const Color(0xFFEA5455),
                      ),
                    ],
                  );
                },
              ),
            ],
          ] else if (jmlTes > 0) ...[
            const SizedBox(height: 12),
            MultiSegmentProgressBar(
              title: 'Akselerasi $jmlTes',
              icon: Icons.rocket_launch_rounded,
              capai: halAks,
              total: totReg,
              baseColor: const Color(0xFFEA5455),
            ),
          ],
          const Divider(height: 30),
          _speedRow(
            'Mode Reguler',
            kec['rasioReg'],
            kec['kecAktReg'],
            kec['kecBakuReg'],
          ),
          _speedRow(
            'Rata-rata Keseluruhan',
            kec['rasioTotal'],
            kec['kecAktTotal'],
            kec['kecBakuTotal'],
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    Map<String, dynamic> prediksi,
    Map<String, dynamic> santri,
  ) {
    final double totReg =
        double.tryParse(santri['total_hal']?.toString() ?? '604') ?? 604;
    final double parsedTotLat =
        double.tryParse(santri['target_latihan']?.toString() ?? '0') ?? 0;
    final double totLat = parsedTotLat > 0 ? parsedTotLat : totReg;
    final bool isSelesai =
        (santri['status']?.toString().toLowerCase().contains('khotam') ??
            false) ||
        (santri['status']?.toString().toLowerCase().contains('siap test') ??
            false);

    if (isSelesai) {
      return _section(
        'Prediksi Khatam',
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Santri telah menyelesaikan seluruh target jilid ini.',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (prediksi['tersedia'] != true) {
      return _section(
        'Prediksi Khatam',
        child: Text(
          prediksi['pesan']?.toString() ?? 'Belum ada data prediksi.',
          style: TextStyle(color: _kText2),
        ),
      );
    }

    final int selisih =
        int.tryParse(prediksi['selisih_hari']?.toString() ?? '0') ?? 0;

    return _section(
      'Prediksi Khatam',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Lembaga',
            style: TextStyle(
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
            style: TextStyle(
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _kText1,
                ),
              ),
              Text(
                '$selisih Sesi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: selisih > 0 ? Colors.red.shade600 : _kAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTableCard(List<Map<String, dynamic>> weekly) {
    double sumLulus = 0;
    double sumUlang = 0;
    double sumTotal = 0;
    int sumH = 0;
    int sumI = 0;
    int sumS = 0;
    int sumA = 0;

    for (var w in weekly) {
      final abs = w['absensi'] ?? {};
      sumH += int.tryParse(abs['H']?.toString() ?? '0') ?? 0;
      sumI += int.tryParse(abs['I']?.toString() ?? '0') ?? 0;
      sumS += int.tryParse(abs['S']?.toString() ?? '0') ?? 0;
      sumA +=
          int.tryParse(abs['T']?.toString() ?? '0') ??
          0; // T is used for Alpa in some contexts here

      final modes = (w['modes'] is Map) ? (w['modes'] as Map) : {};
      modes.forEach((_, m) {
        final halLulus =
            double.tryParse(m['hal_lulus']?.toString() ?? '0') ?? 0;
        final halUlang =
            double.tryParse(m['hal_ulang']?.toString() ?? '0') ?? 0;
        sumLulus += halLulus;
        sumUlang += halUlang;
        sumTotal += (halLulus + halUlang);
      });
    }

    return _section(
      'Perkembangan Mingguan',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 60,
          columnSpacing: 16,
          horizontalMargin: 0,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(
              label: Text(
                'Periode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Mode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Setoran\n(L/U/T)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Absen\n(H/I/S/A)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
          rows: [
            if (weekly.isEmpty)
              const DataRow(
                cells: [
                  DataCell(
                    Text(
                      'Belum ada data',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ],
              )
            else ...[
              ...weekly
                  .map((w) {
                    final abs = w['absensi'] ?? {};
                    final modes = (w['modes'] is Map)
                        ? (w['modes'] as Map)
                        : {};

                    List<DataRow> subRows = [];
                    if (modes.isEmpty) {
                      subRows.add(
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                w['label'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataCell(
                              const Text(
                                'No Data',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            DataCell(const Text('-')),
                            DataCell(
                              Text(
                                '${abs['H']}/${abs['I']}/${abs['S']}/${abs['T']}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      bool firstMode = true;
                      modes.forEach((modeName, m) {
                        final halLulus = m['hal_lulus'] ?? 0;
                        final halUlang = m['hal_ulang'] ?? 0;
                        final total = halLulus + halUlang;

                        subRows.add(
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  firstMode ? (w['label'] ?? '-') : '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        modeName
                                            .toString()
                                            .toLowerCase()
                                            .contains('akselerasi')
                                        ? Colors.red.shade50
                                        : (modeName.toString().toLowerCase() ==
                                                  'reguler'
                                              ? Colors.blue.shade50
                                              : Colors.teal.shade50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    modeName.toString().toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          modeName
                                              .toString()
                                              .toLowerCase()
                                              .contains('akselerasi')
                                          ? Colors.red.shade700
                                          : (modeName
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'reguler'
                                                ? Colors.blue.shade700
                                                : Colors.teal.shade700),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${_f(halLulus)}/${_f(halUlang)}/${_f(total)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              DataCell(
                                Text(
                                  firstMode
                                      ? '${abs['H']}/${abs['I']}/${abs['S']}/${abs['T']}'
                                      : '',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                        firstMode = false;
                      });
                    }
                    return subRows;
                  })
                  .expand((e) => e),
              // TOTAL ROW
              DataRow(
                color: WidgetStateProperty.all(
                  Colors.green.withValues(alpha: 0.05),
                ),
                cells: [
                  const DataCell(
                    Text(
                      'TOTAL AKUMULASI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const DataCell(
                    Text(
                      'PERIODE INI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${_f(sumLulus)}/${_f(sumUlang)}/${_f(sumTotal)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '$sumH/$sumI/$sumS/$sumA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMasalahCard(List<Map<dynamic, dynamic>> masalah) {
    return _section(
      'Masalah Aktif',
      child: masalah.isEmpty
          ? Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: _kAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tidak ada masalah yang aktif',
                  style: TextStyle(color: _kAccent),
                ),
              ],
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.red.shade700,
                              ),
                            ),
                            if ((m['deskripsi']?.toString() ?? '').isNotEmpty)
                              Text(
                                m['deskripsi']!.toString(),
                                style: TextStyle(fontSize: 12, color: _kText2),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Future<void> _sendWaReport(String target) async {
    setState(() => _sendingWa = true);
    try {
      final nis = widget.santri['nis']?.toString() ?? '';
      final res = await ApiService.sendWaReport(nis: nis, target: target);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim laporan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingWa = false);
    }
  }

  Widget _speedRow(
    String label,
    dynamic rasio,
    dynamic aktual,
    dynamic baku, {
    bool isBold = false,
  }) {
    final double vAct = double.tryParse(aktual?.toString() ?? '0') ?? 0;
    final double vBak = double.tryParse(baku?.toString() ?? '0') ?? 0;
    final double vPct = double.tryParse(rasio?.toString() ?? '0') ?? 0;

    String act = _f(double.parse(vAct.toStringAsFixed(2)));
    String bak = _f(double.parse(vBak.toStringAsFixed(2)));
    String pct = _f(double.parse(vPct.toStringAsFixed(1)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isBold ? _kText1 : _kText2,
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (!isBold)
                  Text(
                    'Target: $bak Hal/Sesi',
                    style: TextStyle(fontSize: 10, color: _kText2),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    act,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _kText1,
                    ),
                  ),
                  Text(
                    ' / $bak Hal/Sesi',
                    style: TextStyle(fontSize: 11, color: _kText2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
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
          Text('> $label', style: TextStyle(color: _kText2, fontSize: 12)),
          Text(
            '${tgl ?? '-'} (${hari ?? 0} Sesi)',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              color: highlight ? _kAccent : _kText1,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: Riwayat -------------------------------------------------------
  Widget _buildRiwayat() {
    final rawRiwayat = _detail?['riwayat'];
    final rawList = rawRiwayat is List ? rawRiwayat : [];
    final List<Map<String, dynamic>> riwayat = rawList
        .whereType<Map<String, dynamic>>()
        .toList();

    if (riwayat.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Belum ada riwayat simakan', style: TextStyle(color: _kText2)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: riwayat.length,
      itemBuilder: (context, i) {
        final r = riwayat[i];

        String tglDisplay = '-';
        String jamDisplay = '';
        final rawTgl = r['tgl_simak']?.toString();
        if (rawTgl != null && rawTgl.isNotEmpty && rawTgl != 'null') {
          final dt = DateTime.tryParse(rawTgl);
          if (dt != null) {
            tglDisplay = DateFormat('dd MMM yyyy').format(dt);
            if (rawTgl.contains(':')) {
              jamDisplay = DateFormat('HH:mm').format(dt);
            }
          }
        }

        final status = r['status']?.toString().toLowerCase() ?? '';
        final isLulus = status == 'lulus';

        final int jmlTesItem =
            int.tryParse(r['jml_tes']?.toString() ?? '0') ?? 0;
        String modeStr = r['mode_belajar']?.toString().toUpperCase() ?? '-';
        if (modeStr == 'AKSELERASI' && jmlTesItem > 0) {
          modeStr = 'AKSELERASI $jmlTesItem';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal & Waktu di kiri
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tglDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          if (jamDisplay.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              jamDisplay,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mode Belajar & Badge Lulus/Mengulang
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: modeStr.contains('AKSELERASI')
                                      ? Colors.red.shade50
                                      : (modeStr.contains('REGULER')
                                            ? Colors.blue.shade50
                                            : Colors.teal.shade50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  modeStr,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: modeStr.contains('AKSELERASI')
                                        ? Colors.red.shade700
                                        : (modeStr.contains('REGULER')
                                              ? Colors.blue.shade700
                                              : Colors.teal.shade700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isLulus
                                      ? _kAccent.withAlpha(25)
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isLulus ? 'LULUS' : 'MENGULANG',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isLulus
                                        ? _kAccent
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Detail Halaman
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 14,
                                color: Colors.indigo.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${r['halaman'] ?? 0} Halaman',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _kText1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const SizedBox(width: 18),
                              Text(
                                '(Hal. ${r['hal_awal'] ?? 0} s/d ${r['hal_akhir'] ?? 0})',
                                style: TextStyle(fontSize: 11, color: _kText2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Detail TM
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                size: 14,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tatap Muka: ${r['jml_kehadiran'] ?? 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _kText2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tombol Edit & Hapus (Vertikal di pojok kanan)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Tombol Edit
                        IconButton(
                          onPressed: () => _tampilkanBottomSheetEdit(
                            r,
                            onlyEditDate: i != 0,
                          ),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Edit Riwayat',
                        ),
                        // Tombol Hapus
                        IconButton(
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
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Hapus Riwayat',
                        ),
                      ],
                    ),
                  ],
                ),

                // Catatan
                if ((r['catatan']?.toString() ?? '').isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          r['catatan'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TAB 3: Form Input Cepat ----------------------------------------------
  Widget _buildInput() {
    final santri = Map<String, dynamic>.from(_detail?['santri'] ?? {});
    double capaiHal =
        double.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    double totalHal =
        double.tryParse(santri['total_hal']?.toString() ?? '0') ?? 0;
    double latSek = double.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;

    final int jmlTes = int.tryParse(santri['jml_tes']?.toString() ?? '0') ?? 0;
    final double capaiAks =
        double.tryParse(santri['capai_aks']?.toString() ?? '0') ?? 0;
    // âš ï¸ Sesuai backend: isAkselerasi jika jml_tes>0 ATAU sudah ada capai_aks>0
    final bool isAkselerasi = jmlTes > 0 || capaiAks > 0;
    final int jmlGagalBerturut =
        int.tryParse(santri['jml_gagal_berturut']?.toString() ?? '0') ?? 0;

    bool isLatihan = !isAkselerasi && (capaiHal >= totalHal) && (totalHal > 0);
    double halAwalBenar = isAkselerasi
        ? capaiAks
        : (isLatihan ? latSek : capaiHal);

    final nextCP = _detail?['nextCheckpoint'];
    final double cpTarget = nextCP != null
        ? (double.tryParse(nextCP['halaman_target']?.toString() ?? '0') ?? 0)
        : 0.0;

    final bool isFinishedReg = (totalHal > 0 && capaiHal >= totalHal);
    final double currentLimit = isFinishedReg
        ? totalHal
        : (cpTarget > 0 ? cpTarget : totalHal);
    final bool isAtCP =
        (!isFinishedReg && cpTarget > 0 && capaiHal >= cpTarget);
    final bool latihanSelesai = (latSek >= currentLimit && currentLimit > 0);
    final bool aksSelesai = (totalHal > 0 && capaiAks >= totalHal);

    bool isTerkunci = false;
    String alasanKunci = '';

    if (isAkselerasi) {
      if (aksSelesai) {
        isTerkunci = true;
        alasanKunci = 'Buku Akselerasi telah selesai.';
      }
    } else if (isLatihan || isAtCP) {
      if (latihanSelesai) {
        isTerkunci = true;
        alasanKunci = isFinishedReg
            ? 'Buku Reguler dan target Latihan tercapai.'
            : 'Target Checkpoint dan Latihan tercapai.';
      }
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: _kAccent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // -- Banner Streak Tidak Lulus --------------------------------
            if (jmlGagalBerturut > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade300, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_down_rounded,
                        color: Colors.red.shade700,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$jmlGagalBerturutÃ— Tidak Lulus Berturut-turut',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Santri ini belum berhasil lulus dalam $jmlGagalBerturut sesi terakhir secara berurutan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // -- Form Input ------------------------------------------------
            DetailInputFormWidget(
              nis: widget.santri['nis']?.toString() ?? '',
              initialHalAwal: halAwalBenar,
              isLatihan: isLatihan || isAtCP,
              isAkselerasi: isAkselerasi,
              jmlTes: jmlTes,
              isTerkunci: isTerkunci,
              alasanKunci: alasanKunci,
              jmlGagalBerturut: jmlGagalBerturut,
              catatanMaster: _catatanMaster,
              kelasSettings:
                  _detail?['kelas_settings'] as Map<String, dynamic>? ?? {},
              metodeList:
                  (_detail?['metode_list'] as List?)
                      ?.whereType<Map>()
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList() ??
                  [],
              idKelas: int.tryParse(santri['id_kelas']?.toString() ?? '0') ?? 0,
              onSuccess: _load,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kHeader.withAlpha(15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _kHeader,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _kText2, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _kText1,
                    ),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
