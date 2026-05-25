import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/bloc/masalah_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/masalah_widgets.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/features/masalah/domain/repositories/masalah_repository.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/detail_masalah_sheet.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/tambah_masalah_sheet.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';

// --- Design Tokens -------------------------------------------------------------
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);

// Warna per jenis masalah
Color masalahJenisColor(String? jenis) {
  switch (jenis) {
    case 'Kehadiran':
      return const Color(0xFFEF4444);
    case 'Keterlambatan Belajar':
      return const Color(0xFFF59E0B);
    case 'Tidak Disimak di Rumah':
      return const Color(0xFF8B5CF6);
    default:
      return const Color(0xFF6B7280);
  }
}



// --- Screen --------------------------------------------------------------------
// --- Screen --------------------------------------------------------------------
class MasalahScreen extends StatelessWidget {
  final bool isAdmin;
  const MasalahScreen({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MasalahCubit(
        repository: MasalahRepository(
          networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
          localDataSource: LocalDataSourceImpl(),
        ),
        activeKelompokCubit: context.read<ActiveKelompokCubit>(),
      ),
      child: _MasalahView(isAdmin: isAdmin),
    );
  }
}

class _MasalahView extends StatefulWidget {
  final bool isAdmin;
  const _MasalahView({this.isAdmin = false});

  @override
  State<_MasalahView> createState() => _MasalahViewState();
}

class _MasalahViewState extends State<_MasalahView> {
  // Toggle aktif vs selesai
  bool _showAktif = true;

  List<Map<String, dynamic>> _allAktif = [];
  List<Map<String, dynamic>> _allSelesai = [];
  List<Map<String, dynamic>> _filtered = [];

  bool _loading = true;
  String _error = '';

  // Search
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    // Trigger fetch via Cubit setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MasalahCubit>().fetchMasalah(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- Load (via Cubit) ------------------------------------------------------
  Future<void> _load() async {
    context.read<MasalahCubit>().fetchMasalah(forceRefresh: true);
  }

