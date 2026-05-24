import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/domain/repositories/tahfidz_repository.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/bloc/tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tabs/tahfidz_progress_tab.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tabs/tahfidz_input_massal_tab.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tabs/tahfidz_riwayat_tab.dart';

/// Root screen modul Tahfidz Al-Qur'an.
/// Struktur identik dengan ProgressScreen (Tahsin) — 3 tab + bottom nav.
class TahfidzScreen extends StatelessWidget {
  const TahfidzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TahfidzRepository(
      networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
    );
    return RepositoryProvider<TahfidzRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (_) => TahfidzCubit(
          repository: repository,
          activeKelompokCubit: context.read<ActiveKelompokCubit>(),
        ),
        child: const _TahfidzView(),
      ),
    );
  }
}

class _TahfidzView extends StatefulWidget {
  const _TahfidzView();

  @override
  State<_TahfidzView> createState() => _TahfidzViewState();
}

class _TahfidzViewState extends State<_TahfidzView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  // Notifier untuk search di tab Progress
  final TextEditingController _searchCtrl = TextEditingController();
  final ValueNotifier<bool> _isSearchOpenNotifier = ValueNotifier(false);

  // Key untuk input massal tab (akses simpan dari AppBar)
  final GlobalKey<TahfidzInputMassalTabState> _inputKey =
      GlobalKey<TahfidzInputMassalTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _tabIndexNotifier.value = _tabController.index;
        if (_isSearchOpenNotifier.value && _tabController.index != 0) {
          _isSearchOpenNotifier.value = false;
          _searchCtrl.clear();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabIndexNotifier.dispose();
    _searchCtrl.dispose();
    _isSearchOpenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        customTitle: ValueListenableBuilder<bool>(
          valueListenable: _isSearchOpenNotifier,
          builder: (context, isSearchOpen, _) {
            return ValueListenableBuilder<int>(
              valueListenable: _tabIndexNotifier,
              builder: (context, tabIdx, _) {
                return isSearchOpen && tabIdx == 0
                    ? TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari Santri...',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              _isSearchOpenNotifier.value = false;
                            },
                          ),
                        ),
                      )
                    : Text(
                        tabIdx == 0
                            ? 'Tahfidz Al-Qur\'an'
                            : tabIdx == 1
                                ? 'Input Setoran'
                                : 'Riwayat',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      );
              },
            );
          },
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSearchOpenNotifier,
            builder: (context, isSearchOpen, _) {
              return ValueListenableBuilder<int>(
                valueListenable: _tabIndexNotifier,
                builder: (context, tabIdx, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tabIdx == 0 && !isSearchOpen)
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            _isSearchOpenNotifier.value = true,
                      ),
                    if (tabIdx == 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _inputKey.currentState?.simpan(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857), // Green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          icon: const Icon(Icons.save, size: 16),
                          label: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          TahfidzProgressTab(searchCtrl: _searchCtrl),
          TahfidzInputMassalTab(key: _inputKey),
          const TahfidzRiwayatTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return ValueListenableBuilder<int>(
      valueListenable: _tabIndexNotifier,
      builder: (context, tabIdx, _) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
          top: 2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildNavItem(
                0,
                Icons.menu_book_rounded,
                'Progress',
                tabIdx,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                1,
                Icons.edit_document,
                'Input',
                tabIdx,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                2,
                Icons.history_edu,
                'Riwayat',
                tabIdx,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int currentIdx,
  ) {
    final isSelected = currentIdx == index;
    return InkWell(
      onTap: () {
        _tabController.animateTo(index);
        _tabIndexNotifier.value = index;
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 4),
            if (isSelected || MediaQuery.of(context).size.width > 360)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary)
                        : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Skeleton shimmer card — reusable
// =============================================================================
class TahfidzSkeletonCard extends StatelessWidget {
  const TahfidzSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base =
        Theme.of(context).extension<AppCustomStyles>()!.shimmerBase;
    final highlight =
        Theme.of(context).extension<AppCustomStyles>()!.shimmerHighlight;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).extension<AppCustomStyles>()!.cardBorder,
        ),
      ),
      child: _ShimmerBox(base: base, highlight: highlight),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final Color base;
  final Color highlight;
  const _ShimmerBox({required this.base, required this.highlight});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [_anim.value - 0.3, _anim.value, _anim.value + 0.3],
            colors: [widget.base, widget.highlight, widget.base],
          ),
        ),
      ),
    );
  }
}

/// Helper formatter global untuk modul Tahfidz
String formatHal(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(1);
}

/// Format angka Juz / Halaman
String formatJuz(double hal) {
  // 1 Juz ≈ 20 halaman Al-Qur'an standar (Utsmani)
  const double halPerJuz = 20.0;
  final juz = hal / halPerJuz;
  if (juz < 1) return '${formatHal(hal)} hal';
  return '${juz.toStringAsFixed(1)} juz (${formatHal(hal)} hal)';
}

/// Format tanggal dari string ISO ke lokal
String formatTanggal(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('d MMM yyyy', 'id').format(dt);
  } catch (_) {
    return raw;
  }
}
