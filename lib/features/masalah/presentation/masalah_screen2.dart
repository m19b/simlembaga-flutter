import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/masalah_card.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/approval_card.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/detail_masalah_sheet.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/tambah_masalah_sheet.dart';

// --- Design Tokens -------------------------------------------------------------
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);



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
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        SantriCatatanApiService.getMasalahAktif(
          idKelompok: _selectedKelompokId,
          idKelas: _selectedKelasId,
        ),
        SantriCatatanApiService.getMasalahSelesai(
          idKelompok: _selectedKelompokId,
          idKelas: _selectedKelasId,
        ),
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
                  _selectedKelompokId = int.tryParse(
                    _kelompokList.first['id_kelompok']?.toString() ?? '0',
                  );
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
    setState(() {
      _approvalLoading = true;
      _approvalError = '';
    });
    try {
      final resp = await SantriCatatanApiService.getMasalahPendingApproval();
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

  Future<void> _handleApprovalAction(
    String action,
    String id,
    String? catatan,
  ) async {
    try {
      if (action == 'setujui') {
        await SantriCatatanApiService.setujuiMasalah(id: id);
        _showSnack('Masalah berhasil disetujui', _kAccent);
      } else {
        await SantriCatatanApiService.tolakMasalah(
          id: id,
          catatan: catatan ?? '',
        );
        _showSnack('Masalah ditolak', Colors.orange.shade600);
      }
      _loadApproval();
    } catch (e) {
      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
        Colors.red.shade600,
      );
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
    if (!_searchOpen) {
      _searchCtrl.clear();
      setState(
        () => _filtered = _tabController.index == 0 ? _allAktif : _allSelesai,
      );
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
          if (_tabController.index != 2)
            _buildFilterBar(), // Show filter only on Aktif and Selesai tabs
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
    if (_kelompokList.length <= 1 && _kelasList.length <= 1)
      return const SizedBox.shrink();
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
                            _allAktif = [];
                            _allSelesai = [];
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
                          color: isSel ? _kHeader : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? _kHeader : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          nama,
                          style: TextStyle(
                            color: isSel ? Colors.white : _kText2,
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
                  hint: const Text(
                    'Semua Kelas',
                    style: TextStyle(fontSize: 13),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: _kHeader),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Semua Kelas',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ..._kelasList.map((k) {
                      final id =
                          int.tryParse(k['id_kelas']?.toString() ?? '0') ?? 0;
                      final t = k['tingkat']?.toString() ?? '-';
                      final n = k['nama_kelompok']?.toString() ?? '';
                      return DropdownMenuItem<int?>(
                        value: id,
                        child: Text(
                          'Kelas $t ${n.isNotEmpty ? "($n)" : ""}',
                          style: const TextStyle(fontSize: 13),
                        ),
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
                              const Text(
                                'Masalah Santri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Pantau & tangani permasalahan',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (aktifCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$aktifCount aktif',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            tooltip: 'Tambah Masalah',
                            onPressed: _showTambahMasalahSheet,
                          ),
                        // Refresh (approval tab)
                        if (isApprovalTab)
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
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
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama, NIS, atau jenis...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(
                                        () => _filtered =
                                            _tabController.index == 0
                                            ? _allAktif
                                            : _allSelesai,
                                      );
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
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
      border: Border.all(color: Colors.white.withAlpha(18), width: bw),
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
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
    if (_loading) return const GlobalSkeletonWidget();
    if (_error.isNotEmpty)
      return GlobalErrorWidget(message: _error, onRetry: _load);
    return _buildList(isAktif: isAktif);
  }

  // --- Approval Tab Body ------------------------------------------------------
  Widget _buildApprovalBody() {
    if (_approvalLoading) {
      return const GlobalSkeletonWidget();
    }
    if (_approvalError.isNotEmpty) {
      return GlobalErrorWidget(message: _approvalError, onRetry: _loadApproval);
    }
    if (!_approvalLoaded) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pending_actions_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Geser ke tab ini untuk memuat data',
              style: TextStyle(color: _kText2),
            ),
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: _kAccent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tidak Ada Menunggu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Semua laporan masalah sudah ditinjau.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _kText2, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withAlpha(20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF59E0B).withAlpha(60)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.pending_actions_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_approvalList.length} laporan menunggu persetujuan',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
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
              itemBuilder: (_, i) => ApprovalCard(
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
              isAktif ? 'Tidak ada masalah aktif' : 'Belum ada masalah selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kText1,
              ),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: list.length,
        itemBuilder: (_, i) => MasalahCard(
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
      builder: (_) => DetailMasalahSheet(
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
      builder: (_) => TambahMasalahSheet(onSaved: _load),
    );
  }
}
