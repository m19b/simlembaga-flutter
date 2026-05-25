import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_error_widget.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_skeleton_widget.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_pribadi_card.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_rekap_card.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_riwayat_item.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Riwayat dihapus.' : 'Gagal menghapus.'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

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
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: colorScheme.secondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
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
            return const GlobalSkeletonWidget(itemCount: 4, height: 120);
          } else if (state is PraTahfidzError) {
            return GlobalErrorWidget(
              message: state.message,
              onRetry: _loadData,
            );
          } else if (state is PraTahfidzDetailLoaded) {
            final data = state.data['data'] ?? state.data;
            final santri = data['santri'] is Map
                ? data['santri'] as Map<String, dynamic>
                : <String, dynamic>{};
            final rekap = data['rekap'] is Map
                ? data['rekap'] as Map<String, dynamic>
                : <String, dynamic>{};
            final riwayat = data['riwayat'] is List
                ? data['riwayat'] as List
                : [];

            return TabBarView(
              controller: _tabs,
              children: [
                _buildRingkasan(santri, rekap, riwayat),
                _buildRiwayat(
                  riwayat.whereType<Map<String, dynamic>>().toList(),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRingkasan(
    Map<String, dynamic> santri,
    Map<String, dynamic> rekap,
    List<dynamic> riwayat,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PraTahfidzPribadiCard(santri: santri, rekap: rekap, riwayat: riwayat),
          const SizedBox(height: 16),
          PraTahfidzRekapCard(rekap: rekap, riwayat: riwayat),
        ],
      ),
    );
  }

  Widget _buildRiwayat(List<Map<String, dynamic>> riwayat) {
    if (riwayat.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat setoran.',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
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
          final idPrestasi =
              int.tryParse(r['id_prestasi_pratahfidz']?.toString() ?? '') ?? 0;
          return PraTahfidzRiwayatItem(
            riwayat: r,
            onHapus: () => _hapus(idPrestasi),
          );
        },
      ),
    );
  }
}
