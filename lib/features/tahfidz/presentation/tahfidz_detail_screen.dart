import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/bloc/tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_screen.dart'
    show formatHal, formatJuz, formatTanggal;
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_error_widget.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_skeleton_widget.dart';
/// Halaman Detail Buku Prestasi Santri Tahfidz Al-Qur'an.
/// Menampilkan: Rekap kumulatif + Riwayat setoran + Grafik (placeholder).
class TahfidzDetailScreen extends StatefulWidget {
  final Map<String, dynamic> santri;
  const TahfidzDetailScreen({super.key, required this.santri});

  @override
  State<TahfidzDetailScreen> createState() => _TahfidzDetailScreenState();
}

class _TahfidzDetailScreenState extends State<TahfidzDetailScreen> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic> _detail = {};
  Map<String, dynamic> _rekap = {};
  List<Map<String, dynamic>> _riwayat = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final nis = widget.santri['nis']?.toString() ?? '';
      final res = await context
          .read<TahfidzCubit>()
          .repository
          .getDetail(nis, forceRefresh: forceRefresh);

      final data = res['data'] ?? res;
      final santriData = data['santri'] as Map? ?? {};
      final rekapData = data['rekap'] as Map? ?? {};
      final riwayatRaw = data['riwayat'] as List? ?? [];

      setState(() {
        _detail = {
          ...widget.santri,
          ...{
            'id': null,
          },
        };
        santriData.forEach((k, v) => _detail[k.toString()] = v);
        _rekap = {};
        rekapData.forEach((k, v) => _rekap[k.toString()] = v);
        _riwayat = riwayatRaw
            .whereType<Map>()
            .map((e) {
              final Map<String, dynamic> m = {};
              e.forEach((k, v) => m[k.toString()] = v);
              return m;
            })
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppCustomStyles>()!;
    final nama =
        widget.santri['nama_santri']?.toString() ??
        _detail['nama_santri']?.toString() ??
        '-';
    final tingkat =
        widget.santri['tingkat']?.toString() ??
        _detail['tingkat']?.toString() ??
        '-';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Stack(
          children: [
            const Positioned.fill(child: GlobalHeaderBackground()),
            AppBar(
              toolbarHeight: 56,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    tingkat,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => _loadDetail(forceRefresh: true),
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
          ],
        ),
      ),
      body: _loading
          ? const GlobalSkeletonWidget(
              itemCount: 5,
            )
          : _error.isNotEmpty
              ? GlobalErrorWidget(
                  message: _error,
                  onRetry: () => _loadDetail(forceRefresh: true),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadDetail(forceRefresh: true),
                  color: custom.success,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      // ── Rekap Kumulatif ──────────────────────────────────
                      _RekapCard(rekap: _rekap),
                      const SizedBox(height: 16),
                      // ── Riwayat Setoran ──────────────────────────────────
                      _RiwayatSection(riwayat: _riwayat, cubit: context.read<TahfidzCubit>(), onDeleted: () => _loadDetail(forceRefresh: true)),
                    ],
                  ),
                ),
    );
  }
}

