import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';

class PraTahfidzDetailScreen extends StatefulWidget {
  final String nis;
  final String namaSantri;

  const PraTahfidzDetailScreen({
    super.key,
    required this.nis,
    required this.namaSantri,
  });

  @override
  State<PraTahfidzDetailScreen> createState() => _PraTahfidzDetailScreenState();
}

class _PraTahfidzDetailScreenState extends State<PraTahfidzDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<PraTahfidzCubit>().fetchDetail(widget.nis, forceRefresh: true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _hapus(int idPrestasi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Riwayat setoran ini akan dihapus. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await context.read<PraTahfidzCubit>().hapusRiwayat(idPrestasi);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Riwayat dihapus.' : 'Gagal menghapus.'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));

    if (ok) {
      _loadData(); // Reload detail
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaSantri,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'NIS: ${widget.nis}',
              style: const TextStyle(
                color: Colors.white70, 
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: colorScheme.secondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Buku Prestasi'),
          ],
        ),
      ),
      body: BlocBuilder<PraTahfidzCubit, PraTahfidzState>(
        buildWhen: (prev, curr) {
          return curr is PraTahfidzDetailLoading ||
              curr is PraTahfidzDetailLoaded ||
              curr is PraTahfidzError;
        },
        builder: (context, state) {
          if (state is PraTahfidzDetailLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: SkeletonListWidget(itemCount: 4, itemHeight: 120),
            );
          } else if (state is PraTahfidzError) {
            return _buildError(state.message);
          } else if (state is PraTahfidzDetailLoaded) {
            final data = state.data['data'] ?? state.data;
            final santri = data['santri'] is Map ? data['santri'] as Map<String, dynamic> : <String, dynamic>{};
            final rekap = data['rekap'] is Map ? data['rekap'] as Map<String, dynamic> : <String, dynamic>{};
            final riwayat = data['riwayat'] is List ? data['riwayat'] as List : [];

            return TabBarView(
              controller: _tabs,
              children: [
                _buildRingkasan(santri, rekap, riwayat),
                _buildRiwayat(riwayat.whereType<Map<String, dynamic>>().toList()),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(String err) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            err,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).extension<AppCustomStyles>()!.success,
              foregroundColor: Colors.white,
            ),
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: Ringkasan ────────────────────────────────────────────────────────
  Widget _buildRingkasan(Map<String, dynamic> santri, Map<String, dynamic> rekap, List<dynamic> riwayat) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPribadiCard(santri, rekap, riwayat),
          const SizedBox(height: 16),
          _buildRekapCard(rekap, riwayat),
        ],
      ),
    );
  }

  Widget _buildPribadiCard(Map<String, dynamic> santri, Map<String, dynamic> rekap, List<dynamic> riwayat) {
    final colorScheme = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;

    // Jika rekap kosong, hitung pointer dari riwayat terakhir
    String pointerText = '0';
    if (rekap.isNotEmpty && rekap['pointer_halaman'] != null) {
      pointerText = rekap['pointer_halaman'].toString();
    } else if (riwayat.isNotEmpty) {
      pointerText = riwayat.first['hal_akhir']?.toString() ?? '0';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Data Pribadi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Nama', santri['nama_santri']?.toString() ?? '-'),
          _infoRow('NIS', santri['nis']?.toString() ?? '-'),
          _infoRow('Tingkat', santri['tingkat']?.toString() ?? '-'),
          _infoRow('Kelas', santri['nama_kelas']?.toString() ?? '-'),
          _infoRow('Pointer Saat Ini', 'Hal. ${double.tryParse(pointerText)?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}'),
        ],
      ),
    );
  }

  Widget _buildRekapCard(Map<String, dynamic> rekap, List<dynamic> riwayat) {
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final colorScheme = Theme.of(context).colorScheme;

    // Menghitung kumulatif halaman: pakai rekap jika ada, jika tidak jumlahkan manual dari riwayat
    double totalHal = 0;
    if (rekap.isNotEmpty && rekap['kumulatif_halaman'] != null) {
      totalHal = double.tryParse(rekap['kumulatif_halaman']?.toString() ?? '0') ?? 0;
    } else {
      for (final r in riwayat) {
        totalHal += double.tryParse(r['total_hal']?.toString() ?? '0') ?? 0;
      }
    }
    final totalSetoran = riwayat.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Statistik Progres',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  'Total Setoran',
                  '$totalSetoran✕',
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  'Total Halaman',
                  '${totalHal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} Hal',
                  styles.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: Riwayat ────────────────────────────────────────────────────────
  Widget _buildRiwayat(List<Map<String, dynamic>> riwayat) {
    if (riwayat.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat setoran.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: riwayat.length,
        itemBuilder: (ctx, i) {
          final r = riwayat[i];
          final colorScheme = Theme.of(context).colorScheme;
          final styles = Theme.of(context).extension<AppCustomStyles>()!;

          final idPrestasi = int.tryParse(r['id_prestasi_pratahfidz']?.toString() ?? '') ?? 0;
          final tglStr = r['tanggal']?.toString() ?? '';
          final tgl = DateTime.tryParse(tglStr) ?? DateTime.now();
          
          final halAwal = double.tryParse(r['hal_awal']?.toString() ?? '0') ?? 0;
          final halAkhir = double.tryParse(r['hal_akhir']?.toString() ?? '0') ?? 0;
          final totalHal = double.tryParse(r['total_hal']?.toString() ?? '0') ?? 0;
          final status = r['status_bacaan']?.toString() ?? '';
          
          Color statusColor;
          if (status == 'Lebih') {
            statusColor = styles.success;
          } else if (status == 'Kurang') {
            statusColor = styles.warning;
          } else {
            statusColor = colorScheme.primary;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: styles.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Date Box
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(tgl),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(tgl),
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesi ${r['sesi'] ?? '-'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hal. ${halAwal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} → ${halAkhir.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${totalHal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} hal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: styles.error),
                  onPressed: () => _hapus(idPrestasi),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
