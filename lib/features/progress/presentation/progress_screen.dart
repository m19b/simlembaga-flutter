import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'progress_detail_screen.dart';
import 'progress_input_screen.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/progress_detail_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/progress_input_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg     = Color(0xFFF3F4F6);
const Color _kText1  = Color(0xFF111827);
const Color _kText2  = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);

// ─── Progress Belajar – Daftar Santri ─────────────────────────────────────────
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allSantri = [];
  List<Map<String, dynamic>> _filtered  = [];
  bool   _loading = true;
  String _error   = '';

  // Search FAB state
  bool _searchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  late AnimationController _searchAnim;
  late Animation<double> _searchScale;

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _searchScale = CurvedAnimation(parent: _searchAnim, curve: Curves.easeOutCubic);
    _searchCtrl.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    _debounce?.cancel();
    _searchAnim.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchAnim.forward();
    } else {
      _searchAnim.reverse();
      _searchCtrl.clear();
      setState(() => _filtered = _allSantri);
    }
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _searchCtrl.text.trim().toLowerCase();
      if (!mounted) return;
      setState(() {
        _filtered = q.isEmpty
            ? _allSantri
            : _allSantri.where((s) {
                final nama = (s['nama_santri'] ?? '').toString().toLowerCase();
                final nis  = (s['nis']         ?? '').toString().toLowerCase();
                return nama.contains(q) || nis.contains(q);
              }).toList();
      });
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final resp = await ApiService.getProgressList();
      // Response envelope: { status:200, error:null, message:'...', data:{ santri_list:[], ... } }
      final raw = resp['data'];
      List<Map<String, dynamic>> list = [];

      if (raw is Map) {
        final rawList = raw['santri_list'];
        if (rawList is List && rawList.isNotEmpty) {
          list = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } else if (raw is List) {
        list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      if (!mounted) return;
      setState(() {
        _allSantri = list;
        _filtered  = list;
        _loading   = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      // Header FIXED — tidak hilang saat scroll
      appBar: _buildAppBar(),
      body: _loading ? _buildSkeleton() : _error.isNotEmpty ? _buildError() : _buildBody(),
      // Floating search FAB
      floatingActionButton: _buildSearchFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ─── Fixed AppBar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        color: _kHeader,
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progres Belajar',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Pantau simakan setiap santri',
                              style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        const Icon(Icons.people_outline, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text('${_allSantri.length} Santri',
                            style: GoogleFonts.dmMono(color: Colors.white70, fontSize: 11)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deco(double size, double borderW) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withAlpha(20), width: borderW),
    ),
  );

  // ─── Search FAB (ngambang) ─────────────────────────────────────────────────
  Widget _buildSearchFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search bar yang muncul di atas FAB (animasi scale + fade)
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
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.dmSans(fontSize: 14, color: _kText1),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIS…',
                    hintStyle: GoogleFonts.dmSans(color: _kText2, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: _kAccent, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: _kText2),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filtered = _allSantri);
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ),

        // FAB utama
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!_searchOpen)
              FloatingActionButton.extended(
                heroTag: 'eval',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressInputScreen())),
                backgroundColor: _kHeader,
                elevation: 4,
                icon: const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 20),
                label: Text('Input Evaluasi', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            if (!_searchOpen) const SizedBox(width: 12),
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

  // ─── Skeleton Loading ─────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, i) => _SkeletonCard(key: ValueKey(i)),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────
  Widget _buildError() {
    final isSession = _error.toLowerCase().contains('sesi') ||
        _error.toLowerCase().contains('habis') ||
        _error.toLowerCase().contains('login');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isSession ? Icons.lock_outline_rounded : Icons.wifi_off_rounded,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_error, textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: _kText2)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: Text('Coba Lagi',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          if (isSession) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              onPressed: () =>
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false),
              icon: const Icon(Icons.login_rounded, color: _kAccent),
              label: Text('Ke Halaman Login',
                  style: GoogleFonts.plusJakartaSans(
                      color: _kAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
      ),
    );
  }

  // ─── Body / List ──────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_filtered.isEmpty && _searchCtrl.text.isNotEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Santri "${_searchCtrl.text}" tidak ditemukan',
              textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: _kText2)),
        ]),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Belum ada data santri', style: GoogleFonts.dmSans(color: _kText2)),
          const SizedBox(height: 8),
          Text('Periksa koneksi atau coba refresh', style: GoogleFonts.dmSans(color: _kText2, fontSize: 12)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: _kAccent)),
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: _kAccent, size: 18),
            label: Text('Refresh', style: GoogleFonts.dmSans(color: _kAccent)),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: _kAccent,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), // 96 agar tidak tertutup FAB
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _SantriCard(
          santri: _filtered[i],
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ProgressDetailScreen(santri: _filtered[i]),
            ));
          },
        ),
      ),
    );
  }
}