// =============================================================================
// Rekap Card
// =============================================================================
class _RekapCard extends StatelessWidget {
  final Map<String, dynamic> rekap;
  const _RekapCard({required this.rekap});

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppCustomStyles>()!;
    final ziyadah =
        double.tryParse(rekap['total_ziyadah_hal']?.toString() ?? '0') ?? 0;
    final sabaq =
        double.tryParse(rekap['total_sabaq_hal']?.toString() ?? '0') ?? 0;
    final manzil =
        double.tryParse(rekap['total_manzil_hal']?.toString() ?? '0') ?? 0;
    final mutqin =
        double.tryParse(rekap['mutqin_rate']?.toString() ?? '0') ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: custom.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Rekap Kumulatif',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _RekapItem(
                label: 'Ziyadah',
                value: formatJuz(ziyadah),
                icon: Icons.arrow_upward_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              _RekapItem(
                label: 'Sabaq',
                value: '${formatHal(sabaq)} hal',
                icon: Icons.refresh_rounded,
                color: custom.warning,
              ),
              _RekapItem(
                label: 'Manzil',
                value: '${formatHal(manzil)} hal',
                icon: Icons.history_edu,
                color: custom.success,
              ),
              _RekapItem(
                label: 'Mutqin',
                value: '${mutqin.toStringAsFixed(0)}%',
                icon: Icons.verified_rounded,
                color: mutqin >= 80 ? custom.success : custom.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mutqin progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (mutqin / 100).clamp(0.0, 1.0),
              backgroundColor: custom.cardBorder,
              color: mutqin >= 80 ? custom.success : custom.warning,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tingkat Kemutqinan: ${mutqin.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RekapItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _RekapItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Riwayat Section
// =============================================================================
class _RiwayatSection extends StatelessWidget {
  final List<Map<String, dynamic>> riwayat;
  final TahfidzCubit cubit;
  final VoidCallback onDeleted;

  const _RiwayatSection({
    required this.riwayat,
    required this.cubit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppCustomStyles>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Riwayat Setoran (${riwayat.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (riwayat.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada riwayat setoran.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          ...riwayat.asMap().entries.map((entry) {
            final idx = entry.key;
            final r = entry.value;
            return _RiwayatDetailCard(
              key: ValueKey(r['id_prestasi_tahfidz'] ?? r['id_prestasi'] ?? idx),
              data: r,
              custom: custom,
              cubit: cubit,
              onDeleted: onDeleted,
            );
          }),
      ],
    );
  }
}

class _RiwayatDetailCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppCustomStyles custom;
  final TahfidzCubit cubit;
  final VoidCallback onDeleted;

  const _RiwayatDetailCard({
    super.key,
    required this.data,
    required this.custom,
    required this.cubit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final tanggal = formatTanggal(data['tanggal']?.toString());
    final ziyadah =
        double.tryParse(data['setoran_hal_total']?.toString() ?? '0') ?? 0;
    final sabaq =
        double.tryParse(data['murojaah_baru_total']?.toString() ?? '0') ?? 0;
    final manzil =
        double.tryParse(data['murojaah_lama_total']?.toString() ?? '0') ?? 0;
    final status = data['status_lulus']?.toString() ?? 'Lulus';
    final namaGuru = data['nama_guru']?.toString() ?? '-';
    final isLulus = status.toLowerCase() == 'lulus';
    final idPrestasi =
        int.tryParse(
          data['id_prestasi_tahfidz']?.toString() ?? data['id_prestasi']?.toString() ?? '',
        );
    final nis = data['nis']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: custom.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tanggal,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLulus
                          ? custom.success.withValues(alpha: 0.15)
                          : custom.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLulus ? custom.success : custom.warning,
                      ),
                    ),
                  ),
                  if (idPrestasi != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _konfirmasiHapus(context, idPrestasi, nis),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: custom.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (ziyadah > 0)
                _DetailTag(
                  label: 'Ziyadah',
                  value: '${formatHal(ziyadah)} hal',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.arrow_upward_rounded,
                ),
              if (sabaq > 0)
                _DetailTag(
                  label: 'Sabaq',
                  value: '${formatHal(sabaq)} hal',
                  color: custom.warning,
                  icon: Icons.refresh_rounded,
                ),
              if (manzil > 0)
                _DetailTag(
                  label: 'Manzil',
                  value: '${formatHal(manzil)} hal',
                  color: custom.success,
                  icon: Icons.history_edu,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Diinput oleh: $namaGuru',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(
    BuildContext context,
    int idPrestasi,
    String nis,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus riwayat setoran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final ok = await cubit.hapusRiwayat(idPrestasi, nis);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Riwayat berhasil dihapus.'),
                      backgroundColor: custom.success,
                    ),
                  );
                  onDeleted();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: custom.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: custom.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _DetailTag({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
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
}
