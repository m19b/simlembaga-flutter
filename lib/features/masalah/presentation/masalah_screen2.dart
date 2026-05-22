import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

// --- Design Tokens -------------------------------------------------------------
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);

// Warna per jenis masalah
Color _jenisColor(String? jenis) {
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
class MasalahScreen extends StatefulWidget {
  final bool isAdmin;
  const MasalahScreen({super.key, this.isAdmin = false});

  @override
  State<MasalahScreen> createState() => _MasalahScreenState();
}

class _MasalahScreenState extends State<MasalahScreen>
    with TickerProviderStateMixin {
  // Tab: 0=Aktif, 1=Selesai, 2=Approval
  late TabController _tabController;

  List<Map<String, dynamic>> _allAktif = [];
  List<Map<String, dynamic>> _allSelesai = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _error = '';

  // Filter
  List<Map<String, dynamic>> _kelompokList = [];
  List<Map<String, dynamic>> _kelasList = [];
  int? _selectedKelompokId;
  int? _selectedKelasId;

  // Approval
  List<Map<String, dynamic>> _approvalList = [];
  bool _approvalLoading = false;
  String _approvalError = '';
  bool _approvalLoaded = false;

  // Search
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchCtrl.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_searchOpen) {
      setState(() {
        _searchOpen = false;
        _searchCtrl.clear();
      });
    }
    setState(() {
      _filtered = _tabController.index == 0 ? _allAktif : _allSelesai;
    });
    if (_tabController.index == 2 && !_approvalLoaded) {
      _loadApproval();
    }
  }

  // --- Load Masalah -----------------------------------------------------------
  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final results = await Future.wait([
        ApiService.getMasalahAktif(idKelompok: _selectedKelompokId, idKelas: _selectedKelasId),
        ApiService.getMasalahSelesai(idKelompok: _selectedKelompokId, idKelas: _selectedKelasId),
      ]);

      List<Map<String, dynamic>> _parse(dynamic resp, bool isFirstLoad) {
        final raw = resp['data'];
        if (raw is Map) {
          if (isFirstLoad) {
            final meta = raw['meta'];
            if (meta is Map) {
              final kl = meta['kelompok_list'];
              if (kl is List) {
                _kelompokList = kl.whereType<Map>().map((e) {
                  final Map<String, dynamic> m = {};
                  e.forEach((k, v) => m[k.toString()] = v);
                  return m;
                }).toList();
                if (_selectedKelompokId == null && _kelompokList.isNotEmpty) {
                  _selectedKelompokId = int.tryParse(_kelompokList.first['id_kelompok']?.toString() ?? '0');
                }
              }
              final kelasL = meta['kelas_list'];
              if (kelasL is List) {
                _kelasList = kelasL.whereType<Map>().map((e) {
                  final Map<String, dynamic> m = {};
                  e.forEach((k, v) => m[k.toString()] = v);
                  return m;
                }).toList();
              }
            }
          }

          final list = raw['masalah'];
          if (list is List)
            return list.whereType<Map>().map((e) {
              final Map<String, dynamic> m = {};
              e.forEach((k, v) => m[k.toString()] = v);
              return m;
            }).toList();
        }
        return [];
      }

      if (!mounted) return;
      setState(() {
        _allAktif = _parse(results[0], true);
        _allSelesai = _parse(results[1], false);
        _filtered = _tabController.index == 0 ? _allAktif : _allSelesai;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  // --- Load Approval ----------------------------------------------------------
  Future<void> _loadApproval() async {
    if (!mounted) return;
    setState(() { _approvalLoading = true; _approvalError = ''; });
    try {
      final resp = await ApiService.getMasalahPendingApproval();
      final raw = resp['data'];
      List<Map<String, dynamic>> list = [];
      if (raw is Map) {
        final r = raw['masalah'];
        if (r is List) {
          list = r.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
      }
      if (!mounted) return;
      setState(() {
        _approvalList = list;
        _approvalLoading = false;
        _approvalLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _approvalError = e.toString().replaceAll('Exception: ', '');
        _approvalLoading = false;
        _approvalLoaded = true;
      });
    }
  }

  Future<void> _handleApprovalAction(String action, String id, String? catatan) async {
    try {
      if (action == 'setujui') {
        await ApiService.setujuiMasalah(id: id);
        _showSnack('Masalah berhasil disetujui', _kAccent);
      } else {
        await ApiService.tolakMasalah(id: id, catatan: catatan ?? '');
        _showSnack('Masalah ditolak', Colors.orange.shade600);
      }
      _loadApproval();
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), Colors.red.shade600);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _applySearch(_searchCtrl.text.trim());
    });
  }

  void _applySearch(String q) {
    final base = _tabController.index == 0 ? _allAktif : _allSelesai;
    if (q.isEmpty) { setState(() => _filtered = base); return; }
    final lower = q.toLowerCase();
    setState(() {
      _filtered = base.where((m) {
        final nama = (m['nama_santri'] ?? '').toString().toLowerCase();
        final nis = (m['nis'] ?? '').toString().toLowerCase();
        final jenis = (m['jenis_masalah'] ?? '').toString().toLowerCase();
        return nama.contains(lower) || nis.contains(lower) || jenis.contains(lower);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (!_searchOpen) {
      _searchCtrl.clear();
      setState(() => _filtered = _tabController.index == 0 ? _allAktif : _allSelesai);
    }
  }

  // --- Build ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_tabController.index != 2) _buildFilterBar(), // Show filter only on Aktif and Selesai tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMasalahBody(isAktif: true),
                _buildMasalahBody(isAktif: false),
                _buildApprovalBody(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomTabBar(),
    );
  }

  Widget _buildFilterBar() {
    if (_kelompokList.length <= 1 && _kelasList.length <= 1) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_kelompokList.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kelompokList.map((k) {
                  final id = int.tryParse(k['id_kelompok']?.toString() ?? '0') ?? 0;
                  final nama = k['kelompok']?.toString() ?? '-';
                  final isSel = _selectedKelompokId == id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (!isSel) {
                          setState(() { _selectedKelompokId = id; _selectedKelasId = null; _allAktif = []; _allSelesai = []; _filtered = []; });
                          _load();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? _kHeader : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? _kHeader : Colors.grey.shade300),
                        ),
                        child: Text(
                          nama,
                          style: TextStyle(
                            color: isSel ? Colors.white : _kText2,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_kelasList.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  value: _selectedKelasId,
                  hint: const Text('Semua Kelas', style: TextStyle(fontSize: 13)),
                  icon: const Icon(Icons.arrow_drop_down, color: _kHeader),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Semua Kelas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    ..._kelasList.map((k) {
                      final id = int.tryParse(k['id_kelas']?.toString() ?? '0') ?? 0;
                      final t = k['tingkat']?.toString() ?? '-';
                      final n = k['nama_kelompok']?.toString() ?? '';
                      return DropdownMenuItem<int?>(
                        value: id,
                        child: Text('Kelas $t ${n.isNotEmpty ? "($n)" : ""}', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedKelasId = val;
                      _allAktif = [];
                      _allSelesai = [];
                      _filtered = [];
                    });
                    _load();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- AppBar -----------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    final aktifCount = _allAktif.length;
    final isApprovalTab = _tabController.index == 2;
    final isAktifTab = _tabController.index == 0;
    final extraH = (_searchOpen && !isApprovalTab) ? 52.0 : 0.0;

    return PreferredSize(
      preferredSize: Size.fromHeight(72 + extraH),
      child: Container(
        color: _kHeader,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Masalah Santri',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const Text('Pantau & tangani permasalahan',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (aktifCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$aktifCount aktif',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        // Search (non-approval tab only)
                        if (!isApprovalTab)
                          IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _searchOpen
                                    ? Icons.search_off_rounded
                                    : Icons.search_rounded,
                                key: ValueKey(_searchOpen),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            onPressed: _toggleSearch,
                          ),
                        // Tambah (aktif tab only)
                        if (isAktifTab)
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            tooltip: 'Tambah Masalah',
                            onPressed: _showTambahMasalahSheet,
                          ),
                        // Refresh (approval tab)
                        if (isApprovalTab)
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 22),
                            tooltip: 'Refresh',
                            onPressed: _loadApproval,
                          ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  // Expandable search field
                  if (_searchOpen && !isApprovalTab)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Cari nama, NIS, atau jenis...',
                            hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Colors.white70, size: 18),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 16, color: Colors.white70),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _filtered =
                                          _tabController.index == 0
                                              ? _allAktif
                                              : _allSelesai);
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                    ),
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
          border:
              Border.all(color: Colors.white.withAlpha(18), width: bw),
        ),
      );

  // --- Bottom Tab Bar ---------------------------------------------------------
  Widget _buildBottomTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: TabBar(
          controller: _tabController,
          indicatorColor: _kHeader,
          indicatorWeight: 3,
          labelColor: _kHeader,
          unselectedLabelColor: _kText2,
          labelStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500),
          tabs: [
            Tab(
              icon: const Icon(Icons.warning_rounded, size: 20),
              text: 'Aktif (${_allAktif.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              text: 'Selesai',
            ),
            Tab(
              icon: const Icon(Icons.pending_actions_rounded, size: 20),
              text: _approvalList.isNotEmpty
                  ? 'Approval (${_approvalList.length})'
                  : 'Approval',
            ),
          ],
        ),
      ),
    );
  }

  // --- Masalah Tab Body -------------------------------------------------------
  Widget _buildMasalahBody({required bool isAktif}) {
    if (_loading) return _buildSkeleton();
    if (_error.isNotEmpty) return _buildError();
    return _buildList(isAktif: isAktif);
  }

  // --- Approval Tab Body ------------------------------------------------------
  Widget _buildApprovalBody() {
    if (_approvalLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => _MasalahSkeletonCard(key: ValueKey(i)),
      );
    }
    if (_approvalError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_approvalError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kText2)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _kHeader),
                onPressed: _loadApproval,
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white),
                label: const Text('Coba Lagi',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }
    if (!_approvalLoaded) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pending_actions_rounded,
                size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Geser ke tab ini untuk memuat data',
                style: TextStyle(color: _kText2)),
          ],
        ),
      );
    }
    if (_approvalList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFBBF7D0), width: 2),
                ),
                child: const Icon(Icons.inbox_rounded,
                    color: _kAccent, size: 38),
              ),
              const SizedBox(height: 20),
              const Text('Tidak Ada Menunggu',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Semua laporan masalah sudah ditinjau.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: _kText2, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withAlpha(20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFF59E0B).withAlpha(60)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_actions_rounded,
                  color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_approvalList.length} laporan menunggu persetujuan',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: _kAccent,
            onRefresh: _loadApproval,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: _approvalList.length,
              itemBuilder: (_, i) => _ApprovalCard(
                item: _approvalList[i],
                isAdmin: widget.isAdmin,
                onAction: _handleApprovalAction,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Skeleton ---------------------------------------------------------------
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: 6,
      itemBuilder: (_, i) => _MasalahSkeletonCard(key: ValueKey(i)),
    );
  }

  // --- Error ------------------------------------------------------------------
  Widget _buildError() {
    final isSession = _error.toLowerCase().contains('sesi') ||
        _error.toLowerCase().contains('login');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSession
                  ? Icons.lock_outline_rounded
                  : Icons.wifi_off_rounded,
              size: 64, color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(_error,
                textAlign: TextAlign.center,
                style: TextStyle(color: _kText2)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white),
              label: const Text('Coba Lagi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- List -------------------------------------------------------------------
  Widget _buildList({required bool isAktif}) {
    final list = _searchCtrl.text.isNotEmpty
        ? _filtered
        : (isAktif ? _allAktif : _allSelesai);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAktif
                  ? Icons.check_circle_outline_rounded
                  : Icons.history_toggle_off_rounded,
              size: 72,
              color: isAktif ? _kAccent : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isAktif
                  ? 'Tidak ada masalah aktif'
                  : 'Belum ada masalah selesai',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText1),
            ),
            const SizedBox(height: 6),
            if (isAktif)
              Text(
                'Alhamdulillah, semua santri dalam kondisi baik!',
                style: TextStyle(fontSize: 12, color: _kText2),
                textAlign: TextAlign.center,
              ),
            if (isAktif) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kAccent),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                onPressed: _showTambahMasalahSheet,
                icon: const Icon(Icons.add_rounded,
                    color: _kAccent, size: 18),
                label: Text('Tambah Masalah',
                    style: TextStyle(
                        color: _kAccent,
                        fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: list.length,
        itemBuilder: (_, i) => _MasalahCard(
          item: list[i],
          isAktif: isAktif,
          onTap: () => _showDetailSheet(list[i], isAktif),
        ),
      ),
    );
  }

  void _showDetailSheet(Map<String, dynamic> item, bool isAktif) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        item: item,
        isAktif: isAktif,
        isAdmin: widget.isAdmin,
        onRefresh: _load,
      ),
    );
  }

  void _showTambahMasalahSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TambahMasalahSheet(onSaved: _load),
    );
  }
}

