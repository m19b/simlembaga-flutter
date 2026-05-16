import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_santri_card.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_skeleton_card.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/pra_tahfidz_detail_screen.dart';

/// Tab 0: Daftar santri + status setoran hari ini
class PraTahfidzProgressTab extends StatefulWidget {
  final TextEditingController searchCtrl;
  final ValueNotifier<List<Map<String, dynamic>>> kelasListNotifier;
  final ValueNotifier<int?> selectedKelasNotifier;
  final DateTime selectedDate;

  const PraTahfidzProgressTab({
    super.key,
    required this.searchCtrl,
    required this.kelasListNotifier,
    required this.selectedKelasNotifier,
    required this.selectedDate,
  });

  @override
  State<PraTahfidzProgressTab> createState() => _PraTahfidzProgressTabState();
}

class _PraTahfidzProgressTabState extends State<PraTahfidzProgressTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _allSantri = [];
  List<Map<String, dynamic>> _filtered = [];
  int? _selectedKelasId;
  bool _loading = true;
  String _error = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.searchCtrl.addListener(_onSearch);
    widget.selectedKelasNotifier.addListener(_onKelasChanged);
    _load();
  }

  @override
  void didUpdateWidget(covariant PraTahfidzProgressTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload jika tanggal berubah dari parent
    if (oldWidget.selectedDate != widget.selectedDate) _load();
  }

  void _onKelasChanged() {
    if (_selectedKelasId != widget.selectedKelasNotifier.value) {
      setState(() {
        _selectedKelasId = widget.selectedKelasNotifier.value;
        _loading = true;
      });
      _load();
    }
  }

  @override
  void dispose() {
    widget.searchCtrl.removeListener(_onSearch);
    widget.selectedKelasNotifier.removeListener(_onKelasChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final q = widget.searchCtrl.text.trim().toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? _allSantri
            : _allSantri.where((s) {
                final nama =
                    (s['nama_santri'] ?? '').toString().toLowerCase();
                final nis = (s['nis'] ?? '').toString().toLowerCase();
                return nama.contains(q) || nis.contains(q);
              }).toList();
      });
    });
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final tanggal =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    await context.read<PraTahfidzCubit>().fetchSantriList(
          tanggal: tanggal,
          forceRefresh: forceRefresh,
        );
  }

  void _applyData(Map<String, dynamic> raw) {
    List<Map<String, dynamic>> list = [];

    final actualData = raw['data'] ?? raw;
    if (actualData is Map) {
      // Parse filter_meta untuk kelas list
      final fm = actualData['filter_meta'];
      if (fm is Map) {
        final kelasL = fm['kelas_list'];
        if (kelasL is List) {
          final kelasList = kelasL.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.kelasListNotifier.value = kelasList;
          });
        }
      }

      // Parse santri list
      var rawList = actualData['santri_list'];
      if (rawList is List) {
        list = rawList.whereType<Map>().map((e) {
          final Map<String, dynamic> m = {};
          e.forEach((k, v) => m[k.toString()] = v);
          return m;
        }).toList();
      }
    }

    // Filter by kelas jika dipilih
    if (_selectedKelasId != null) {
      list = list
          .where((s) =>
              int.tryParse(
                  s['id_kelas_pratahfidz']?.toString() ?? '') ==
              _selectedKelasId)
          .toList();
    }

    setState(() {
      _allSantri = list;
      _filtered = list;
      _loading = false;
      _error = '';
    });
    _onSearch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<PraTahfidzCubit, PraTahfidzState>(
      listener: (context, state) {
        if (state is PraTahfidzLoaded) {
          _applyData(state.data);
        } else if (state is PraTahfidzLoading) {
          setState(() {
            _loading = true;
            _error = '';
          });
        } else if (state is PraTahfidzError) {
          setState(() {
            _loading = false;
            _error = state.message;
          });
        }
      },
      builder: (context, state) {
        if (_loading && _allSantri.isEmpty) {
          return _buildSkeleton();
        }
        if (_error.isNotEmpty && _allSantri.isEmpty) {
          return _buildError();
        }
        return _buildList();
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      itemBuilder: (context, index) => const PraTahfidzSkeletonCard(),
    );
  }

  Widget _buildError() {
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
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
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: styles.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _load(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada data santri.',
              style: TextStyle(
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

    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filtered.length,
        itemBuilder: (context, i) {
          final santri = _filtered[i];
          return PraTahfidzSantriCard(
            key: ValueKey(santri['nis'] ?? i),
            santri: santri,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<PraTahfidzCubit>(),
                  child: PraTahfidzDetailScreen(
                    nis: santri['nis']?.toString() ?? '',
                    namaSantri:
                        santri['nama_santri']?.toString() ?? '-',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
