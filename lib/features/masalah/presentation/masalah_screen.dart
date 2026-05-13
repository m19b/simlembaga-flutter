import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/bloc/masalah_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/masalah_widgets.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/features/masalah/domain/repositories/masalah_repository.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';

// --- Design Tokens -------------------------------------------------------------
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
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

IconData _jenisIcon(String? jenis) {
  switch (jenis) {
    case 'Kehadiran':
      return Icons.event_busy_rounded;
    case 'Keterlambatan Belajar':
      return Icons.trending_down_rounded;
    case 'Tidak Disimak di Rumah':
      return Icons.hearing_disabled_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

String _jenisLabel(String? jenis) => jenis ?? 'Lainnya';

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
          networkInfo: NetworkInfoImpl(InternetConnectionChecker.instance),
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

class _MasalahViewState extends State<_MasalahView>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _searchAnim;
  late Animation<double> _searchScale;

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _searchScale = CurvedAnimation(
      parent: _searchAnim,
      curve: Curves.easeOutCubic,
    );
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
    _searchAnim.dispose();
    super.dispose();
  }

  // --- Load (via Cubit) ------------------------------------------------------
  Future<void> _load() async { context.read<MasalahCubit>().fetchMasalah(forceRefresh: true); }


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

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchAnim.forward();
    } else {
      _searchAnim.reverse();
      _searchCtrl.clear();
      setState(() => _filtered = _showAktif ? _allAktif : _allSelesai);
    }
  }

  // --- Build ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasalahCubit, MasalahState>(
      listener: (context, state) {
        if (state is MasalahLoaded) {
          setState(() {
            _allAktif   = state.aktif;
            _allSelesai = state.selesai;
            _filtered   = _showAktif ? _allAktif : _allSelesai;
            _loading    = false;
            _error      = '';
          });
          if (_searchCtrl.text.isNotEmpty) _applySearch(_searchCtrl.text);
        } else if (state is MasalahError) {
          setState(() { _error = state.message; _loading = false; });
        } else if (state is MasalahLoading) {
          setState(() { _loading = true; _error = ''; });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: _loading
              ? _buildSkeleton()
              : _error.isNotEmpty
                  ? _buildError()
                  : _buildBody(),
          floatingActionButton: _buildFabs(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  // --- AppBar -------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    final aktifCount = _allAktif.length;
    final selesaiCount = _allSelesai.length;

    return PreferredSize(
      preferredSize: const Size.fromHeight(116),
      child: Container(
        color: _kHeader,
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masalah Santri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Pantau & tangani permasalahan',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge aktif
                        if (aktifCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Toggle Pill
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MasalahTogglePill(
                      isAktif: _showAktif,
                      aktifCount: aktifCount,
                      selesaiCount: selesaiCount,
                      onSwitch: _switchTab,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deco(double size, double bw) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withAlpha(18), width: bw),
    ),
  );

  // --- FABs ---------------------------------------------------------------------
  Widget _buildFabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search bar popup
        AnimatedBuilder(
          animation: _searchScale,
          builder: (_, __) => Transform.scale(
            scale: _searchScale.value,
            alignment: Alignment.bottomRight,
            child: Opacity(
              opacity: _searchScale.value.clamp(0.0, 1.0),
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(fontSize: 14, color: _kText1),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, NIS, atau jenisï¿½',
                    hintStyle: TextStyle(color: _kText2, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _kAccent,
                      size: 20,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: _kText2,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(
                                () => _filtered = _showAktif
                                    ? _allAktif
                                    : _allSelesai,
                              );
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Tombol-tombol FAB
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tambah masalah ï¿½ hanya di tab aktif
            if (!_searchOpen && _showAktif)
              FloatingActionButton.extended(
                heroTag: 'tambah',
                onPressed: () => _showTambahMasalahSheet(),
                backgroundColor: _kHeader,
                elevation: 4,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Tambah Masalah',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            if (!_searchOpen && _showAktif) const SizedBox(width: 12),
            // Search FAB
            FloatingActionButton(
              heroTag: 'search',
              onPressed: _toggleSearch,
              backgroundColor: _searchOpen ? Colors.red.shade400 : _kAccent,
              elevation: 4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                  key: ValueKey(_searchOpen),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Skeleton -----------------------------------------------------------------
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: 6,
      itemBuilder: (_, i) => MasalahSkeletonCard(key: ValueKey(i)),
    );
  }

  // --- Error --------------------------------------------------------------------
  Widget _buildError() {
    final isSession =
        _error.toLowerCase().contains('sesi') ||
        _error.toLowerCase().contains('login');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSession ? Icons.lock_outline_rounded : Icons.wifi_off_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: _kText2),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _DetailSheet(item: item, isAktif: _showAktif, isAdmin: widget.isAdmin, onRefresh: _load),
    );
  }

  // --- Bottom Sheet: Tambah Masalah ---------------------------------------------
  void _showTambahMasalahSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TambahMasalahSheet(onSaved: _load),
    );
  }
}

// --- Toggle Pill ---------------------------------------------------------------
class _DetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isAktif;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const _DetailSheet({
    required this.item,
    required this.isAktif,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  bool _saving = false;
  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _tandaiSelesai() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<MasalahCubit>().repository.updateMasalah({
        'id': (widget.item['id_masalah'] ?? widget.item['id']).toString(),
        'status': 'selesai',
        'tgl_selesai': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'catatan_selesai': _catatanCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masalah ditandai selesai',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _kAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jenis = widget.item['jenis_masalah']?.toString();
    final barClr = masalahJenisColor(jenis);
    final nama = widget.item['nama_santri']?.toString() ?? '-';
    final nis = widget.item['nis']?.toString() ?? '';
    final kelas =
        widget.item['kelas']?.toString() ??
        widget.item['tingkat']?.toString() ??
        '';
    final keterangan =
        widget.item['deskripsi']?.toString() ??
        widget.item['keterangan']?.toString() ??
        '';
    final tgl =
        widget.item['tgl_masalah']?.toString() ??
        widget.item['tgl_deteksi']?.toString() ??
        '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: barClr.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: barClr.withAlpha(22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _jenisIcon(jenis),
                            color: barClr,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _kText1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: [
                                  MasalahChip(icon: Icons.badge_outlined, text: nis),
                                  if (kelas.isNotEmpty)
                                    MasalahChip(
                                      icon: Icons.school_outlined,
                                      text: kelas,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        MasalahJenisBadge(jenis: jenis),
                        const Spacer(),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: _kText2,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tgl,
                          style: TextStyle(
                            fontSize: 12,
                            color: _kText2,
                          ),
                        ),
                      ],
                    ),
                    if (keterangan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          keterangan,
                          style: TextStyle(
                            fontSize: 13,
                            color: _kText1,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Aksi (Hanya tampil jika masalah masih aktif DAN user adalah admin)
              // Histori Penanganan
              if (widget.item['tahap_penyelesaian'] is List &&
                  (widget.item['tahap_penyelesaian'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histori Penanganan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kText1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Expandable List
                      ...((widget.item['tahap_penyelesaian'] as List).whereType<Map>().map((tahap) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: ExpansionTile(
                            shape: const Border(),
                            title: Text(
                              tahap['jenis_penyelesaian']?.toString() ?? 'Tindakan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              tahap['tgl_penyelesaian']?.toString() ?? '',
                              style: TextStyle(fontSize: 11, color: _kText2),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  tahap['keterangan']?.toString() ?? '-',
                                  style: TextStyle(fontSize: 13, color: _kText1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Hasil: ${tahap['hasil_tahap']?.toString() ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ),
                ),

              // Aksi (Tambah Tindakan / Selesai)
              if (widget.isAktif) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _kAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showTambahTindakanSheet(context, (widget.item['id_masalah'] ?? widget.item['id']).toString(), widget.onRefresh);
                      },
                      icon: const Icon(Icons.add_task_rounded, color: _kAccent, size: 18),
                      label: Text(
                        'Tambah Tindakan',
                        style: TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.isAdmin) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _catatanCtrl,
                    maxLines: 3,
                    style: TextStyle(fontSize: 14, color: _kText1),
                    decoration: InputDecoration(
                      labelText: 'Catatan penyelesaian (opsional)',
                      labelStyle: TextStyle(
                        color: _kText2,
                        fontSize: 13,
                      ),
                      hintText: 'Tulis catatan atau tindakan yang dilakukanï¿½',
                      hintStyle: TextStyle(
                        color: _kText2,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: _kAccent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _saving ? null : _tandaiSelesai,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      label: Text(
                        _saving ? 'Menyimpanï¿½' : 'Tandai Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTambahTindakanSheet(BuildContext context, String idMasalah, VoidCallback onRefresh) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TambahTindakanSheet(idMasalah: idMasalah, onSaved: onRefresh),
  );
}

class _TambahTindakanSheet extends StatefulWidget {
  final String idMasalah;
  final VoidCallback onSaved;
  const _TambahTindakanSheet({required this.idMasalah, required this.onSaved});

  @override
  State<_TambahTindakanSheet> createState() => _TambahTindakanSheetState();
}

class _TambahTindakanSheetState extends State<_TambahTindakanSheet> {
  final _keteranganCtrl = TextEditingController();
  String? _jenisPenyelesaian;
  String? _hasilTahap;
  DateTime _tglPenyelesaian = DateTime.now();
  bool _saving = false;

  static const _jenisOptions = [
    'Via Chat/Telepon',
    'Kunjungan ke Rumah',
    'Pemanggilan Orang Tua',
    'Konseling Langsung',
    'Lainnya'
  ];

  static const _hasilOptions = [
    'Belum Ada Perubahan',
    'Ada Perbaikan',
    'Masalah Terselesaikan'
  ];

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_jenisPenyelesaian == null || _hasilTahap == null || _keteranganCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lengkapi semua field!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<MasalahCubit>().repository.storeTahapMasalah({
        'id_masalah': widget.idMasalah,
        'jenis_penyelesaian': _jenisPenyelesaian!,
        'tgl_penyelesaian': DateFormat('yyyy-MM-dd').format(_tglPenyelesaian),
        'keterangan': _keteranganCtrl.text.trim(),
        'hasil_tahap': _hasilTahap!,
      });

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tindakan berhasil ditambahkan',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      String errMsg = e.toString().replaceAll('Exception: ', '');
      
      // Khusus untuk error 403 atau Akses Ditolak
      if (errMsg.toLowerCase().contains('akses ditolak') || errMsg.contains('403')) {
        errMsg = 'Akses Ditolak: Anda tidak memiliki izin untuk menambahkan tindakan pada masalah ini.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errMsg,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tambah Tindakan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              // Filter Dropdown: Jenis Penyelesaian
              DropdownButtonFormField<String>(
                value: _jenisPenyelesaian,
                decoration: InputDecoration(
                  labelText: 'Jenis Penyelesaian',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _jenisOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _jenisPenyelesaian = val),
              ),
              const SizedBox(height: 16),
              // TextField: Tgl Penyelesaian
              InkWell(
                onTap: () async {
                  final dt = await showDatePicker(
                    context: context,
                    initialDate: _tglPenyelesaian,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (dt != null) {
                    setState(() => _tglPenyelesaian = dt);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Penyelesaian',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_tglPenyelesaian)),
                ),
              ),
              const SizedBox(height: 16),
              // TextField: Keterangan
              TextField(
                controller: _keteranganCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Keterangan / Intisari',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              // Dropdown: Hasil Tahap
              DropdownButtonFormField<String>(
                value: _hasilTahap,
                decoration: InputDecoration(
                  labelText: 'Hasil Tahap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _hasilOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _hasilTahap = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Simpan Tindakan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Tambah Masalah Sheet ------------------------------------------------------
class _TambahMasalahSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _TambahMasalahSheet({required this.onSaved});

  @override
  State<_TambahMasalahSheet> createState() => _TambahMasalahSheetState();
}

class _TambahMasalahSheetState extends State<_TambahMasalahSheet> {
  final _formKey = GlobalKey<FormState>();

  // Autocomplete santri
  final _nisCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  String? _selectedNis;
  List<Map<String, dynamic>> _santriSuggest = [];
  Timer? _suggTimer;
  bool _loadingSugg = false;

  String? _jenisMasalah;
  DateTime _tglMasalah = DateTime.now();
  bool _saving = false;

  static const _jenisList = [
    'Kehadiran',
    'Keterlambatan Belajar',
    'Tidak Disimak di Rumah',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nisCtrl.dispose();
    _namaCtrl.dispose();
    _keteranganCtrl.dispose();
    _suggTimer?.cancel();
    super.dispose();
  }

  void _onNisChanged(String val) {
    if (_selectedNis != null) setState(() => _selectedNis = null);
    _suggTimer?.cancel();
    if (val.trim().length < 3) {
      setState(() => _santriSuggest = []);
      return;
    }
    _suggTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _loadingSugg = true);
      try {
        final res = await ApiService.cariSantri(val.trim()); // intentional: generic santri search
        if (!mounted) return;
        setState(() {
          _santriSuggest = res;
          _loadingSugg = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _santriSuggest = [];
          _loadingSugg = false;
        });
      }
    });
  }

  void _pilihSantri(Map<String, dynamic> s) {
    setState(() {
      _selectedNis = s['nis']?.toString();
      _nisCtrl.text = s['nis']?.toString() ?? '';
      _namaCtrl.text = s['nama_santri']?.toString() ?? '';
      _santriSuggest = [];
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih santri dari daftar saran',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<MasalahCubit>().repository.storeMasalah({
        'nis': _selectedNis!,
        'jenis_masalah': _jenisMasalah!,
        'keterangan': _keteranganCtrl.text.trim(),
        'tgl_masalah': DateFormat('yyyy-MM-dd').format(_tglMasalah),
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masalah berhasil dicatat',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _kAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      // Cek apakah perlu approval
      final msg = e.toString().replaceAll('Exception: ', '');
      final isApproval =
          msg.toLowerCase().contains('approval') ||
          msg.toLowerCase().contains('persetujuan') ||
          msg.toLowerCase().contains('pending');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproval
                ? 'Masalah diajukan dan menunggu persetujuan admin.'
                : msg,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: isApproval
              ? Colors.orange.shade600
              : Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      if (isApproval) {
        Navigator.pop(context);
        widget.onSaved();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // Header sheet
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _kHeader.withAlpha(18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: _kHeader,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catat Masalah Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _kText1,
                            ),
                          ),
                          Text(
                            'Isi form di bawah dengan lengkap',
                            style: TextStyle(
                              fontSize: 12,
                              color: _kText2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Cari santri
                      _FormLabel('Santri'),
                      TextFormField(
                        controller: _nisCtrl,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9 ]'),
                          ),
                        ],
                        style: TextStyle(fontSize: 14, color: _kText1),
                        decoration: _inputDeco(
                          hint: 'Ketik NIS atau nama santriï¿½',
                          icon: Icons.person_search_rounded,
                          suffix: _loadingSugg
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _kAccent,
                                  ),
                                )
                              : _selectedNis != null
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: _kAccent,
                                  size: 18,
                                )
                              : null,
                        ),
                        onChanged: _onNisChanged,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      // Saran santri
                      if (_santriSuggest.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _santriSuggest.take(5).map((s) {
                              final nama = s['nama_santri']?.toString() ?? '';
                              final nis = s['nis']?.toString() ?? '';
                              final kelas = s['tingkat']?.toString() ?? '';
                              return InkWell(
                                onTap: () => _pilihSantri(s),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: _kAccent.withAlpha(18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: _kAccent,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nama,
                                              style:
                                                  TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: _kText1,
                                                  ),
                                            ),
                                            Text(
                                              '$nis ï¿½ $kelas',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _kText2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (_selectedNis != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _kAccent.withAlpha(14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: _kAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _namaCtrl.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _kAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      // Jenis masalah
                      _FormLabel('Jenis Masalah'),
                      DropdownButtonFormField<String>(
                        value: _jenisMasalah,
                        isExpanded: true,
                        hint: Text(
                          'Pilih jenis masalah',
                          style: TextStyle(
                            color: _kText2,
                            fontSize: 13,
                          ),
                        ),
                        style: TextStyle(fontSize: 14, color: _kText1),
                        decoration: _inputDeco(
                          hint: '',
                          icon: Icons.category_outlined,
                        ).copyWith(hintText: null),
                        items: _jenisList
                            .map(
                              (j) => DropdownMenuItem(
                                value: j,
                                child: Row(
                                  children: [
                                    Icon(
                                      _jenisIcon(j),
                                      size: 16,
                                      color: masalahJenisColor(j),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(j),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _jenisMasalah = v),
                        validator: (v) =>
                            v == null ? 'Pilih jenis masalah' : null,
                      ),
                      const SizedBox(height: 14),
                      // Tanggal
                      _FormLabel('Tanggal Deteksi'),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _tglMasalah,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (ctx, child) => Theme(
                              data: Theme.of(ctx).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: _kHeader,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setState(() => _tglMasalah = d);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: _kAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat(
                                  'EEEE, d MMMM yyyy',
                                  'id_ID',
                                ).format(_tglMasalah),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _kText1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Keterangan
                      _FormLabel('Keterangan / Deskripsi'),
                      TextFormField(
                        controller: _keteranganCtrl,
                        maxLines: 4,
                        style: TextStyle(fontSize: 14, color: _kText1),
                        decoration: _inputDeco(
                          hint: 'Tuliskan detail masalah yang terdeteksiï¿½',
                          icon: Icons.notes_rounded,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Keterangan wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Tombol simpan
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kHeader,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _saving ? null : _simpan,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          label: Text(
                            _saving ? 'Menyimpanï¿½' : 'Simpan Masalah',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Form helpers --------------------------------------------------------------
Widget _FormLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _kText2,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}

InputDecoration _inputDeco({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _kText2, fontSize: 13),
    prefixIcon: Icon(icon, color: _kAccent, size: 18),
    suffixIcon: suffix != null
        ? Padding(padding: const EdgeInsets.all(12), child: suffix)
        : null,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
    ),
  );
}