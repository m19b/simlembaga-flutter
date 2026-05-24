import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';

/// Tab 2: Riwayat global setoran semua santri
class PraTahfidzRiwayatTab extends StatefulWidget {
  const PraTahfidzRiwayatTab({super.key});

  @override
  State<PraTahfidzRiwayatTab> createState() => _PraTahfidzRiwayatTabState();
}

class _PraTahfidzRiwayatTabState extends State<PraTahfidzRiwayatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Ambil riwayat dari detail yang sudah ada, bukan endpoint khusus
  // karena API pra-tahfidz menggunakan endpoint detail/:nis
  final List<Map<String, dynamic>> _riwayat = [];
  bool _loading = false;
  String _error = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<PraTahfidzCubit>().state;
        if (state is PraTahfidzLoaded) {
          _processState(state.data);
        }
      }
    });
  }

  void _processState(dynamic data) {
    final actualData = data['data'] ?? data;
    final rawList = actualData['santri_list'];
    if (rawList is List) {
      final List<Map<String, dynamic>> allRiwayat = [];
      for (final s in rawList) {
        if (s is! Map) continue;
        final riwayatHariIni = s['riwayat_hari_ini'];
        if (riwayatHariIni is List) {
          for (final r in riwayatHariIni) {
            if (r is Map) {
              final Map<String, dynamic> row = {};
              r.forEach((k, v) => row[k.toString()] = v);
              row['nama_santri'] = s['nama_santri'];
              row['tingkat'] = s['tingkat'];
              allRiwayat.add(row);
            }
          }
        }
      }
      setState(() {
        _riwayat
          ..clear()
          ..addAll(allRiwayat);
        _loading = false;
        _error = '';
      });
    }
  }

  // Hapus riwayat
  Future<void> _hapus(int idPrestasi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
            'Riwayat setoran ini akan dihapus. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok =
        await context.read<PraTahfidzCubit>().hapusRiwayat(idPrestasi);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Riwayat dihapus.' : 'Gagal menghapus.'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  Future<void> _refresh() async {
    final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final activeId = context.read<ActiveKelompokCubit>().state.activeId;
    await context.read<PraTahfidzCubit>().fetchSantriList(
          tanggal: tanggal,
          idKelompok: activeId > 0 ? activeId : null,
          forceRefresh: true,
        );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<PraTahfidzCubit, PraTahfidzState>(
      listener: (context, state) {
        if (state is PraTahfidzLoaded) {
          _processState(state.data);
        } else if (state is PraTahfidzLoading) {
          setState(() => _loading = true);
        } else if (state is PraTahfidzError) {
          setState(() {
            _loading = false;
            _error = state.message;
          });
        }
      },
      child: Column(
        children: [
          // ── Header tanggal ──────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.history_edu_rounded,
                    size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Setoran ${DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_riwayat.length} entri',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_month_rounded,
                        size: 18, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // ── Daftar Riwayat ──────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            Center(
                              child: Text(
                                _error,
                                style: TextStyle(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6)),
                              ),
                            ),
                          ],
                        )
                      : _riwayat.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.history_toggle_off_rounded,
                                          size: 56,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.25)),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Belum ada setoran hari ini.',
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: _riwayat.length,
                              itemBuilder: (ctx, i) {
                              final r = _riwayat[i];
                              final idPrestasi = int.tryParse(
                                      r['id_prestasi_pratahfidz']
                                              ?.toString() ??
                                          r['id_prestasi']?.toString() ??
                                          '') ??
                                  0;
                              final totalHal = double.tryParse(
                                      r['total_hal']?.toString() ?? '0') ??
                                  0;
                              final halAwal = double.tryParse(
                                      r['hal_awal']?.toString() ?? '0') ??
                                  0;
                              final halAkhir = double.tryParse(
                                      r['hal_akhir']?.toString() ?? '0') ??
                                  0;
                              final status =
                                  r['status_bacaan']?.toString() ?? '';

                              Color statusColor;
                              if (status == 'Lebih') {
                                statusColor = styles.success;
                              } else if (status == 'Kurang') {
                                statusColor = styles.warning;
                              } else {
                                statusColor = colorScheme.primary;
                              }

                              return Container(
                                key: ValueKey(idPrestasi),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  border: Border.all(
                                      color: styles.cardBorder),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Status badge
                                    Container(
                                      width: 4,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r['nama_santri']?.toString() ??
                                                '-',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${r['tingkat'] ?? ''} · ${r['sesi'] ?? ''}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              _InfoChip(
                                                label:
                                                    'Hal. ${halAwal.toStringAsFixed(1)} → ${halAkhir.toStringAsFixed(1)}',
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              _InfoChip(
                                                label:
                                                    '+${totalHal.toStringAsFixed(1)} hal',
                                                color: styles.success,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Hapus button
                                    if (idPrestasi > 0)
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: styles.error,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _hapus(idPrestasi),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
