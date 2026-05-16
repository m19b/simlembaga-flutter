import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/bloc/tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_screen.dart'
    show TahfidzSkeletonCard, formatHal;
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_detail_screen.dart';

/// Tab 1 — Daftar santri dengan rekap Ziyadah / Sabaq / Manzil.
class TahfidzProgressTab extends StatefulWidget {
  final TextEditingController searchCtrl;
  const TahfidzProgressTab({super.key, required this.searchCtrl});

  @override
  State<TahfidzProgressTab> createState() => _TahfidzProgressTabState();
}

class _TahfidzProgressTabState extends State<TahfidzProgressTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _allSantri = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  bool _isFetching = false;
  String _error = '';
  Timer? _debounce;
  String? _tanggal;

  @override
  void initState() {
    super.initState();
    _tanggal = DateTime.now().toIso8601String().split('T')[0];
    widget.searchCtrl.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    widget.searchCtrl.removeListener(_onSearch);
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = widget.searchCtrl.text.trim().toLowerCase();
      if (!mounted) return;
      setState(() {
        _filtered = q.isEmpty
            ? _allSantri
            : _allSantri.where((s) {
                final nama = (s['nama_santri'] ?? '').toString().toLowerCase();
                final nis = (s['nis'] ?? '').toString().toLowerCase();
                return nama.contains(q) || nis.contains(q);
              }).toList();
      });
    });
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final activeId =
          context.read<ActiveKelompokCubit>().state.activeId;
      await context.read<TahfidzCubit>().fetchProgressList(
        idKelompok: activeId > 0 ? activeId : null,
        tanggal: _tanggal,
        forceRefresh: forceRefresh,
      );
    } finally {
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<TahfidzCubit, TahfidzState>(
      listenWhen: (prev, curr) =>
          curr is TahfidzLoaded ||
          curr is TahfidzError ||
          curr is TahfidzLoading,
      listener: (context, state) {
        if (state is TahfidzLoaded) {
          final raw = state.data['data'] ?? state.data;
          List<Map<String, dynamic>> list = [];
          if (raw is Map) {
            final rawList = raw['santri_list'];
            if (rawList is List) {
              list = rawList
                  .whereType<Map>()
                  .map((e) {
                    final Map<String, dynamic> safeMap = {};
                    e.forEach((k, v) => safeMap[k.toString()] = v);
                    return safeMap;
                  })
                  .toList();
            }
          } else if (raw is List) {
            list = raw
                .whereType<Map>()
                .map((e) {
                  final Map<String, dynamic> safeMap = {};
                  e.forEach((k, v) => safeMap[k.toString()] = v);
                  return safeMap;
                })
                .toList();
          }
          setState(() {
            _allSantri = list;
            _filtered = list;
            _loading = false;
            _error = '';
          });
          _onSearch();
        } else if (state is TahfidzError) {
          setState(() {
            _error = state.message;
            _loading = false;
          });
        } else if (state is TahfidzLoading) {
          setState(() {
            _loading = true;
            _error = '';
          });
        }
      },
      builder: (context, state) {
        if (_loading && _allSantri.isEmpty) return _buildSkeleton();
        if (_error.isNotEmpty && _allSantri.isEmpty) return _buildError();
        return _buildBody();
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => const TahfidzSkeletonCard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).extension<AppCustomStyles>()!.success,
              ),
              onPressed: () => _load(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      color: Theme.of(context).extension<AppCustomStyles>()!.success,
      backgroundColor: Theme.of(context).cardColor,
      child: _filtered.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada data santri Tahfidz.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => _load(forceRefresh: true),
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Theme.of(context)
                              .extension<AppCustomStyles>()!
                              .success,
                          size: 18,
                        ),
                        label: Text(
                          'Refresh',
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<AppCustomStyles>()!
                                .success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                return _TahfidzSantriCard(
                  key: ValueKey(_filtered[i]['nis']),
                  santri: _filtered[i],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<TahfidzCubit>(),
                          child: TahfidzDetailScreen(
                            santri: _filtered[i],
                          ),
                        ),
                      ),
                    ).then((_) => _load(forceRefresh: false));
                  },
                );
              },
            ),
    );
  }
}

// =============================================================================
// Card Santri — StatelessWidget untuk isolasi rebuild
// =============================================================================
class _TahfidzSantriCard extends StatelessWidget {
  final Map<String, dynamic> santri;
  final VoidCallback onTap;
  const _TahfidzSantriCard({
    super.key,
    required this.santri,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppCustomStyles>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String nama = santri['nama_santri']?.toString() ?? '-';
    final String nis = santri['nis']?.toString() ?? '';
    final String tingkat = santri['tingkat']?.toString() ?? '-';
    final bool sudahSetor =
        santri['sudah_setor'] == true ||
        santri['sudah_setor']?.toString() == '1' ||
        santri['sudah_setor']?.toString() == 'true';

    final double ziyadah =
        double.tryParse(santri['total_ziyadah_hal']?.toString() ?? '0') ?? 0;
    final double sabaq =
        double.tryParse(santri['total_sabaq_hal']?.toString() ?? '0') ?? 0;
    final double manzil =
        double.tryParse(santri['total_manzil_hal']?.toString() ?? '0') ?? 0;
    final double mutqin =
        double.tryParse(santri['mutqin_rate']?.toString() ?? '0') ?? 0;

    // Riwayat hari ini
    final riwayatHariIni = santri['riwayat_hari_ini'];
    final List<dynamic> riwayat =
        riwayatHariIni is List ? riwayatHariIni : [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: custom.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header baris ────────────────────────────────────────────
              Row(
                children: [
                  _AvatarOrFoto(foto: santri['foto']?.toString()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$nis · $tingkat',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge status setor hari ini
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sudahSetor
                          ? custom.success.withValues(alpha: 0.15)
                          : custom.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sudahSetor
                            ? custom.success.withValues(alpha: 0.5)
                            : custom.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sudahSetor
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          size: 12,
                          color: sudahSetor ? custom.success : custom.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sudahSetor ? 'Sudah' : 'Belum',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                sudahSetor ? custom.success : custom.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Stats row: Ziyadah / Sabaq / Manzil / Mutqin ───────────
              Row(
                children: [
                  _StatChip(
                    label: 'Ziyadah',
                    value: '${formatHal(ziyadah)} hal',
                    icon: Icons.arrow_upward_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  _StatChip(
                    label: 'Sabaq',
                    value: '${formatHal(sabaq)} hal',
                    icon: Icons.refresh_rounded,
                    color: custom.warning,
                  ),
                  const SizedBox(width: 6),
                  _StatChip(
                    label: 'Manzil',
                    value: '${formatHal(manzil)} hal',
                    icon: Icons.history_edu,
                    color: custom.success,
                  ),
                  const SizedBox(width: 6),
                  _StatChip(
                    label: 'Mutqin',
                    value: '${mutqin.toStringAsFixed(0)}%',
                    icon: Icons.verified_rounded,
                    color: custom.success,
                  ),
                ],
              ),
              // ── Setoran hari ini summary ─────────────────────────────────
              if (riwayat.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  color: custom.cardBorder,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Setoran hari ini: ${riwayat.length}x',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOrFoto extends StatelessWidget {
  final String? foto;
  const _AvatarOrFoto({this.foto});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      backgroundImage: (foto != null && foto!.startsWith('http'))
          ? NetworkImage(foto!)
          : null,
      child: (foto == null || !foto!.startsWith('http'))
          ? Icon(
              Icons.person_rounded,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 10, color: color),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
