import 'widgets/detail_input_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/shared/widgets/multi_segment_progress_bar.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bottom_edit.dart';

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
  late final TahsinRepository _repository;

  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _catatanMaster = [];
  bool _loading = true;
  bool _sendingWa = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _repository = TahsinRepository(
      networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
    );
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

  Future<void> _load({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final nis = widget.santri['nis']?.toString() ?? '';
      final data = await _repository.getProgressDetail(
        nis,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;
      setState(() {
        _detail = data['data'] ?? data;
        if (_detail != null && _detail!['riwayat'] is List) {
          final List riwayatRaw = List.from(_detail!['riwayat']);
          riwayatRaw.sort((a, b) {
            final dateA =
                DateTime.tryParse(
                  a['tgl_simak']?.toString() ?? a['tanggal']?.toString() ?? '',
                ) ??
                DateTime(2000);
            final dateB =
                DateTime.tryParse(
                  b['tgl_simak']?.toString() ?? b['tanggal']?.toString() ?? '',
                ) ??
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
                await ApiService.deleteProgress(idPrestasi);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil dihapus")),
                );
                _load(forceRefresh: true);
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
      builder: (sheetCtx) => BottomEdit(
        dataPrestasi: Map<String, dynamic>.from(item),
        onlyEditDate: onlyEditDate,
        onSave: (updatedItem) async {
          setState(() => _loading = true);
          try {
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
            _load(forceRefresh: true);
          } catch (e) {
            if (!mounted) return;
            setState(() => _loading = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Gagal memperbarui: $e")));
          }
        },
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
          backgroundColor: const Color(0xFF22C55E),
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
              ? 'Kirim laporan perkembangan santri ke WhatsApp orang tua?'
              : 'Kirim laporan perkembangan santri ke WhatsApp Anda?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isParent
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF0284C7),
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
    if (confirm == true) _sendWaReport(target);
  }

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<AppCustomStyles>();
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Stack(
          children: [
            const Positioned.fill(child: GlobalHeaderBackground()),
            AppBar(
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: onPrimary,
              iconTheme: IconThemeData(color: onPrimary),
              centerTitle: false,
              title: Text(
              _tabs.index == 0
                  ? 'Detail Santri | ${widget.santri["nama_santri"] ?? ""}'
                  : (_tabs.index == 1 ? 'Riwayat Simakan' : 'Input Simakan'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              actions: [
                if (!_loading)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => _load(forceRefresh: true),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: _loading
          ? _buildShimmerLoading(styles)
          : _error.isNotEmpty
          ? _buildError()
          : TabBarView(
              controller: _tabs,
              children: [
                _RingkasanTab(
                  detail: _detail,
                  repository: _repository,
                  onLoad: _load,
                  onSendWa: _confirmSendWaReport,
                  sendingWa: _sendingWa,
                ),
                _RiwayatTab(
                  riwayat: _detail?['riwayat'] ?? [],
                  onEdit: _tampilkanBottomSheetEdit,
                  onDelete: _hapusData,
                ),
                _InputTab(
                  detail: _detail,
                  santri: widget.santri,
                  catatanMaster: _catatanMaster,
                  onSuccess: () => _load(forceRefresh: true),
                ),
              ],
            ),
      bottomNavigationBar: (_loading || _error.isNotEmpty)
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: styles?.headerBorder ?? Colors.transparent,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _tabs.index,
                onTap: (i) => _tabs.animateTo(i),
                backgroundColor: bgColor,
                selectedItemColor: const Color(0xFF22C55E),
                unselectedItemColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined),
                    activeIcon: Icon(Icons.analytics),
                    label: 'Ringkasan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history),
                    label: 'Riwayat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.edit_note_outlined),
                    activeIcon: Icon(Icons.edit_note),
                    label: 'Input',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerLoading(AppCustomStyles? styles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: styles?.shimmerBase ?? Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: styles?.cardBorder ?? Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _load(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingkasanTab extends StatefulWidget {
  final Map<String, dynamic>? detail;
  final TahsinRepository repository;
  final Future<void> Function({bool forceRefresh}) onLoad;
  final Function(String) onSendWa;
  final bool sendingWa;

  const _RingkasanTab({
    required this.detail,
    required this.repository,
    required this.onLoad,
    required this.onSendWa,
    required this.sendingWa,
  });

  @override
  State<_RingkasanTab> createState() => _RingkasanTabState();
}

class _RingkasanTabState extends State<_RingkasanTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final styles = Theme.of(context).extension<AppCustomStyles>();
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;

    final santriRaw = widget.detail?['santri'];
    final Map<String, dynamic> santri = {};
    if (santriRaw is Map) santriRaw.forEach((k, v) => santri[k.toString()] = v);

    final prediksiRaw = widget.detail?['prediksi'];
    final Map<String, dynamic> prediksi = {};
    if (prediksiRaw is Map) {
      prediksiRaw.forEach((k, v) => prediksi[k.toString()] = v);
    }
    final prediksiPerJilidRaw = widget.detail?['prediksi_per_jilid'];
    final Map<String, dynamic> prediksiPerJilid = {};
    if (prediksiPerJilidRaw is Map) {
      prediksiPerJilidRaw.forEach((k, v) => prediksiPerJilid[k.toString()] = v);
    }
    final masalahList = widget.detail?['masalah_aktif'] ?? [];
    final masalah = (masalahList is List ? masalahList : [])
        .whereType<Map>()
        .toList();

    final rekapRaw = widget.detail?['rekap_absensi'];
    final Map<String, dynamic> rekapAbsensi = {};
    if (rekapRaw is Map) {
      rekapRaw.forEach((k, v) => rekapAbsensi[k.toString()] = v);
    }

    final weeklyList = widget.detail?['weekly'] ?? [];
    final weekly = (weeklyList is List ? weeklyList : [])
        .whereType<Map>()
        .toList();

    return RefreshIndicator(
      color: const Color(0xFF22C55E),
      onRefresh: () => widget.onLoad(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAbsensiCard(context, rekapAbsensi, styles),
          const SizedBox(height: 14),
          _buildProgressCard(
            context,
            santri,
            Map<String, dynamic>.from(widget.detail?['kec'] ?? {}),
            styles,
          ),
          const SizedBox(height: 14),
          _buildPredictionCard(
            context,
            prediksi,
            prediksiPerJilid,
            styles,
            int.tryParse(santri['id_kelas']?.toString() ?? '0'),
          ),
          const SizedBox(height: 14),
          _buildWeeklyTableCard(context, weekly, styles),
          const SizedBox(height: 14),
          _buildDataPribadiCard(context, santri, styles, onSurfaceVar),
          const SizedBox(height: 14),
          _buildMasalahCard(context, masalah, styles),
          const SizedBox(height: 14),
          _buildWaReportButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWaReportButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.sendingWa
                ? null
                : () => widget.onSendWa('parent'),
            icon: widget.sendingWa
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: const Text('Kirim Laporan ke Orang Tua'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: widget.sendingWa ? null : () => widget.onSendWa('self'),
            icon: const Icon(Icons.person_outline, size: 18),
            label: const Text('Kirim ke Saya Sendiri'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0284C7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataPribadiCard(
    BuildContext context,
    Map<String, dynamic> santri,
    AppCustomStyles? styles,
    Color onSurfaceVar,
  ) {
    final ttl = [
      santri['tempat_lahir']?.toString(),
      santri['tgl_lahir']?.toString(),
    ].where((v) => v != null && v.isNotEmpty).join(', ');
    final umur = santri['umur']?.toString() ?? '';
    final ttlFull = ttl.isNotEmpty
        ? '$ttl${umur.isNotEmpty ? ' ($umur th)' : ''}'
        : '-';
    final noHpSantri =
        santri['no_hp_santri']?.toString() ??
        santri['no_hp']?.toString() ??
        '-';
    final hpAyah =
        santri['hp_ayah']?.toString() ??
        santri['no_hp_ayah']?.toString() ??
        '-';
    final hpIbu =
        santri['hp_ibu']?.toString() ?? santri['no_hp_ibu']?.toString() ?? '-';
    final waGroup =
        santri['wa_group']?.toString() ??
        santri['wa_group_ibu']?.toString() ??
        '-';
    final noWaGroup = santri['no_wa_group']?.toString() ?? '-';

    Future<void> openWhatsAppGroup(String no) async {
      if (no.isEmpty || no == '-') return;
      String cleanNo = no.replaceAll(RegExp(r'\D'), '');
      if (cleanNo.startsWith('0')) cleanNo = '62${cleanNo.substring(1)}';
      if (cleanNo.startsWith('8')) cleanNo = '62$cleanNo';

      final pesan = santri['pesanwa']?.toString() ?? '';
      final link = santri['linkgroupwa']?.toString() ?? '';

      final text = "$pesan\n$link".trim();
      
      final waScheme = Uri.parse(
        "whatsapp://send?phone=$cleanNo&text=${Uri.encodeComponent(text)}",
      );
      
      final webScheme = Uri.parse(
        "https://wa.me/$cleanNo?text=${Uri.encodeComponent(text)}",
      );

      if (await canLaunchUrl(waScheme)) {
        await launchUrl(waScheme, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webScheme)) {
        await launchUrl(webScheme, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
          );
        }
      }
    }

    return _SectionWidget(
      title: 'Data Pribadi & Orang Tua',
      styles: styles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Data Pribadi subsection
          _SubSectionHeader(
            icon: Icons.person_outline_rounded,
            label: 'Data Pribadi',
          ),
          const SizedBox(height: 8),
          _InfoRowWidget(
            label: 'Nama Santri',
            value: santri['nama_santri']?.toString() ?? '-',
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'NIS',
            value: santri['nis']?.toString() ?? '-',
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'Kelas/Kelompok',
            value:
                '${santri["tingkat"] ?? "-"} ${santri["nama_kelompok"] ?? "-"}',
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'TTL',
            value: ttlFull,
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'Alamat',
            value: santri['alamat']?.toString() ?? '-',
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'No. HP Santri',
            value: noHpSantri,
            onSurfaceVar: onSurfaceVar,
            onWaTap: () => openWhatsAppGroup(noHpSantri),
          ),
          const SizedBox(height: 14),
          // — Data Orang Tua subsection
          _SubSectionHeader(
            icon: Icons.family_restroom_rounded,
            label: 'Data Orang Tua',
          ),
          const SizedBox(height: 8),
          _InfoRowWidget(
            label: 'Ayah',
            value: santri['nama_ayah']?.toString() ?? '-',
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'HP Ayah',
            value: hpAyah,
            onSurfaceVar: onSurfaceVar,
            onWaTap: () => openWhatsAppGroup(hpAyah),
          ),
          _InfoRowWidget(
            label: 'Ibu',
            value: santri['nama_ibu']?.toString() ?? '-',
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'HP Ibu',
            value: hpIbu,
            onSurfaceVar: onSurfaceVar,
            onWaTap: () => openWhatsAppGroup(hpIbu),
          ),
          _InfoRowWidget(
            label: 'WA Group (Nama)',
            value: waGroup,
            onSurfaceVar: onSurfaceVar,
          ),
          _InfoRowWidget(
            label: 'No. WA Group',
            value: noWaGroup,
            onSurfaceVar: onSurfaceVar,
            onWaTap: () => openWhatsAppGroup(noWaGroup),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiCard(
    BuildContext context,
    Map<String, dynamic> rekap,
    AppCustomStyles? styles,
  ) {
    return _SectionWidget(
      title: 'Rekapitulasi Absensi Total',
      styles: styles,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _absensiMetric('Hadir', rekap['H']?.toString() ?? '0', Colors.green),
          _absensiMetric('Sakit', rekap['S']?.toString() ?? '0', Colors.orange),
          _absensiMetric('Izin', rekap['I']?.toString() ?? '0', Colors.blue),
          _absensiMetric('Alpa', rekap['T']?.toString() ?? '0', Colors.red),
        ],
      ),
    );
  }

  Widget _absensiMetric(String label, String value, Color color) {
    return Container(
      width: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1)),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    Map<String, dynamic> santri,
    Map<String, dynamic> kec,
    AppCustomStyles? styles,
  ) {
    final double halReg =
        double.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final double totReg =
        double.tryParse(santri['total_hal']?.toString() ?? '604') ?? 604;
    final double halMulai =
        double.tryParse(santri['hal_mulai']?.toString() ?? '1') ?? 1;
    final double baseHal = (halMulai > 0) ? halMulai - 1 : 0;
    final double halLat =
        double.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;
    final double totLat = halLat > 0 ? totReg : 0;
    final onSurf = Theme.of(context).colorScheme.onSurfaceVariant;

    return _SectionWidget(
      title: 'Progres Khotaman & Kecepatan',
      styles: styles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                'Total Pencapaian: ',
                style: TextStyle(fontSize: 11, color: onSurf),
              ),
              Text(
                '${_f(halReg)} Hal',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MultiSegmentProgressBar(
            title: 'Progres Jilid',
            icon: Icons.menu_book_rounded,
            capai: halReg,
            total: totReg,
            baseHal: baseHal,
            checkpoints: santri['checkpoints'],
            baseColor: const Color(0xFF6366F1),
          ),
          if (halLat > 0) ...[
            const SizedBox(height: 12),
            MultiSegmentProgressBar(
              title: 'Progres Latihan',
              icon: Icons.edit_note_rounded,
              capai: halLat,
              total: totLat,
              baseHal: baseHal,
              checkpoints: santri['checkpoints'],
              baseColor: const Color(0xFF14B8A6),
            ),
          ],
          const SizedBox(height: 12),
          // Checkpoint info
          if (widget.detail?['nextCheckpoint'] != null) ...[
            _checkpointRow(widget.detail!['nextCheckpoint']),
            const SizedBox(height: 8),
          ],
          const Divider(height: 20),
          _kecRow(
            'Mode Reguler',
            kec['kecBakuTotal'],
            kec['rasioReg'] ?? kec['rasioTotal'],
            onSurf,
          ),
          const SizedBox(height: 6),
          _kecRow(
            'Rata-rata Keseluruhan',
            kec['kecAktTotal'],
            kec['rasioTotal'],
            onSurf,
          ),
        ],
      ),
    );
  }

  Widget _checkpointRow(dynamic cp) {
    final hal = cp is Map ? (cp['halaman'] ?? cp['hal'] ?? '-') : '-';
    final ayat = cp is Map ? (cp['ayat'] ?? cp['nama'] ?? '-') : '-';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag_circle_rounded,
            color: Color(0xFF22C55E),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Checkpoint: Halaman $hal',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$ayat',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kecRow(String label, dynamic kecVal, dynamic rasio, Color onSurf) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: onSurf)),
        const Spacer(),
        Text(
          '${_f(kecVal)} ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text('hal/sesi', style: TextStyle(fontSize: 10, color: onSurf)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${_f(rasio)}%',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF22C55E),
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildPredictionCard(
    BuildContext context,
    Map<String, dynamic> p,
    Map<String, dynamic> pj,
    AppCustomStyles? styles,
    int? idKelasSantri,
  ) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final tersedia = p['tersedia'] == true;
    final selisih = p['selisih_hari'];

    if (!tersedia || pj.isEmpty) {
      return _SectionWidget(
        title: 'Prediksi Selesai Kelas',
        styles: styles,
        child: const Text(
          'Data belum cukup untuk membuat prediksi.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      );
    }

    List perJilid = pj['per_jilid'] is List ? pj['per_jilid'] : [];
    if (idKelasSantri != null && idKelasSantri > 0) {
      perJilid = perJilid.where((e) {
        if (e is Map) {
          final idK = int.tryParse(e['id_kelas']?.toString() ?? '0') ?? 0;
          return idK == idKelasSantri;
        }
        return true;
      }).toList();
    }

    return _SectionWidget(
      title: 'Prediksi Selesai Kelas',
      styles: styles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prediksi Aktual', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${pj['tgl_khotaman_aktual'] ?? '-'}', style: TextStyle(color: onSurf, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${pj['total_tm_aktual'] ?? 0} TM Aktual', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Target Lembaga', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${pj['tgl_khotaman_baku'] ?? '-'}', style: TextStyle(color: onSurf, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${pj['total_tm_baku'] ?? 0} TM Target', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          if (selisih != null && selisih != 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: (selisih < 0 ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(selisih < 0 ? Icons.trending_up : Icons.trending_down, size: 16, color: selisih < 0 ? Colors.green : Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selisih < 0 ? 'Lebih cepat ${selisih.abs()} sesi dari target' : 'Lebih lambat $selisih sesi dari target',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selisih < 0 ? Colors.green : Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Rincian per Jilid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 35,
              dataRowMinHeight: 35,
              dataRowMaxHeight: 45,
              horizontalMargin: 0,
              columnSpacing: 25,
              columns: [
                DataColumn(label: Text('Jilid/Buku', style: TextStyle(fontSize: 12, color: onSurf))),
                DataColumn(label: Text('Target', style: TextStyle(fontSize: 12, color: onSurf))),
                DataColumn(label: Text('Aktual', style: TextStyle(fontSize: 12, color: onSurf))),
              ],
              rows: perJilid.map((item) {
                return DataRow(cells: [
                  DataCell(Text('${item['tingkat'] ?? '-'}', style: TextStyle(fontSize: 12, color: onSurf))),
                  DataCell(Text('${item['tgl_baku'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  DataCell(Text('${item['tgl_aktual'] ?? '-'}', style: TextStyle(fontSize: 12, color: onSurf, fontWeight: FontWeight.w600))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Color _modeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'reguler':
        return const Color(0xFF22C55E);
      case 'latihan':
        return const Color(0xFF6366F1);
      case 'akselerasi':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF0EA5E9);
    }
  }

  Widget _buildWeeklyTableCard(
    BuildContext context,
    List<Map<dynamic, dynamic>> weekly,
    AppCustomStyles? styles,
  ) {
    if (weekly.isEmpty) return const SizedBox.shrink();

    final onSurf = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfHigh = Theme.of(context).colorScheme.surfaceContainerHighest;

    // Accumulate totals
    int totalL = 0, totalU = 0, totalSim = 0;
    int totalH = 0, totalS = 0, totalI = 0, totalAlpa = 0;

    // Build row data: (periode, modeName, simakanStr, absensiStr, modeColor, isFirstMode)
    final List<(String, String, String, String, Color, bool)> rows = [];

    for (final e in weekly) {
      final label = e['label']?.toString() ?? '-';
      final absensiRaw = e['absensi'];
      final modesRaw = e['modes'];
      final Map<String, dynamic> modes = {};
      if (modesRaw is Map) modesRaw.forEach((k, v) => modes[k.toString()] = v);

      // Parse absensi
      String absensiStr = '-';
      if (absensiRaw is Map) {
        final h =
            int.tryParse(
              (absensiRaw['H'] ?? absensiRaw['h'] ?? 0).toString(),
            ) ??
            0;
        final s =
            int.tryParse(
              (absensiRaw['S'] ?? absensiRaw['s'] ?? 0).toString(),
            ) ??
            0;
        final i =
            int.tryParse(
              (absensiRaw['I'] ?? absensiRaw['i'] ?? 0).toString(),
            ) ??
            0;
        final t =
            int.tryParse(
              (absensiRaw['T'] ?? absensiRaw['t'] ?? absensiRaw['A'] ?? 0)
                  .toString(),
            ) ??
            0;
        absensiStr = '$h/$s/$i/$t';
        totalH += h;
        totalS += s;
        totalI += i;
        totalAlpa += t;
      } else if (absensiRaw is String &&
          absensiRaw.isNotEmpty &&
          absensiRaw != '-') {
        absensiStr = absensiRaw;
      }

      bool isFirst = true;
      if (modes.isEmpty) {
        rows.add((label, '-', '-', absensiStr, Colors.grey, true));
      } else {
        for (final entry in modes.entries) {
          final modeData = entry.value;
          String simStr = '-';
          if (modeData is Map) {
            final lRaw = modeData['hal_lulus'] ?? modeData['L'] ?? modeData['lulus'] ?? modeData['l'] ?? modeData['hal'] ?? 0;
            final l = (double.tryParse(lRaw.toString()) ?? 0).toInt();
            
            final uRaw = modeData['hal_ulang'] ?? modeData['U'] ?? modeData['ulang'] ?? modeData['u'] ?? 0;
            final u = (double.tryParse(uRaw.toString()) ?? 0).toInt();
            
            final totRaw = modeData['jml_sesi'] ?? modeData['T'] ?? modeData['total'] ?? modeData['t'] ?? 0;
            final tot = (double.tryParse(totRaw.toString()) ?? 0).toInt();
            if (tot > 0) {
              simStr = '$l/$u/$tot';
              totalL += l;
              totalU += u;
              totalSim += tot;
            } else {
              final hal =
                  int.tryParse(
                    (modeData['hal'] ?? modeData['halaman'] ?? 0).toString(),
                  ) ??
                  0;
              final status =
                  modeData['status']?.toString() ??
                  modeData['status_halaman']?.toString() ??
                  '-';
              final isLulus = status.toLowerCase() == 'lulus';
              simStr = '$hal hal • ${isLulus ? "L" : "U"}';
            }
          }
          rows.add((
            isFirst ? label : '',
            entry.key,
            simStr,
            isFirst ? absensiStr : '',
            _modeColor(entry.key),
            isFirst,
          ));
          isFirst = false;
        }
      }
    }

    final colWidths = [
      const FlexColumnWidth(2.2),
      const FlexColumnWidth(1.8),
      const FlexColumnWidth(1.5),
      const FlexColumnWidth(1.6),
    ];

    Widget headerCell(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: onSurf,
        ),
        textAlign: TextAlign.center,
      ),
    );

    return _SectionWidget(
      title: 'Perkembangan Mingguan',
      styles: styles,
      child: Column(
        children: [
          // Table
          Table(
            columnWidths: {
              0: colWidths[0],
              1: colWidths[1],
              2: colWidths[2],
              3: colWidths[3],
            },
            border: TableBorder.all(
              color: onSurf.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: surfHigh.withValues(alpha: 0.6),
                ),
                children: [
                  headerCell('Periode'),
                  headerCell('Mode'),
                  headerCell('Simakan\nL/U/T'),
                  headerCell('Absensi\nH/S/I/T'),
                ],
              ),
              // Data rows
              ...rows.map((r) {
                final (periode, mode, simakan, absensi, color, isFirst) = r;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isFirst && periode.isNotEmpty
                        ? color.withValues(alpha: 0.04)
                        : null,
                  ),
                  children: [
                    // Periode
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 5,
                      ),
                      child: Text(
                        periode,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Mode badge
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: mode == '-'
                          ? Text(
                              '-',
                              style: TextStyle(fontSize: 10, color: onSurf),
                              textAlign: TextAlign.center,
                            )
                          : Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  mode.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    // Simakan
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 4,
                      ),
                      child: Text(
                        simakan,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Absensi
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 4,
                      ),
                      child: Text(
                        absensi,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
              // Total row
              TableRow(
                decoration: BoxDecoration(
                  color: surfHigh.withValues(alpha: 0.8),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 5,
                    ),
                    child: Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: onSurf,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 4,
                    ),
                    child: Text(
                      'AKUMULASI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: onSurf,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 4,
                    ),
                    child: Text(
                      totalSim > 0 ? '$totalL/$totalU/$totalSim' : '-',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 4,
                    ),
                    child: Text(
                      totalH + totalS + totalI + totalAlpa > 0
                          ? '$totalH/$totalS/$totalI/$totalAlpa'
                          : '-',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Legend
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('L = Lulus', const Color(0xFF22C55E)),
              const SizedBox(width: 12),
              _legendItem('U = Ulang', Colors.red),
              const SizedBox(width: 12),
              _legendItem('T = Total', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 9, color: color)),
      ],
    );
  }

  Widget _buildMasalahCard(
    BuildContext context,
    List<Map<dynamic, dynamic>> masalah,
    AppCustomStyles? styles,
  ) {
    return _SectionWidget(
      title: 'Masalah Aktif',
      styles: styles,
      child: masalah.isEmpty
          ? Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF22C55E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tidak ada masalah yang aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : Column(
              children: masalah
                  .map(
                    (m) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      title: Text(
                        m['jenis_masalah']?.toString() ?? 'Masalah',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        m['keterangan']?.toString() ?? '-',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _RiwayatTab extends StatefulWidget {
  final List<dynamic> riwayat;
  final Function(Map<dynamic, dynamic>, {bool onlyEditDate}) onEdit;
  final Function(int) onDelete;

  const _RiwayatTab({
    required this.riwayat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_RiwayatTab> createState() => _RiwayatTabState();
}

class _RiwayatTabState extends State<_RiwayatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _formatIndonesianDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;

    final hijri = HijriCalendar.fromDate(dt);
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}H';
    final masehiStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);

    return '$masehiStr\n$hijriStr';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final styles = Theme.of(context).extension<AppCustomStyles>();
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;

    if (widget.riwayat.isEmpty) {
      return const Center(child: Text('Belum ada riwayat'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.riwayat.length,
      itemBuilder: (context, i) {
        final r = widget.riwayat[i];
        final isLulus =
            r['status']?.toString().toLowerCase() == 'lulus' ||
            r['status_halaman']?.toString().toLowerCase() == 'lulus';
        final halAwal = r['hal_awal']?.toString() ?? '-';
        final halAkhir = r['hal_akhir']?.toString() ?? '-';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: styles?.cardBorder ?? Colors.white.withValues(alpha: 0.1),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatIndonesianDate(r['tgl_simak'] ?? r['tanggal']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isLulus ? Colors.green : Colors.red).withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLulus ? 'LULUS' : 'MENGULANG',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isLulus ? const Color(0xFF22C55E) : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progres Halaman',
                        style: TextStyle(fontSize: 10, color: onSurfaceVar),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hal: $halAwal s/d $halAkhir',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => widget.onEdit(r, onlyEditDate: i != 0),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () => widget.onDelete(
                      int.tryParse(r['id']?.toString() ?? '0') ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InputTab extends StatefulWidget {
  final Map<String, dynamic>? detail;
  final Map<String, dynamic> santri;
  final List<Map<String, dynamic>> catatanMaster;
  final VoidCallback onSuccess;

  const _InputTab({
    required this.detail,
    required this.santri,
    required this.catatanMaster,
    required this.onSuccess,
  });

  @override
  State<_InputTab> createState() => _InputTabState();
}

class _InputTabState extends State<_InputTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = widget.detail?['santri'] ?? widget.santri;
    final int jmlTes = int.tryParse(s['jml_tes']?.toString() ?? '0') ?? 0;
    final double capaiAks =
        double.tryParse(s['capai_aks']?.toString() ?? '0') ?? 0;

    double initHal = double.tryParse(s['capai_hal']?.toString() ?? '0') ?? 0;
    final riwayat = widget.detail?['riwayat'];
    if (riwayat is List && riwayat.isNotEmpty) {
      final lastProgress = riwayat.first;
      final isLulus =
          lastProgress['status']?.toString().toLowerCase() == 'lulus' ||
          lastProgress['status_halaman']?.toString().toLowerCase() == 'lulus';
      if (isLulus) {
        initHal =
            double.tryParse(lastProgress['hal_akhir']?.toString() ?? '0') ??
            initHal;
      } else {
        initHal =
            double.tryParse(lastProgress['hal_awal']?.toString() ?? '0') ??
            initHal;
      }
    }

    // Logic for locking input (Siap Tes)
    final capaiHal = double.tryParse(s['capai_hal']?.toString() ?? '0') ?? 0;
    final totalHal = double.tryParse(s['total_hal']?.toString() ?? '0') ?? 0;
    final nextCP = s['nextCheckpoint'] ?? s['checkpoints'];
    final cpTarget = nextCP is Map
        ? (double.tryParse(nextCP['halaman_target']?.toString() ?? '0') ?? 0.0)
        : 0.0;
    final bool isFinishedReg = (totalHal > 0 && capaiHal >= totalHal);
    final double currentLimit = isFinishedReg
        ? totalHal
        : (cpTarget > 0 ? cpTarget : totalHal);
    final bool isAtCP =
        (!isFinishedReg && cpTarget > 0 && capaiHal >= cpTarget);
    final bool latihanSelesai =
        (s['lat_sek'] != null &&
        double.tryParse(s['lat_sek'].toString()) != null &&
        double.tryParse(s['lat_sek'].toString())! >= currentLimit &&
        currentLimit > 0);
    final bool aksSelesai = (totalHal > 0 && capaiAks >= totalHal);
    final String lastMode = s['last_mode']?.toString() ?? '';
    final bool isAksMode =
        jmlTes > 0 || capaiAks > 0 || lastMode == 'akselerasi';
    final bool isLatihanMode =
        !isAksMode && (isAtCP || isFinishedReg) && totalHal > 0;
    final bool isRegulerMode = !isAksMode && !isLatihanMode;

    bool locked = false;
    if (isAksMode && aksSelesai) {
      locked = true;
    } else if (isLatihanMode && latihanSelesai) {
      locked = true;
    } else if (isRegulerMode && isAtCP) {
      locked = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DetailInputFormWidget(
        nis: s['nis']?.toString() ?? '',
        initialHalAwal: initHal,
        isLatihan: isLatihanMode,
        isAkselerasi: isAksMode,
        jmlTes: jmlTes,
        isTerkunci: locked,
        alasanKunci: '🎯 Target tercapai — Siap Tes',
        catatanMaster: widget.catatanMaster,
        kelasSettings: Map<String, dynamic>.from(
          widget.detail?['kelas_settings'] ?? {},
        ),
        metodeList: List<Map<String, dynamic>>.from(
          widget.detail?['metode_list'] ?? [],
        ),
        idKelas: int.tryParse(s['id_kelas']?.toString() ?? '0') ?? 0,
        onSuccess: widget.onSuccess,
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final AppCustomStyles? styles;
  const _SectionWidget({required this.title, required this.child, this.styles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color onSurfaceVar;
  final VoidCallback? onWaTap;
  const _InfoRowWidget({
    required this.label,
    required this.value,
    required this.onSurfaceVar,
    this.onWaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: onSurfaceVar)),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onWaTap != null &&
                    value.trim() != '' &&
                    value.trim() != '-')
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InkWell(
                      onTap: onWaTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat,
                          size: 14,
                          color: Color(0xFF25D366),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SubSectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
