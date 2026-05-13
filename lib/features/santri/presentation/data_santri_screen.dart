import 'widgets/santri_card_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/santri/presentation/bloc/santri_cubit.dart';
import 'package:manajemen_tahsin_app/features/santri/domain/repositories/santri_repository.dart';

// --- Design Tokens -------------------------------------------------------------
const Color _kHeader = Color(0xFF0F4C2A);
const Color _kBg = Color(0xFFF3F4F6);
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF16A34A);
const Color _kWhite = Colors.white;

// --- Screen -------------------------------------------------------------------
class DataSantriScreen extends StatefulWidget {
  const DataSantriScreen({super.key});

  @override
  State<DataSantriScreen> createState() => _DataSantriScreenState();
}

class _DataSantriScreenState extends State<DataSantriScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allSantri = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _error = '';

  // Search
  bool _searchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
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
                final nis = (s['nis'] ?? '').toString().toLowerCase();
                return nama.contains(q) || nis.contains(q);
              }).toList();
      });
    });
  }

  Future<void> _load() async {
    context.read<SantriCubit>().fetchSantriList();
  }

  // --- Fungsi Peluncur WA ------------------------------------------------------
  // CARI: Future<void> _launchWA
  Future<void> _launchWA(
    BuildContext ctx,
    String phone, {
    String? pesan,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) return;

    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }

    // Jika ada pesan dari t_kelas.pesanwa, sisipkan ke URL
    String urlStr = 'https://wa.me/$cleanPhone';
    if (pesan != null && pesan.trim().isNotEmpty) {
      urlStr += '?text=${Uri.encodeQueryComponent(pesan.trim())}';
    }

    final Uri url = Uri.parse(urlStr);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal membuka WhatsApp. Pastikan aplikasi terinstall.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _fetchAndShowDetail(String nis) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: _kAccent)),
    );

    try {
      final resp = await context.read<SantriRepository>().getSantriDetail(nis);
      final raw = resp['data']; // {'santri': {...}}
      final data = (raw is Map)
          ? (raw['santri'] ?? raw)
          : raw; // ambil isi 'santri'

      if (!mounted) return;
      Navigator.pop(context);

      if (data != null && data is Map<String, dynamic>) {
        _showDetail(data);
      } else {
        throw Exception('Data santri tidak ditemukan');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat detail: ${e.toString().replaceAll('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  // --- Build -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SantriCubit, SantriState>(
      listener: (context, state) {
        if (state is SantriLoaded) {
          final raw = state.data['data'];
          List<Map<String, dynamic>> list = [];
          if (raw is List) {
            list = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
          } else if (raw is Map) {
            final rawList = raw['santri'] ?? raw['data'] ?? [];
            if (rawList is List) {
              list = rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
            }
          }
          setState(() {
            _allSantri = list;
            _filtered = list;
            _loading = false;
            _error = '';
          });
          _onSearch();
        } else if (state is SantriError) {
          setState(() {
            _error = state.message;
            _loading = false;
          });
        } else if (state is SantriLoading) {
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
          body: _loading
              ? _buildSkeleton()
              : _error.isNotEmpty
                  ? _buildError()
                  : _buildBody(),
          floatingActionButton: _buildSearchFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  // --- AppBar ------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        color: _kHeader,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _kWhite,
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
                            'Data Santri',
                            style: TextStyle(
                              color: _kWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manajemen data santri lembaga',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_allSantri.length} Santri',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: borderW,
      ),
    ),
  );

  // --- Search FAB --------------------------------------------------------------
  Widget _buildSearchFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
                  color: _kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(fontSize: 14, color: _kText1),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NISâ€¦',
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
                              setState(() => _filtered = _allSantri);
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
        FloatingActionButton(
          heroTag: 'searchSantri',
          onPressed: _toggleSearch,
          backgroundColor: _searchOpen ? Colors.red.shade400 : _kAccent,
          elevation: 4,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
              key: ValueKey(_searchOpen),
              color: _kWhite,
            ),
          ),
        ),
      ],
    );
  }

  // --- Body --------------------------------------------------------------------
  Widget _buildBody() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data santri.',
              style: TextStyle(color: _kText2, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: _kAccent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => SantriCardWidget(
          santri: _filtered[i],
          index: i + 1,
          onTap: () => _fetchAndShowDetail(_filtered[i]['nis'].toString()),
        ),
      ),
    );
  }

  // --- Detail BottomSheet ------------------------------------------------------
  void _showDetail(Map<String, dynamic> s) {
    final nama = s['nama_santri']?.toString() ?? '-';
    final panggilan = s['nama_panggilan']?.toString() ?? '';
    final nis = s['nis']?.toString() ?? '-';
    final jk = s['jenis_kelamin']?.toString() ?? '-';
    final kelas = s['tingkat']?.toString() ?? '-';
    final kelompok = s['nama_kelompok']?.toString() ?? '-';
    final tglLahir = s['tanggal_lahir']?.toString() ?? '';
    final tmpLahir = s['tempat_lahir']?.toString() ?? '';
    final alamat = s['alamat_lengkap']?.toString() ?? '-';
    final hp = s['no_hp_santri']?.toString() ?? '-';
    final namaAyah = s['nama_ayah']?.toString() ?? '-';
    final hpAyah = s['hp_ayah']?.toString() ?? '-';
    final namaIbu = s['nama_ibu']?.toString() ?? '-';
    final hpIbu = s['hp_ibu']?.toString() ?? '-';
    final pesanDb = s['pesanwa']?.toString() ?? '';
    final linkDb = s['linkgroupwa']?.toString() ?? '';
    final waGroup = s['wa_group']?.toString() ?? '-';
    final noWaGroup = s['no_wa_group']?.toString() ?? '-';

    // Pesan otomatis untuk Ayah/Ibu
    String pesanOrangTua = '';
    if (pesanDb.isNotEmpty || linkDb.isNotEmpty) {
      pesanOrangTua = "";
      if (pesanDb.isNotEmpty) {
        pesanOrangTua += "$pesanDb\n";
      }
      if (linkDb.isNotEmpty) {
        pesanOrangTua += linkDb;
      }
    }
    String ttl = '-';
    if (tglLahir.isNotEmpty) {
      final parts = tglLahir.split('-');
      if (parts.length == 3) {
        final bln = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agt',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        final m = int.tryParse(parts[1]) ?? 0;
        final tahun = int.tryParse(parts[0]) ?? 0;
        final umur = DateTime.now().year - tahun;
        ttl =
            '${tmpLahir.isNotEmpty ? "$tmpLahir, " : ""}${parts[2]} ${m > 0 && m < 13 ? bln[m] : parts[1]} ${parts[0]}  ($umur th)';
      }
    } else if (tmpLahir.isNotEmpty) {
      ttl = tmpLahir;
    }

    final isL = jk == 'Laki-laki';

    // Simpan context sebelum masuk ke builder async
    final ctx = context;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: _kWhite,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scroller) => ListView(
          controller: scroller,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: _kAccent.withValues(alpha: 0.1),
                  child: Text(
                    nama[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _kAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: _kText1,
                        ),
                      ),
                      if (panggilan.isNotEmpty)
                        Text(
                          '"$panggilan"',
                          style: TextStyle(
                            fontSize: 12,
                            color: _kText2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NIS: $nis',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isL
                                  ? Colors.blue.shade50
                                  : Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              jk,
                              style: TextStyle(
                                fontSize: 10,
                                color: isL ? Colors.blue : Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _divider(),

            // Data Pribadi
            _sectionTitle('Data Pribadi', Icons.person_outline_rounded),
            _infoRow(sheetCtx, 'Kelas / Kelompok', '$kelas â€” $kelompok'),

            _infoRow(sheetCtx, 'TTL', ttl),
            _infoRow(sheetCtx, 'Alamat', alamat),
            _infoRow(sheetCtx, 'No HP', hp, isWa: true, pesan: pesanOrangTua),

            const SizedBox(height: 12),
            _divider(),

            // Data Orang Tua
            _sectionTitle('Data Orang Tua', Icons.family_restroom_rounded),
            _infoRow(sheetCtx, 'Ayah', namaAyah),
            // _infoRow(sheetCtx, 'HP Ayah', hpAyah, isWa: true, pesan: pesanWa),
            _infoRow(
              sheetCtx,
              'HP Ayah',
              hpAyah,
              isWa: true,
              pesan: pesanOrangTua,
            ),
            _infoRow(sheetCtx, 'Ibu', namaIbu),
            _infoRow(
              sheetCtx,
              'HP Ibu',
              hpIbu,
              isWa: true,
              pesan: pesanOrangTua,
            ),
            _infoRow(
              sheetCtx,
              'WA Group ($waGroup)',
              noWaGroup,
              isWa: true,
              pesan: pesanOrangTua,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: _kAccent),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _kText1,
          ),
        ),
      ],
    ),
  );

  // --- Info Row dengan tombol WA -----------------------------------------------
  Widget _infoRow(
    BuildContext ctx,
    String label,
    String value, {
    bool isWa = false,
    String pesan = '',
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(fontSize: 12, color: _kText2)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kText1,
            ),
          ),
        ),
        // Tombol Chat WA â€” muncul hanya jika isWa=true dan nomor valid
        if (isWa && value.isNotEmpty && value != '-')
          InkWell(
            // onTap: () => _launchWA(ctx, value),
            onTap: () =>
                _launchWA(ctx, value, pesan: pesan.isNotEmpty ? pesan : null),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _divider() => Divider(color: Colors.grey.shade200, height: 1);

  // --- Skeleton ----------------------------------------------------------------
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, i) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
          ),
        ),
      ),
    );
  }

  // --- Error -------------------------------------------------------------------
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: _kText2, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Santri Card Widget --------------------------------------------------------