  void _switchTab(bool aktif) {
    if (_showAktif == aktif) return;
    setState(() {
      _showAktif = aktif;
      _filtered = aktif ? _allAktif : _allSelesai;
      if (_searchCtrl.text.isNotEmpty) _applySearch(_searchCtrl.text);
    });
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _applySearch(_searchCtrl.text.trim());
    });
  }

  void _applySearch(String q) {
    final base = _showAktif ? _allAktif : _allSelesai;
    if (q.isEmpty) {
      setState(() => _filtered = base);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      _filtered = base.where((m) {
        final nama = (m['nama_santri'] ?? '').toString().toLowerCase();
        final nis = (m['nis'] ?? '').toString().toLowerCase();
        final jenis = (m['jenis_masalah'] ?? '').toString().toLowerCase();
        return nama.contains(lower) ||
            nis.contains(lower) ||
            jenis.contains(lower);
      }).toList();
    });
  }

  // --- Build ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasalahCubit, MasalahState>(
      listener: (context, state) {
        if (state is MasalahLoaded) {
          setState(() {
            _allAktif = state.aktif;
            _allSelesai = state.selesai;
            _filtered = _showAktif ? _allAktif : _allSelesai;
            _loading = false;
            _error = '';
          });
          if (_searchCtrl.text.isNotEmpty) _applySearch(_searchCtrl.text);
        } else if (state is MasalahError) {
          setState(() {
            _error = state.message;
            _loading = false;
          });
        } else if (state is MasalahLoading) {
          setState(() {
            _loading = true;
            _error = '';
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              if (state is MasalahLoaded && state.isOfflineWarning)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.orange.shade800,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda sedang offline. Menampilkan data lokal.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _loading
                    ? const GlobalSkeletonWidget()
                    : _error.isNotEmpty
                    ? GlobalErrorWidget(message: _error, onRetry: _load)
                    : _buildBody(),
              ),
            ],
          ),
          bottomNavigationBar: _buildCustomBottomNav(),
        );
      },
    );
  }

  // --- AppBar -------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    final aktifCount = _allAktif.length;

    return AppHeaderBar(
      customTitle: _searchOpen
          ? TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Cari nama/NIS/jenis...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (_) => _onSearch(),
            )
          : null,
      title: 'Masalah Santri',
      subtitle: _searchOpen ? '' : 'Pantau & tangani permasalahan',
      height: 48,
      actions: [
        if (!_searchOpen && _showAktif)
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
            ),
            tooltip: 'Tambah Masalah',
            onPressed: _showTambahMasalahSheet,
          ),
        IconButton(
          icon: Icon(
            _searchOpen ? Icons.close_rounded : Icons.search_rounded,
            color: Colors.white,
          ),
          tooltip: 'Pencarian',
          onPressed: () {
            if (_searchOpen) {
              _searchCtrl.clear();
              setState(() {
                _searchOpen = false;
                _filtered = _showAktif ? _allAktif : _allSelesai;
              });
            } else {
              setState(() {
                _searchOpen = true;
              });
            }
          },
        ),
        if (aktifCount > 0 && !_searchOpen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).extension<AppCustomStyles>()?.error ??
                  Colors.red.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '$aktifCount aktif',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // --- Custom Bottom Nav --------------------------------------------------------
  Widget _buildCustomBottomNav() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 2,
        left: 4,
        right: 4,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            true,
            Icons.warning_amber_rounded,
            'Aktif',
            _allAktif.length,
          ),
          _buildNavItem(
            false,
            Icons.check_circle_outline_rounded,
            'Selesai',
            _allSelesai.length,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    bool isAktifType,
    IconData icon,
    String label,
    int count,
  ) {
    final isSelected = _showAktif == isAktifType;
    final clr = isAktifType ? Colors.red.shade400 : _kAccent;
    final primaryThemeColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () {
          _switchTab(isAktifType);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                      ? clr.withValues(alpha: 0.15)
                      : clr.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? clr : Colors.grey, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : primaryThemeColor)
                      : Colors.grey,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? clr : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }



  // --- Body ---------------------------------------------------------------------
  Widget _buildBody() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showAktif
                  ? Icons.check_circle_outline_rounded
                  : Icons.history_toggle_off_rounded,
              size: 72,
              color: _showAktif ? _kAccent : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _showAktif
                  ? 'Tidak ada masalah aktif'
                  : 'Belum ada masalah selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kText1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _showAktif
                  ? 'Alhamdulillah, semua santri dalam kondisi baik!'
                  : '',
              style: TextStyle(fontSize: 12, color: _kText2),
              textAlign: TextAlign.center,
            ),
            if (_showAktif) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kAccent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: _showTambahMasalahSheet,
                icon: const Icon(Icons.add_rounded, color: _kAccent, size: 18),
                label: Text(
                  'Tambah Masalah',
                  style: TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _kAccent,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => MasalahCard(
          item: _filtered[i],
          isAktif: _showAktif,
          onTap: () => _showDetailSheet(_filtered[i]),
        ),
      ),
    );
  }

  // --- Bottom Sheet: Detail & Aksi ----------------------------------------------
  void _showDetailSheet(Map<String, dynamic> item) {
    // Capture cubit ref BEFORE opening the sheet so it survives async gaps
    final cubit = context.read<MasalahCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Do NOT override backgroundColor here – let bottomSheetTheme handle AMOLED color
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: DetailMasalahSheet(
          item: item,
          isAktif: _showAktif,
          isAdmin: widget.isAdmin,
          onRefresh: _load,
        ),
      ),
    );
  }

  // --- Bottom Sheet: Tambah Masalah ---------------------------------------------
  void _showTambahMasalahSheet() {
    // Capture cubit ref BEFORE opening the sheet
    final cubit = context.read<MasalahCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Do NOT override backgroundColor here – let bottomSheetTheme handle AMOLED color
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: TambahMasalahSheet(onSaved: _load),
      ),
    );
  }
}