// ─── Santri Card ─────────────────────────────────────────────────────────────
class _SantriCard extends StatelessWidget {
  final Map<String, dynamic> santri;
  final VoidCallback onTap;
  const _SantriCard({required this.santri, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String kelompok = santri['kelompok']?.toString() ?? '-';
    final String kelas    = santri['kelas']?.toString()    ?? '-';

    // Halaman
    final int capaiHal = int.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final int totalHal = int.tryParse(santri['total_hal']?.toString() ?? '604') ?? 604;
    final int pctHal   = int.tryParse(santri['pctHal']?.toString() ?? '0') ?? 0;
    final double halProgress = totalHal > 0 ? (capaiHal / totalHal).clamp(0.0, 1.0) : 0.0;
    
    final int cntLulus = int.tryParse(santri['cnt_lulus']?.toString() ?? '0') ?? 0;
    final int cntUlang = int.tryParse(santri['cnt_ulang']?.toString() ?? '0') ?? 0;
    final String lastHal = santri['lastHal']?.toString() ?? '';

    // Latihan
    final int latSek    = int.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;
    final int targetLat = int.tryParse(santri['target_latihan']?.toString() ?? '0') ?? 0;
    final int pctLat    = int.tryParse(santri['pctLat']?.toString() ?? '0') ?? 0;
    final double latProgress = targetLat > 0 ? (latSek / targetLat).clamp(0.0, 1.0) : 0.0;
    final bool modeIsLatihan = santri['modeIsLatihan'] == true;

    // Kecepatan & Badge
    final String kLabel = santri['kLabel']?.toString() ?? '-';
    final String kClr   = santri['kClr']?.toString() ?? 'primary';
    final double kecAktTotal = double.tryParse(santri['kecAktTotal']?.toString() ?? '0') ?? 0.0;
    final bool hasCepat = santri['hasCepat'] == true;

    // Helper color
    Color getBadgeColor(String c) {
      switch (c) {
        case 'success': return Colors.green.shade600;
        case 'info':    return Colors.teal.shade500;
        case 'warning': return Colors.orange.shade600;
        case 'danger':  return Colors.red.shade600;
        case 'primary':
        default:        return Colors.blue.shade600;
      }
    }
    
    const Color kBlue = Color(0xFF3B82F6);
    const Color kTeal = Color(0xFF14B8A6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (santri['nama_santri'] ?? 'S')[0].toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.bold, color: _kAccent),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      Text(
                        santri['nama_santri'] ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 14, color: _kText1),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(santri['nis'] ?? '-', style: GoogleFonts.dmMono(fontSize: 11, color: _kText2)),
                          const SizedBox(width: 4),
                          _chip(kelompok, _kAccent),
                          _chip(kelas, Colors.indigo.shade400),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ),

                      // --- HALAMAN ---
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 14, color: kBlue),
                          const SizedBox(width: 4),
                          Text('Halaman', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: kBlue)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text('$capaiHal/$totalHal', style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.bold, color: _kText1), overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 4),
                                Text('$pctHal%', style: GoogleFonts.dmMono(fontSize: 11, color: _kText2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: halProgress,
                          minHeight: 5,
                          backgroundColor: kBlue.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(kBlue),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Lulus: $cntLulus TM', style: GoogleFonts.dmSans(fontSize: 11, color: _kText2)),
                          if (cntUlang > 0)
                            _chip('${cntUlang}x ulang', Colors.orange.shade700, bgOpacity: 0.1),
                          if (lastHal.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 10, color: _kText2),
                                const SizedBox(width: 2),
                                Text(lastHal, style: GoogleFonts.dmSans(fontSize: 10, color: _kText2)),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- LATIHAN ---
                      Row(
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 16, color: kTeal),
                          const SizedBox(width: 4),
                          Text('Latihan', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: kTeal)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!modeIsLatihan && latSek == 0)
                                  Flexible(child: Text('Selesaikan halaman dulu', style: GoogleFonts.dmSans(fontSize: 11, color: _kText2), overflow: TextOverflow.ellipsis))
                                else ...[
                                  Flexible(child: Text('$latSek/$targetLat', style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.bold, color: _kText1), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 4),
                                  Text('$pctLat%', style: GoogleFonts.dmMono(fontSize: 11, color: _kText2)),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (modeIsLatihan || latSek > 0) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: latProgress,
                            minHeight: 5,
                            backgroundColor: kTeal.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(kTeal),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // --- KECEPATAN ---
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 14, color: Colors.indigo),
                          const SizedBox(width: 4),
                          Text('Kecepatan', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!hasCepat)
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                      child: Text('Belum cukup data', style: GoogleFonts.dmSans(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    ),
                                  )
                                else ...[
                                  Flexible(
                                    child: Text('${kecAktTotal.toStringAsFixed(2)} hal/TM', style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.bold, color: _kText1), overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: getBadgeColor(kClr).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                    child: Text(kLabel, style: GoogleFonts.dmSans(fontSize: 10, color: getBadgeColor(kClr), fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!hasCepat)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 6),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Min. 3 sesi lulus', style: GoogleFonts.dmSans(fontSize: 10, color: _kText2)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, {double bgOpacity = 0.1}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(bgOpacity), borderRadius: BorderRadius.circular(6)),
    child: Text(label,
        style: GoogleFonts.dmSans(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
  );
}

// ─── Skeleton Card ────────────────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({super.key});
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(_anim.value * 0.3))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 14,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(_anim.value * 0.4),
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(
                      height: 10,
                      width: 160,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(_anim.value * 0.3),
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 12),
                  Container(
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(_anim.value * 0.35),
                          borderRadius: BorderRadius.circular(4))),
                ]),
          ),
        ]),
      ),
    );
  }
}
