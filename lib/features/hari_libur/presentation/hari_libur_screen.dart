import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/repositories/hari_libur_repository.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/bloc/hari_libur_cubit.dart';


class HariLiburScreen extends StatelessWidget {
  const HariLiburScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idKelompok =
        context.read<ActiveKelompokCubit>().state.activeId;

    return BlocProvider(
      create: (_) => HariLiburCubit(
        repository: HariLiburRepository(
          networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
        ),
      )..fetch(tahun: DateTime.now().year, idKelompok: idKelompok),
      child: const _HariLiburView(),
    );
  }
}

class _HariLiburView extends StatefulWidget {
  const _HariLiburView();

  @override
  State<_HariLiburView> createState() => _HariLiburViewState();
}

class _HariLiburViewState extends State<_HariLiburView> {
  late int _selectedTahun;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTahun = DateTime.now().year;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }


  void _refetch() {
    final idKelompok =
        context.read<ActiveKelompokCubit>().state.activeId;
    context
        .read<HariLiburCubit>()
        .fetch(tahun: _selectedTahun, idKelompok: idKelompok);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchCtrl.clear();
      }
    });
  }

  List<HariLiburModel> _filterItems(List<HariLiburModel> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items
        .where((h) => h.keterangan.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now().year;
    final tahunOptions = [now - 1, now, now + 1];

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── AppBar: judul kiri, dropdown tahun + search kanan ─────────
          SliverAppBar(
            pinned: true,
            titleSpacing: 0,
            backgroundColor: isDark ? Colors.black : Theme.of(context).colorScheme.primary,
            flexibleSpace: const FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(child: GlobalHeaderBackground()),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.onPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Cari hari libur...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                          fontSize: 15),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  )
                : Text(
                    'Hari Libur',
                    style: GoogleFonts.plusJakartaSans(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
            actions: [
              // Dropdown tahun (hanya saat tidak search)
              if (!_isSearching)
                PopupMenuButton<int>(
                  initialValue: _selectedTahun,
                  onSelected: (val) {
                    setState(() => _selectedTahun = val);
                    _refetch();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: isDark
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF0F4C2A),
                  itemBuilder: (_) => tahunOptions.map((t) {
                    final isSelected = t == _selectedTahun;
                    return PopupMenuItem<int>(
                      value: t,
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check_rounded,
                                color: Colors.amber, size: 16)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 6),
                          Text(
                            '$t',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_selectedTahun',
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded,
                            color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              // Search icon di kanan mentok
              IconButton(
                icon: Icon(
                  _isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _toggleSearch,
              ),
            ],
          ),


          // ── Body ──────────────────────────────────────────────────────
          BlocBuilder<HariLiburCubit, HariLiburState>(
            builder: (context, state) {
              if (state is HariLiburLoading || state is HariLiburInitial) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const _SkeletonCard(),
                      childCount: 6,
                    ),
                  ),
                );
              }

              if (state is HariLiburError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              size: 56, color: cs.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refetch,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (state is HariLiburLoaded) {
                final items = _filterItems(state.items);
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.event_busy_rounded,
                              size: 56,
                              color: cs.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ditemukan "$_searchQuery"'
                                  : 'Tidak ada hari libur di tahun $_selectedTahun',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }

                // Group by month
                final Map<int, List<HariLiburModel>> byMonth = {};
                for (final item in items) {
                  final dt = item.tanggalDt;
                  final month = dt?.month ?? 0;
                  byMonth.putIfAbsent(month, () => []).add(item);
                }
                final sortedMonths = byMonth.keys.toList()..sort();

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final month = sortedMonths[index];
                        final monthItems = byMonth[month]!;
                        return _MonthSection(
                          month: month,
                          year: _selectedTahun,
                          items: monthItems,
                        );
                      },
                      childCount: sortedMonths.length,
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}

// ── Month section ────────────────────────────────────────────────────────────
class _MonthSection extends StatelessWidget {
  final int month;
  final int year;
  final List<HariLiburModel> items;

  const _MonthSection({
    required this.month,
    required this.year,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final monthName = DateFormat('MMMM', 'id_ID')
        .format(DateTime(year, month));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                monthName,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _HariLiburCard(item: item)),
      ],
    );
  }
}

// ── Card hari libur ──────────────────────────────────────────────────────────
class _HariLiburCard extends StatelessWidget {
  final HariLiburModel item;

  const _HariLiburCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dt = item.tanggalDt;
    final isPast = dt != null && dt.isBefore(DateTime.now());
    final isToday = dt != null &&
        dt.year == DateTime.now().year &&
        dt.month == DateTime.now().month &&
        dt.day == DateTime.now().day;

    final Color accentColor = isToday
        ? Colors.amber
        : (item.kategori?.toLowerCase() == 'nasional'
            ? Colors.red.shade400
            : cs.primary);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: isToday
            ? Border.all(color: Colors.amber.shade400, width: 1.5)
            : Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    dt != null ? '${dt.day}' : '-',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor),
                  ),
                  Text(
                    dt != null
                        ? DateFormat('MMM', 'id_ID').format(dt).toUpperCase()
                        : '',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accentColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaLibur,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isPast
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : cs.onSurface,
                    ),
                  ),
                  if (item.tanggalMulai != item.tanggalAkhir) ...[
                    const SizedBox(height: 4),
                    Text(
                      's.d. ${item.tanggalAkhir}',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (item.kategori != null && item.kategori!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.kategori!,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: accentColor),
                          ),
                        ),
                      if (isToday) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'HARI INI',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loading ─────────────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 80,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 14,
                    width: 160,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    )),
                const SizedBox(height: 8),
                Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
