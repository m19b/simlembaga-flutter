import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'progress_detail_screen.dart';
import 'progress_input_screen.dart';
import 'riwayat_global_tab.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';

import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/bloc/tahsin_cubit.dart';
import 'package:manajemen_tahsin_app/shared/widgets/multi_segment_progress_bar.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_field.dart';

import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_skeleton_widget.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_error_widget.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/widgets/tahsin_report_sheet.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TahsinCubit(
            repository: TahsinRepository(
              networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
            ),
            activeKelompokCubit: context.read<ActiveKelompokCubit>(),
          ),
        ),
      ],
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatefulWidget {
  const _ProgressView();

  @override
  State<_ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<_ProgressView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late TabController _tabController;
  bool _isSearchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final ValueNotifier<List<Map<String, dynamic>>> _kelasListNotifier =
      ValueNotifier([]);
  final ValueNotifier<int?> _selectedKelasNotifier = ValueNotifier(null);
  final GlobalKey<ProgressInputScreenState> _inputKey =
      GlobalKey<ProgressInputScreenState>();

  final GlobalKey<RiwayatGlobalTabState> _riwayatKey =
      GlobalKey<RiwayatGlobalTabState>();
  DateTime _riwayatTanggal = DateTime.now();
  bool _isSavingProgress = false;

  // ValueNotifier untuk tab index — menghindari setState penuh setiap kali tab berubah
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // Hanya update notifier saat index tab benar-benar berubah (bukan saat animasi)
      if (!_tabController.indexIsChanging) {
        _tabIndexNotifier.value = _tabController.index;
        if (_isSearchOpen && _tabController.index != 0) {
          _isSearchOpen = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabIndexNotifier.dispose();
    _searchCtrl.dispose();
    _kelasListNotifier.dispose();
    _selectedKelasNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        customTitle: ValueListenableBuilder<int>(
          valueListenable: _tabIndexNotifier,
          builder: (context, tabIdx, _) {
            return _isSearchOpen && tabIdx == 0
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari Santri...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _isSearchOpen = false);
                        },
                      ),
                    ),
                  )
                : Text(
                    tabIdx == 0
                        ? 'Progres'
                        : tabIdx == 1
                        ? 'Input Evaluasi'
                        : 'Riwayat Kelas',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  );
          },
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _tabIndexNotifier,
            builder: (context, tabIdx, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tabIdx == 0) ...[
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _kelasListNotifier,
                    builder: (context, kelasList, child) {
                      if (kelasList.isEmpty) return const SizedBox.shrink();
                      return ValueListenableBuilder<int?>(
                        valueListenable: _selectedKelasNotifier,
                        builder: (context, selectedKelasId, child) {
                          return Container(
                            height: 26,
                            margin: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).extension<AppCustomStyles>()!.headerBorder,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  popupMenuTheme: PopupMenuThemeData(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .extension<AppCustomStyles>()!
                                            .headerBorder,
                                      ),
                                    ),
                                  ),
                                ),
                                child: DropdownButton<int?>(
                                  value: selectedKelasId,
                                  isDense: true,
                                  dropdownColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Theme.of(context).colorScheme.primary,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.7),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  onChanged: (val) =>
                                      _selectedKelasNotifier.value = val,
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Semua'),
                                    ),
                                    ...kelasList.map((k) {
                                      final id =
                                          int.tryParse(
                                            k['id_kelas']?.toString() ?? '0',
                                          ) ??
                                          0;
                                      final t = k['tingkat']?.toString() ?? '-';
                                      return DropdownMenuItem<int?>(
                                        value: id,
                                        child: Text(t),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (!_isSearchOpen)
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() => _isSearchOpen = true),
                    ),
                ],
                if (tabIdx == 1) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: StatefulBuilder(
                      builder: (context, setBtnState) {
                        return ElevatedButton.icon(
                          onPressed: _isSavingProgress
                              ? null
                              : () async {
                                  setState(() => _isSavingProgress = true);
                                  setBtnState(() {}); // re-render btn
                                  try {
                                    await _inputKey.currentState?.simpan();
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSavingProgress = false);
                                      setBtnState(() {});
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.green.shade300,
                            disabledForegroundColor: Colors.white70,
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
                          icon: _isSavingProgress
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save, size: 16),
                          label: Text(
                            _isSavingProgress ? 'Menyimpan...' : 'Simpan',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (tabIdx == 2) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CustomDateField(
                      selectedDate: _riwayatTanggal,
                      isCompact: true,
                      isWhite: true,
                      onDateSelected: (date) {
                        if (date != null && date != _riwayatTanggal) {
                          setState(() => _riwayatTanggal = date);
                          _riwayatKey.currentState?.setTanggal(date);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Kirim Laporan Perbandingan ke WA Saya',
                    onPressed: () => _showSendReportSheet(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Prevent horizontal swipe to avoid chart conflicts
        children: [
          _SantriListTab(
            searchCtrl: _searchCtrl,
            kelasListNotifier: _kelasListNotifier,
            selectedKelasNotifier: _selectedKelasNotifier,
          ),
          ProgressInputScreen(key: _inputKey), // Component tab Input
          RiwayatGlobalTab(
            key: _riwayatKey,
            repository: context.read<TahsinCubit>().repository,
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
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
                Icons.bar_chart_rounded,
                'Progress',
                tabIdx,
              ),
            ),
            Expanded(
              child: _buildNavItem(1, Icons.edit_document, 'Input', tabIdx),
            ),
            Expanded(
              child: _buildNavItem(2, Icons.history_edu, 'Riwayat', tabIdx),
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
    int currentTabIdx,
  ) {
    final isSelected = currentTabIdx == index;
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
              ? (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15)
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1))
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
                  : Colors.grey,
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary)
                        : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSendReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TahsinReportSheet(),
    );
  }
}

// --- TAB 1: LIST SANTRI (PROGRESS) ------------------------------------------
class _SantriListTab extends StatefulWidget {
  final TextEditingController searchCtrl;
  final ValueNotifier<List<Map<String, dynamic>>> kelasListNotifier;
  final ValueNotifier<int?> selectedKelasNotifier;

  const _SantriListTab({
    required this.searchCtrl,
    required this.kelasListNotifier,
    required this.selectedKelasNotifier,
  });

  @override
  State<_SantriListTab> createState() => _SantriListTabState();
}

class _SantriListTabState extends State<_SantriListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> _allSantri = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _kelompokList = [];
  List<Map<String, dynamic>> _kelasList = [];
  int? _selectedKelompokId;
  int? _selectedKelasId;
  bool _loading = true;
  bool _isFetching = false; // guard: mencegah 2 API call bersamaan
  String _error = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.searchCtrl.addListener(_onSearch);
    widget.selectedKelasNotifier.addListener(_onKelasFilterChanged);

    // Inisialisasi kelompok ID dari cubit global agar tidak null
    _selectedKelompokId = ActiveKelompokCubit.activeKelompokId;
    if (_selectedKelompokId == 0 || _selectedKelompokId == null) {
      final activeState = context.read<ActiveKelompokCubit>().state;
      if (activeState.activeId > 0) {
        _selectedKelompokId = activeState.activeId;
      } else if (activeState.allowedKelompok.isNotEmpty) {
        _selectedKelompokId = int.tryParse(
          activeState.allowedKelompok.first['id_kelompok']?.toString() ?? '0',
        );
      }
    }

    _load();
  }

  void _onKelasFilterChanged() {
    if (_selectedKelasId != widget.selectedKelasNotifier.value) {
      setState(() {
        _selectedKelasId = widget.selectedKelasNotifier.value;
        _allSantri = [];
        _filtered = [];
        _loading = true;
      });
      // Reset cubit ke Initial agar spinner tampil, lalu load dari cache
      context.read<TahsinCubit>().resetToInitial();
      _load();
    }
  }

  @override
  void dispose() {
    widget.searchCtrl.removeListener(_onSearch);
    widget.selectedKelasNotifier.removeListener(_onKelasFilterChanged);
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
    // Guard: jangan panggil API jika sudah ada request yang sedang berjalan
    if (_isFetching) return;
    _isFetching = true;
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await context.read<TahsinCubit>().fetchProgressList(
        idKelompok: _selectedKelompokId,
        idKelas: _selectedKelasId,
        forceRefresh: forceRefresh,
        tanggal: todayStr,
      );
    } finally {
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<TahsinCubit, TahsinState>(
      listener: (context, state) {
        if (state is TahsinLoaded) {
          final raw = state.data['data'] ?? state.data;
          List<Map<String, dynamic>> list = [];

          if (raw is Map) {
            final fm = raw['filter_meta'];
            if (fm is Map) {
              final kl = fm['kelompok_list'];
              if (kl is List) {
                _kelompokList = kl.whereType<Map>().map((e) {
                  final Map<String, dynamic> m = {};
                  e.forEach((k, v) => m[k.toString()] = v);
                  return m;
                }).toList();
                if (_selectedKelompokId == null && _kelompokList.isNotEmpty) {
                  _selectedKelompokId = int.tryParse(
                    _kelompokList.first['id_kelompok']?.toString() ?? '0',
                  );
                }
              }
              final kelasL = fm['kelas_list'];
              if (kelasL is List) {
                _kelasList = kelasL.whereType<Map>().map((e) {
                  final Map<String, dynamic> m = {};
                  e.forEach((k, v) => m[k.toString()] = v);
                  return m;
                }).toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    widget.kelasListNotifier.value = _kelasList;
                  }
                });
              }
            }

            dynamic globalCheckpoints =
                raw['checkpoints'] ?? raw['t_kelas_checkpoint'];
            if (globalCheckpoints is String) {
              try {
                globalCheckpoints = json.decode(globalCheckpoints);
              } catch (_) {}
            }

            final rawList = raw['santri_list'];
            if (rawList is List && rawList.isNotEmpty) {
              list = rawList.whereType<Map>().map((e) {
                final Map<String, dynamic> safeMap = {};
                e.forEach((k, v) => safeMap[k.toString()] = v);
                if (globalCheckpoints != null &&
                    safeMap['checkpoints'] == null) {
                  safeMap['checkpoints'] = globalCheckpoints;
                }
                return safeMap;
              }).toList();
            }
          } else if (raw is List) {
            list = raw.whereType<Map>().map((e) {
              final Map<String, dynamic> safeMap = {};
              e.forEach((k, v) => safeMap[k.toString()] = v);
              return safeMap;
            }).toList();
          }
          setState(() {
            _allSantri = list;
            _filtered = list;
            _loading = false;
            _error = '';
          });
          _onSearch();
        } else if (state is TahsinError) {
          setState(() {
            _error = state.message;
            _loading = false;
          });
        } else if (state is TahsinLoading) {
          setState(() {
            _loading = true;
            _error = '';
          });
        }
      },
      builder: (context, state) {
        if (_loading && _allSantri.isEmpty)
          return const GlobalSkeletonWidget(itemCount: 8);
        if (_error.isNotEmpty && _allSantri.isEmpty) {
          return GlobalErrorWidget(
            message: _error,
            onRetry: () => _load(forceRefresh: true),
          );
        }
        return _buildBody();
      },
    );
  }

  Widget _buildFilterBar() {
    if (_kelompokList.length <= 1) return const SizedBox.shrink();
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_kelompokList.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kelompokList.map((k) {
                  final id =
                      int.tryParse(k['id_kelompok']?.toString() ?? '0') ?? 0;
                  final nama = k['kelompok']?.toString() ?? '-';
                  final isSel = _selectedKelompokId == id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (!isSel) {
                          setState(() {
                            _selectedKelompokId = id;
                            _selectedKelasId = null;
                            _allSantri = [];
                            _filtered = [];
                          });
                          _load();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? Theme.of(context).colorScheme.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF374151)
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? Theme.of(context).colorScheme.primary
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF4B5563)
                                      : Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          nama,
                          style: TextStyle(
                            color: isSel
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _loading
              ? const GlobalSkeletonWidget(itemCount: 5)
              : _error.isNotEmpty
              ? GlobalErrorWidget(
                  message: _error,
                  onRetry: () => _load(forceRefresh: true),
                )
              : RefreshIndicator(
                  onRefresh: () => _load(forceRefresh: true),
                  color: Theme.of(
                    context,
                  ).extension<AppCustomStyles>()!.success,
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
                                  const Icon(
                                    Icons.person_off_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada data santri.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton.icon(
                                    onPressed: _load,
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: Theme.of(
                                        context,
                                      ).extension<AppCustomStyles>()!.success,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Refresh',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).extension<AppCustomStyles>()!.success,
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
                            return _SantriCard(
                              santri: _filtered[i],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProgressDetailScreen(
                                      santri: _filtered[i],
                                    ),
                                  ),
                                ).then((_) => _load(forceRefresh: false));
                              },
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _SantriCard extends StatelessWidget {
  final Map<String, dynamic> santri;
  final VoidCallback onTap;
  const _SantriCard({required this.santri, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String kelompok = santri['kelompok']?.toString() ?? '-';
    final String kelas = santri['kelas']?.toString() ?? '-';

    String _f(num v) => v.toString().replaceAll(RegExp(r'\.0$'), '');

    // Halaman
    final double capaiHal =
        double.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final double totalHal =
        double.tryParse(santri['total_hal']?.toString() ?? '604') ?? 604;
    final double halMulai =
        double.tryParse(santri['hal_mulai']?.toString() ?? '1') ?? 1;
    final double baseHal = (halMulai > 0) ? halMulai - 1 : 0;
    // ignore: unused_local_variable
    final int pctHal = int.tryParse(santri['pctHal']?.toString() ?? '0') ?? 0;
    // halProgress computed but not used directly in current layout
    // ignore: unused_local_variable
    final double halProgress = totalHal > 0
        ? (capaiHal / totalHal).clamp(0.0, 1.0)
        : 0.0;

    final int cntLulus =
        int.tryParse(santri['cnt_lulus']?.toString() ?? '0') ?? 0;
    final int cntUlang =
        int.tryParse(santri['cnt_ulang']?.toString() ?? '0') ?? 0;

    // Latihan
    final double latSek =
        double.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;
    final double _parsedTargetLat =
        double.tryParse(santri['target_latihan']?.toString() ?? '0') ?? 0;
    final double targetLat = _parsedTargetLat > 0 ? _parsedTargetLat : totalHal;
    // ignore: unused_local_variable
    final double latProgress = targetLat > 0
        ? (latSek / targetLat).clamp(0.0, 1.0)
        : 0.0;
    final bool modeIsLatihan = santri['modeIsLatihan'] == true;

    // Akselerasi
    final int jmlTes = int.tryParse(santri['jml_tes']?.toString() ?? '0') ?? 0;
    final List<dynamic> aksHistory = santri['aks_history'] is List
        ? santri['aks_history']
        : [];
    final double capaiAks =
        double.tryParse(santri['capai_aks']?.toString() ?? '0') ?? 0;
    final double aksProgress = totalHal > 0
        ? (capaiAks / totalHal).clamp(0.0, 1.0)
        : 0.0;
    // ignore: unused_local_variable
    final int pctAks = (aksProgress * 100).round();

    // Kecepatan & Badge
    // Catatan: santri dengan sesi < 3 harus muncul "Belum Terukur" badge grey
    final int totalSesi =
        int.tryParse(santri['total_sesi']?.toString() ?? '0') ??
        (cntLulus + cntUlang);
    final bool isBelumTerukur = totalSesi < 3;
    final String kLabel = isBelumTerukur
        ? 'Belum Terukur'
        : (santri['kLabel']?.toString() ?? '-');

    // Tentukan warna kClr
    String kClrStr = 'grey';
    if (!isBelumTerukur) {
      kClrStr = (santri['kClr']?.toString() ?? 'primary').toLowerCase();
    }

    final double kecAktTotal =
        double.tryParse(santri['kecAktTotal']?.toString() ?? '0') ?? 0.0;

    Color getBadgeColor(String c) {
      if (isBelumTerukur) return Theme.of(context).colorScheme.onSurfaceVariant;
      switch (c) {
        case 'success':
          return Theme.of(context).extension<AppCustomStyles>()!.success;
        case 'info':
          return Theme.of(context).colorScheme.secondary;
        case 'warning':
          return Theme.of(context).extension<AppCustomStyles>()!.warning;
        case 'danger':
          return Theme.of(context).extension<AppCustomStyles>()!.error;
        case 'primary':
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    // ignore: unused_local_variable
    const Color kBlue = Color(0xFF3B82F6);
    const Color kTeal = Color(0xFF14B8A6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).extension<AppCustomStyles>()!.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                // Container(
                //   width: 48,
                //   height: 48,
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).extension<AppCustomStyles>()!.success.withValues(alpha: 0.1),
                //     shape: BoxShape.circle,
                //   ),
                //   alignment: Alignment.center,
                //   child: Text(
                //     (santri['nama_santri'] ?? 'S')[0].toUpperCase(),
                //     style: TextStyle(
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold,
                //       color: Theme.of(context).extension<AppCustomStyles>()!.success,
                //     ),
                //   ),
                // ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      Text(
                        santri['nama_santri'] ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            santri['nis'] ?? '-',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          _chip(
                            kelompok,
                            Theme.of(
                              context,
                            ).extension<AppCustomStyles>()!.success,
                          ),
                          _chip(kelas, Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),

                      // --- HALAMAN ---
                      MultiSegmentProgressBar(
                        title: 'Halaman',
                        icon: Icons.menu_book_rounded,
                        capai: capaiHal,
                        total: totalHal,
                        baseHal: baseHal,
                        checkpoints:
                            santri['checkpoints'] ??
                            santri['checkpoint'] ??
                            santri['t_kelas_checkpoint'] ??
                            santri['check_points'],
                        baseColor: const Color(0xFF6610F2),
                        trailingText: Text(
                          '(${santri['sisa_tm_baku'] ?? 0} TM)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- LATIHAN ---
                      if (!modeIsLatihan && latSek == 0) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              size: 16,
                              color: kTeal,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Latihan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kTeal,
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                'Selesaikan halaman dulu',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        MultiSegmentProgressBar(
                          title: 'Latihan',
                          icon: Icons.edit_note_rounded,
                          capai: latSek,
                          total: targetLat,
                          baseHal: baseHal,
                          checkpoints:
                              santri['checkpoints'] ??
                              santri['checkpoint'] ??
                              santri['t_kelas_checkpoint'] ??
                              santri['check_points'],
                          baseColor: const Color(0xFF14B8A6),
                        ),
                      ],

                      // --- AKSELERASI (HISTORI) ---
                      if (aksHistory.isNotEmpty) ...[
                        for (var item in aksHistory) ...[
                          Builder(
                            builder: (context) {
                              final int sCycle =
                                  int.tryParse(
                                    item['jml_tes']?.toString() ?? '0',
                                  ) ??
                                  0;
                              final double sHal =
                                  double.tryParse(
                                    item['hal_aks']?.toString() ?? '0',
                                  ) ??
                                  0;
                              final int sTm =
                                  int.tryParse(
                                    item['tm_aks']?.toString() ?? '0',
                                  ) ??
                                  0;

                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: MultiSegmentProgressBar(
                                  title: 'Akselerasi $sCycle ($sTm TM)',
                                  icon: Icons.rocket_launch_rounded,
                                  capai: sHal,
                                  total: totalHal,
                                  baseHal: baseHal,
                                  baseColor: const Color(0xFFEA5455),
                                ),
                              );
                            },
                          ),
                        ],
                      ] else if (jmlTes > 0) ...[
                        const SizedBox(height: 16),
                        MultiSegmentProgressBar(
                          title: 'Akselerasi $jmlTes',
                          icon: Icons.rocket_launch_rounded,
                          capai: capaiAks,
                          total: totalHal,
                          baseHal: baseHal,
                          baseColor: const Color(0xFFEA5455),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // --- KECEPATAN (PREDIKSI GABUNGAN) ---
                      Row(
                        children: [
                          const Icon(
                            Icons.speed_rounded,
                            size: 14,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kcpt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (kecAktTotal > 0)
                                  Flexible(
                                    child: Text(
                                      '${_f(double.parse(kecAktTotal.toStringAsFixed(2)))} hal/TM',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (!isBelumTerukur) const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getBadgeColor(
                                      kClrStr,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    kLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: getBadgeColor(kClrStr),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
    ),
  );
}