// --- Approval Card (embedded) -------------------------------------------------
class _ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAdmin;
  final Future<void> Function(String action, String id, String? catatan) onAction;

  const _ApprovalCard({
    required this.item,
    required this.isAdmin,
    required this.onAction,
  });

  String _fmtTgl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('d MMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = item['id_masalah']?.toString() ?? item['id']?.toString() ?? '';
    final nama = item['nama_santri']?.toString() ?? '-';
    final nis = item['nis']?.toString() ?? '';
    final kelas = item['tingkat']?.toString() ?? '';
    final jenis = item['jenis_masalah']?.toString();
    final ket = item['keterangan']?.toString() ?? '';
    final tgl = item['tgl_deteksi']?.toString() ?? item['tgl_masalah']?.toString() ?? '';
    final guru = item['nama_pembuat']?.toString() ?? item['username']?.toString() ?? '-';
    final barClr = _jenisColor(jenis);
    const kOrange = Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: barClr.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: barClr),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(nama,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _kText1)),
                          ),
                          _JenisBadge(jenis: jenis),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _Chip(icon: Icons.badge_outlined, text: nis),
                          if (kelas.isNotEmpty)
                            _Chip(icon: Icons.school_outlined, text: kelas),
                          _Chip(
                            icon: Icons.person_outline_rounded,
                            text: 'Oleh: $guru',
                          ),
                        ],
                      ),
                      if (ket.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 6),
                        Text(ket,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _kText2,
                                height: 1.4)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: _kText2),
                          const SizedBox(width: 4),
                          Text(_fmtTgl(tgl),
                              style: const TextStyle(
                                  fontSize: 11, color: _kText2)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kOrange.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.hourglass_empty_rounded,
                                    size: 10, color: kOrange),
                                const SizedBox(width: 4),
                                Text('Menunggu',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: kOrange,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Tombol aksi: hanya tampil jika isAdmin
                      if (isAdmin) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.red.shade300, width: 1),
                                  foregroundColor: Colors.red.shade600,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                onPressed: () =>
                                    _showTolakDialog(context, id),
                                icon: const Icon(Icons.cancel_outlined,
                                    size: 15),
                                label: const Text('Tolak',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () =>
                                    _showSetujuiDialog(context, id, nama),
                                icon: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 15),
                                label: const Text('Setujui',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Guru: tampil info saja tanpa tombol aksi
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: kOrange.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 14, color: kOrange),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Menunggu persetujuan admin',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetujuiDialog(BuildContext context, String id, String namaSantri) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kAccent.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _kAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Setujui Masalah',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _kText1)),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: _kText2),
            children: [
              const TextSpan(text: 'Masalah untuk '),
              TextSpan(
                  text: namaSantri,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: _kText1)),
              const TextSpan(
                  text: ' akan disetujui dan menjadi aktif. Lanjutkan?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: _kText2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onAction('setujui', id, null);
            },
            child: const Text('Setujui',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(BuildContext context, String id) {
    final catatanCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.cancel_rounded,
                  color: Colors.red.shade600, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Tolak Masalah',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kText1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Berikan alasan penolakan:',
                style: TextStyle(color: _kText2, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: _kText1),
              decoration: InputDecoration(
                hintText: 'Tulis alasan penolakan...',
                hintStyle: TextStyle(color: _kText2, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.red.shade400, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: _kText2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final catatan = catatanCtrl.text.trim();
              if (catatan.isEmpty) return;
              Navigator.pop(ctx);
              onAction('tolak', id, catatan);
            },
            child: const Text('Tolak',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


// --- Masalah Card --------------------------------------------------------------
class _MasalahCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAktif;
  final VoidCallback onTap;

  const _MasalahCard({
    required this.item,
    required this.isAktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nama = item['nama_santri']?.toString() ?? '-';
    final nis = item['nis']?.toString() ?? '';
    final kelas =
        item['kelas']?.toString() ?? item['tingkat']?.toString() ?? '';
    final jenis = item['jenis_masalah']?.toString();
    final keterangan =
        item['deskripsi']?.toString() ?? item['keterangan']?.toString() ?? '';
    final tgl =
        item['tgl_masalah']?.toString() ??
        item['tgl_deteksi']?.toString() ??
        '';
    final tglSelesai = item['tgl_selesai']?.toString() ?? '';

    final barClr = _jenisColor(jenis);

    // Format tanggal
    String _fmtTgl(String raw) {
      if (raw.isEmpty) return '';
      try {
        final d = DateTime.parse(raw);
        return DateFormat('d MMM yyyy', 'id_ID').format(d);
      } catch (_) {
        return raw;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: barClr.withAlpha(40), width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Severity bar kiri
                  Container(width: 4, color: barClr),
                  // Konten
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Nama + badge jenis
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nama,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _kText1,
                                  ),
                                ),
                              ),
                              _JenisBadge(jenis: jenis),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row 2: chips NIS & kelas
                          Wrap(
                            spacing: 6,
                            children: [
                              _Chip(icon: Icons.badge_outlined, text: nis),
                              if (kelas.isNotEmpty)
                                _Chip(icon: Icons.school_outlined, text: kelas),
                            ],
                          ),
                          if (keterangan.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 8),
                            Text(
                              keterangan,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: _kText2,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Row 3: tanggal + status selesai
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: _kText2,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmtTgl(tgl),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _kText2,
                                ),
                              ),
                              const Spacer(),
                              if (!isAktif && tglSelesai.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 11,
                                      color: _kAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Selesai ${_fmtTgl(tglSelesai)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _kAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              if (isAktif)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: _kText2,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Jenis Badge ---------------------------------------------------------------
class _JenisBadge extends StatelessWidget {
  final String? jenis;
  const _JenisBadge({this.jenis});

  @override
  Widget build(BuildContext context) {
    final clr = _jenisColor(jenis);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: clr.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_jenisIcon(jenis), size: 11, color: clr),
          const SizedBox(width: 5),
          Text(
            _jenisLabel(jenis),
            style: TextStyle(
              fontSize: 11,
              color: clr,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Info Chip -----------------------------------------------------------------
class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: _kText2),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: _kText2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Skeleton Card -------------------------------------------------------------
class _MasalahSkeletonCard extends StatefulWidget {
  const _MasalahSkeletonCard({super.key});

  @override
  State<_MasalahSkeletonCard> createState() => _MasalahSkeletonCardState();
}

class _MasalahSkeletonCardState extends State<_MasalahSkeletonCard>
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
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      builder: (_, __) {
        final opacity = 0.06 + 0.08 * _anim.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _SkelBox(w: 140, h: 14, opacity: opacity),
                            const Spacer(),
                            _SkelBox(w: 80, h: 22, opacity: opacity, r: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _SkelBox(w: 70, h: 22, opacity: opacity, r: 6),
                            const SizedBox(width: 8),
                            _SkelBox(w: 60, h: 22, opacity: opacity, r: 6),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _SkelBox(w: double.infinity, h: 12, opacity: opacity),
                        const SizedBox(height: 6),
                        _SkelBox(w: 200, h: 12, opacity: opacity),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkelBox extends StatelessWidget {
  final double w, h, opacity;
  final double r;
  const _SkelBox({
    required this.w,
    required this.h,
    required this.opacity,
    this.r = 6,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(r),
    ),
  );
}

// --- Detail Bottom Sheet --------------------------------------------------------
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
      await ApiService.updateMasalah(
        id: (widget.item['id_masalah'] ?? widget.item['id']).toString(),
        status: 'selesai',
        tglSelesai: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        catatanSelesai: _catatanCtrl.text.trim(),
      );
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
    final barClr = _jenisColor(jenis);
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
                                  _Chip(icon: Icons.badge_outlined, text: nis),
                                  if (kelas.isNotEmpty)
                                    _Chip(
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
                        _JenisBadge(jenis: jenis),
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
                      hintText: 'Tulis catatan atau tindakan yang dilakukan...',
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
      await ApiService.storeTahapMasalah(
        idMasalah: widget.idMasalah,
        jenisPenyelesaian: _jenisPenyelesaian!,
        tglPenyelesaian: DateFormat('yyyy-MM-dd').format(_tglPenyelesaian),
        keterangan: _keteranganCtrl.text.trim(),
        hasilTahap: _hasilTahap!,
      );

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
        final res = await ApiService.cariSantri(val.trim());
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
      await ApiService.storeMasalah(
        nis: _selectedNis!,
        jenisMasalah: _jenisMasalah!,
        keterangan: _keteranganCtrl.text.trim(),
        tglMasalah: DateFormat('yyyy-MM-dd').format(_tglMasalah),
      );
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
                                      color: _jenisColor(j),
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
