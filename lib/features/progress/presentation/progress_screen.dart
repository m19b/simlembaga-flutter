import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'progress_detail_screen.dart';
import 'progress_input_screen.dart';
import 'riwayat_global_tab.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_cubit.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_state.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/data/catatan_master_model.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/widgets/catatan_form_sheet.dart';
import 'package:flutter/services.dart';
import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/bloc/tahsin_cubit.dart';
import 'package:manajemen_tahsin_app/shared/widgets/multi_segment_progress_bar.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_field.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';

import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';

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
        BlocProvider(create: (_) => CatatanMasterCubit()),
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
  final GlobalKey<ProgressInputScreenState> _inputKey = GlobalKey<ProgressInputScreenState>();

  final GlobalKey<RiwayatGlobalTabState> _riwayatKey = GlobalKey<RiwayatGlobalTabState>();
  DateTime _riwayatTanggal = DateTime.now();

  // ValueNotifier untuk tab index — menghindari setState penuh setiap kali tab berubah
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  void _showCatatanForm(BuildContext context, {
    CatatanMaster? item,
    required Map<String, dynamic> filterMeta,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<CatatanMasterCubit>(),
        child: CatatanFormSheet(item: item, filterMeta: filterMeta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Stack(
                children: [
                  const Positioned.fill(
                    child: GlobalHeaderBackground(),
                  ),
                  // ── AppBar content ────────────────────────────────────
                  AppBar(
                    toolbarHeight: 48,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    titleSpacing: 0, // Geser judul ke kiri
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                    actionsIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                    centerTitle: false,
              title: ValueListenableBuilder<int>(
                valueListenable: _tabIndexNotifier,
                builder: (context, tabIdx, _) {
                  return _isSearchOpen && tabIdx == 0
                    ? TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari Santri...',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _isSearchOpen = false);
                            },
                          ),
                        ),
                      )
                    : Text(
                        tabIdx == 0 ? 'Progres'
                          : tabIdx == 1 ? 'Input Evaluasi'
                          : tabIdx == 2 ? 'Riwayat Kelas'
                          : 'Catatan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).extension<AppCustomStyles>()!.headerBorder),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        popupMenuTheme: PopupMenuThemeData(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: Theme.of(context).extension<AppCustomStyles>()!.headerBorder),
                                          ),
                                        ),
                                      ),
                                      child: DropdownButton<int?>(
                                        value: selectedKelasId,
                                        isDense: true,
                                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Theme.of(context).colorScheme.primary,
                                        icon: Icon(Icons.arrow_drop_down, size: 16, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        onChanged: (val) => _selectedKelasNotifier.value = val,
                                        items: [
                                          const DropdownMenuItem<int?>(value: null, child: Text('Semua')),
                                          ...kelasList.map((k) {
                                            final id = int.tryParse(k['id_kelas']?.toString() ?? '0') ?? 0;
                                            final t = k['tingkat']?.toString() ?? '-';
                                            return DropdownMenuItem<int?>(value: id, child: Text(t));
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
                          child: ElevatedButton.icon(
                            onPressed: () => _inputKey.currentState?.simpan(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 32),
                            ),
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      if (tabIdx == 3)
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          tooltip: 'Tambah Catatan',
                          onPressed: () {
                            final state = context.read<CatatanMasterCubit>().state;
                            if (state is CatatanMasterLoaded) {
                              _showCatatanForm(context, filterMeta: state.filterMeta);
                            } else if (state is CatatanMasterActionProgress) {
                              _showCatatanForm(context, filterMeta: state.filterMeta);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
                  ),
                  // ── Garis putih pembatas bawah ────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ],
              ),
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
            ),const _CatatanEmbeddedTab(),
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
            Expanded(child: _buildNavItem(0, Icons.bar_chart_rounded, 'Progress', tabIdx)),
            Expanded(child: _buildNavItem(1, Icons.edit_document, 'Input', tabIdx)),
            Expanded(child: _buildNavItem(2, Icons.history_edu, 'Riwayat', tabIdx)),
            Expanded(child: _buildNavItem(3, Icons.sticky_note_2_outlined, 'Catatan', tabIdx)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int currentTabIdx) {
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
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
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
                          ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).colorScheme.primary) 
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
      builder: (context) => const _SendReportBottomSheet(),
    );
  }
}

class _SendReportBottomSheet extends StatefulWidget {
  const _SendReportBottomSheet();

  @override
  State<_SendReportBottomSheet> createState() => _SendReportBottomSheetState();
}

class _SendReportBottomSheetState extends State<_SendReportBottomSheet> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _sending = false;

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      final df = DateFormat('yyyy-MM-dd');
      final res = await ApiService.sendKolektifWaReport(
        tglMulai: df.format(_startDate),
        tglAkhir: df.format(_endDate),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dfDisplay = DateFormat('dd MMM yyyy');
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Text(
                'Kirim Laporan Perbandingan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan ini berisi perbandingan performa seluruh santri di kelas Anda dalam periode tertentu.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Periode Laporan:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${dfDisplay.format(_startDate)} - ${dfDisplay.format(_endDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Kirim Laporan ke WA Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
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
        _selectedKelompokId = int.tryParse(activeState.allowedKelompok.first['id_kelompok']?.toString() ?? '0');
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

            dynamic globalCheckpoints = raw['checkpoints'] ?? raw['t_kelas_checkpoint'];
            if (globalCheckpoints is String) {
              try { globalCheckpoints = jsonDecode(globalCheckpoints); } catch (_) {}
            }

            final rawList = raw['santri_list'];
            if (rawList is List && rawList.isNotEmpty) {
              list = rawList.whereType<Map>().map((e) {
                final Map<String, dynamic> safeMap = {};
                e.forEach((k, v) => safeMap[k.toString()] = v);
                if (globalCheckpoints != null && safeMap['checkpoints'] == null) {
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
      itemBuilder: (_, i) => const _SkeletonCard(),
    );
  }

  Widget _buildError() {
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).extension<AppCustomStyles>()!.success),
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
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
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.6),
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
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
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
                                  const Icon(
                                    Icons.person_off_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada data santri.',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton.icon(
                                    onPressed: _load,
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: Theme.of(context).extension<AppCustomStyles>()!.success,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Refresh',
                                      style: TextStyle(color: Theme.of(context).extension<AppCustomStyles>()!.success),
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
        border: Border.all(color: Theme.of(context).extension<AppCustomStyles>()!.cardBorder),
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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          _chip(kelompok, Theme.of(context).extension<AppCustomStyles>()!.success),
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
                        checkpoints: santri['checkpoints'] ?? santri['checkpoint'] ?? santri['t_kelas_checkpoint'] ?? santri['check_points'],
                        baseColor: const Color(0xFF6610F2),
                        trailingText: Text(
                          '(${santri['sisa_tm_baku'] ?? 0} TM)',
                          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
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
                          checkpoints: santri['checkpoints'] ?? santri['checkpoint'] ?? santri['t_kelas_checkpoint'] ?? santri['check_points'],
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

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(_ctrl);
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
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).extension<AppCustomStyles>()!.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(Theme.of(context).extension<AppCustomStyles>()!.shimmerBase, Theme.of(context).extension<AppCustomStyles>()!.shimmerHighlight, _anim.value),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    color: Color.lerp(Theme.of(context).extension<AppCustomStyles>()!.shimmerBase, Theme.of(context).extension<AppCustomStyles>()!.shimmerHighlight, _anim.value),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 160,
                    color: Color.lerp(Theme.of(context).extension<AppCustomStyles>()!.shimmerBase, Theme.of(context).extension<AppCustomStyles>()!.shimmerHighlight, _anim.value),
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

// --- Tab Catatan (Embedded tanpa UserModel, konten sama dengan CatatanMasterScreen) ------
class _CatatanEmbeddedTab extends StatefulWidget {
  const _CatatanEmbeddedTab();

  @override
  State<_CatatanEmbeddedTab> createState() => _CatatanEmbeddedTabState();
}

class _CatatanEmbeddedTabState extends State<_CatatanEmbeddedTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int? _selectedKelasId;
  int? _selectedKelompokId;
  final TextEditingController _searchCtrl = TextEditingController();
  List<CatatanMaster> _filteredList = [];
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<CatatanMasterCubit>().loadCatatan();
    _searchCtrl.addListener(
      () => _updateFilteredList(context.read<CatatanMasterCubit>().state),
    );
  }

  void _updateFilteredList(dynamic state) {
    if (state is CatatanMasterLoaded) {
      final query = _searchCtrl.text.toLowerCase();
      setState(() {
        _filteredList = query.isEmpty
            ? state.catatan
            : state.catatan
                  .where((c) => c.teksCatatan.toLowerCase().contains(query))
                  .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showForm({
    CatatanMaster? item,
    required Map<String, dynamic> filterMeta,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<CatatanMasterCubit>(),
        child: CatatanFormSheet(item: item, filterMeta: filterMeta),
      ),
    );
  }

  void _confirmDelete(CatatanMaster item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Hapus Catatan?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${item.teksCatatan}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.read<CatatanMasterCubit>().deleteCatatan(item.idCatatan);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
              elevation: 0,
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<CatatanMasterCubit, dynamic>(
        listener: (context, state) {
          if (state is CatatanMasterLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.message!.contains('Error')
                    ? Colors.red
                    : Theme.of(context).extension<AppCustomStyles>()!.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CatatanMasterLoading || state is CatatanMasterInitial) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: SkeletonListWidget(itemCount: 8, itemHeight: 80),
            );
          }
          if (state is CatatanMasterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CatatanMasterCubit>().loadCatatan(),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).extension<AppCustomStyles>()!.success),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          Map<String, dynamic> filterMeta = {};

          if (state is CatatanMasterLoaded ||
              state is CatatanMasterActionProgress) {
            filterMeta = state is CatatanMasterLoaded
                ? state.filterMeta
                : (state as CatatanMasterActionProgress).filterMeta;

            if (state is CatatanMasterLoaded) {
              final query = _searchCtrl.text.toLowerCase();
              _filteredList = query.isEmpty
                  ? state.catatan
                  : state.catatan
                        .where(
                          (c) => c.teksCatatan.toLowerCase().contains(query),
                        )
                        .toList();
            }
          }

          return Column(
            children: [
              // -- Filter Bar --
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    if (!_isSearchExpanded)
                      Expanded(
                        child: _buildFilters(filterMeta),
                      ),
                    if (!_isSearchExpanded) const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _isSearchExpanded
                          ? MediaQuery.of(context).size.width - 24
                          : 40,
                      child: _isSearchExpanded
                          ? SizedBox(
                              height: 36,
                              child: TextField(
                                controller: _searchCtrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Cari catatan...',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _isSearchExpanded = false);
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF374151)
                                      : Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 12,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF374151)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.search, size: 20),
                                onPressed: () {
                                  setState(() => _isSearchExpanded = true);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              // -- List --
              Expanded(
                child: RefreshIndicator(
                  color: Theme.of(context).extension<AppCustomStyles>()?.success ?? Colors.green,
                  onRefresh: () =>
                      context.read<CatatanMasterCubit>().loadCatatan(
                        idKelas: _selectedKelasId,
                        idKelompok: _selectedKelompokId,
                      ),
                  child: _filteredList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada catatan ditemukan',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final item = _filteredList[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _showForm(
                                  item: item,
                                  filterMeta: filterMeta,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.teksCatatan,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (item.aktif
                                                          ? Colors.green
                                                          : Colors.grey)
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color:
                                                    (item.aktif
                                                            ? Colors.green
                                                            : Colors.grey)
                                                        .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              item.aktif ? 'AKTIF' : 'NONAKTIF',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: item.aktif
                                                    ? Colors.green.shade700
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.school_outlined,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.namaKelompok} • ${item.namaKelas}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Urutan: ${item.urutan}',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(height: 1),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () =>
                                                _confirmDelete(item),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 0,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton.icon(
                                            onPressed: () => _showForm(
                                              item: item,
                                              filterMeta: filterMeta,
                                            ),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(Map<String, dynamic> meta) {
    List<Map<String, dynamic>> safeMeta(dynamic raw) {
      if (raw is! List) return [];
      return raw.whereType<Map>().map((e) {
        final Map<String, dynamic> m = {};
        e.forEach((k, v) => m[k.toString()] = v);
        return m;
      }).toList();
    }

    final isAdmin = meta['is_admin'] == true;
    final kelompokList = safeMeta(meta['kelompok_list']);
    final kelasList = safeMeta(meta['kelas_list']);

    return Row(
      children: [
        if (isAdmin && kelompokList.length > 1) ...[
          Expanded(
            child: _buildDropdown(
              'Kelompok',
              _selectedKelompokId,
              kelompokList,
              'id_kelompok',
              (v) {
                setState(() {
                  _selectedKelompokId = v;
                  _selectedKelasId = null;
                });
                context.read<CatatanMasterCubit>().loadCatatan(idKelompok: v);
              },
            ),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: _buildDropdown(
            'Kelas',
            _selectedKelasId,
            kelasList,
            'id_kelas',
            (v) {
              setState(() => _selectedKelasId = v);
              context.read<CatatanMasterCubit>().loadCatatan(
                idKelompok: _selectedKelompokId,
                idKelas: v,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    int? value,
    List<Map<String, dynamic>> items,
    String idField,
    ValueChanged<int?> onChanged,
  ) {
    final bool valueExists =
        value == null ||
        items.any(
          (item) => int.tryParse(item[idField]?.toString() ?? '') == value,
        );
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF374151)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: valueExists ? value : null,
          isExpanded: true,
          isDense: true,
          hint: Text('Semua $label', style: const TextStyle(fontSize: 11)),
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text('Semua $label', style: const TextStyle(fontSize: 11)),
            ),
            ...items.map(
              (item) => DropdownMenuItem<int>(
                value: int.tryParse(item[idField]?.toString() ?? '0'),
                child: Text(
                  item['kelompok']?.toString() ??
                      item['tingkat']?.toString() ??
                      '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
