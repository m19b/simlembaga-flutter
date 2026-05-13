import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'bloc/tes_cubit.dart';
import 'bloc/tes_state.dart';
import '../data/tes_model.dart';
import '../../auth/data/user_model.dart';
import '../../../../core/constants/api_config.dart';

class DaftarTesScreen extends StatefulWidget {
  const DaftarTesScreen({super.key});

  @override
  State<DaftarTesScreen> createState() => _DaftarTesScreenState();
}

class _DaftarTesScreenState extends State<DaftarTesScreen> {
  int _currentIndex = 0;
  String _baseUrl = '';

  // Grab-style Month Selector Logic
  late DateTime _selectedMonth;
  final ScrollController _monthScrollController = ScrollController();

  List<DateTime> _generateMonths() {
    final current = DateTime.now();
    return List.generate(8, (index) {
      return DateTime(current.year, current.month - 6 + index, 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _fetchBaseUrl();
    context.read<TesCubit>().loadDaftarTes();
    _loadRiwayat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthScrollController.hasClients) {
        _monthScrollController.animateTo(
          _monthScrollController.position.maxScrollExtent - 50,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchBaseUrl() async {
    final url = await ApiConfig.getBaseUrl();
    if (mounted) {
      setState(
        () => _baseUrl = url.replaceAll('/api', '').replaceAll('/public', ''),
      );
    }
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  void _loadRiwayat() {
    final tglMulai = DateFormat('yyyy-MM-dd').format(_selectedMonth);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final tglAkhir = DateFormat('yyyy-MM-dd').format(lastDay);

    context.read<TesCubit>().loadRiwayatTes(
      tglMulai: tglMulai,
      tglAkhir: tglAkhir,
      reload: true,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TesCubit, TesState>(
      listener: (context, state) {
        if (state is TesError) {
          _showError(state.message);
        } else if (state is TesActionSuccess) {
          _showSuccess(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F4C2A), // kHeaderColor
          title: Text(
            _currentIndex == 0 ? 'Daftar Calon Tes' : 'Riwayat Tes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [_buildCalonTesTab(), _buildRiwayatTab()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF0F4C2A),
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt_rounded),
              label: 'Calon Tes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: CALON TES ──────────────────────────────────────────────────────────

  Widget _buildCalonTesTab() {
    return BlocBuilder<TesCubit, TesState>(
      buildWhen: (prev, curr) {
        // Only react to non-riwayat states
        return curr is TesInitial || curr is TesLoading || curr is TesLoaded;
      },
      builder: (context, state) {
        if (state is TesLoading || state is TesInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0F4C2A)),
          );
        }

        if (state is TesLoaded) {
          final items = state.calonTesList;
          final reversedList = items.reversed.toList();

          return Column(
            children: [
              Expanded(
                child: reversedList.isEmpty
                    ? Center(
                        child: Text(
                          "Tidak ada santri untuk ditampilkan.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<TesCubit>().loadDaftarTes(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: reversedList.length,
                          itemBuilder: (context, index) {
                            final item = reversedList[index];
                            final bool tunggakan =
                                item.keuangan?.adaTunggakan ?? false;
                            final bool isTerdaftar = item.isTerdaftar;

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildAvatar(
                                          item.foto,
                                          item.namaSantri,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaSantri,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF1F2937,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "NIS: ${item.nis} • ${item.tingkat}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: tunggakan
                                                      ? Colors.red.shade50
                                                      : Colors.green.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      tunggakan
                                                          ? Icons
                                                                .warning_rounded
                                                          : Icons
                                                                .check_circle_rounded,
                                                      size: 14,
                                                      color: tunggakan
                                                          ? Colors.red.shade700
                                                          : Colors
                                                                .green
                                                                .shade700,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      tunggakan
                                                          ? "Ada Tunggakan"
                                                          : "Lunas",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: tunggakan
                                                            ? Colors
                                                                  .red
                                                                  .shade700
                                                            : Colors
                                                                  .green
                                                                  .shade700,
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
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: Colors.grey.shade100,
                                      height: 1,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            _buildInfoCol(
                                              "Sisa Reguler",
                                              "${item.sisaHal}",
                                              Colors.blue,
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: Colors.grey.shade200,
                                            ),
                                            const SizedBox(width: 16),
                                            _buildInfoCol(
                                              "Latihan",
                                              "${item.latSek}/${item.targetLatihan}",
                                              Colors.orange,
                                            ),
                                          ],
                                        ),
                                        // Action Button: Batal OR Daftarkan
                                        if (isTerdaftar)
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: Colors.red.shade400,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            onPressed: () {
                                              if (item.idDaftar != null) {
                                                context
                                                    .read<TesCubit>()
                                                    .batalkanTes(
                                                      item.idDaftar!,
                                                    );
                                              }
                                            },
                                            child: Text(
                                              "Batal",
                                              style: TextStyle(
                                                color: Colors.red.shade600,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0F4C2A,
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                            ),
                                            onPressed: () =>
                                                _daftarkanTes(item),
                                            child: Text(
                                              "Daftarkan",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return Center(
          child: ElevatedButton.icon(
            onPressed: () => context.read<TesCubit>().loadDaftarTes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String foto, String nama) {
    if (_baseUrl.isEmpty || foto.isEmpty) {
      return _buildFallbackAvatar(nama);
    }

    // Attempt Image URL
    final imageUrl = '$_baseUrl/uploads/santri/$foto';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(nama);
        },
      ),
    );
  }

  Widget _buildFallbackAvatar(String nama) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.blue.shade50,
      child: Text(
        nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color.shade700,
          ),
        ),
      ],
    );
  }

  // ─── Modal Info Keuangan ────────────────────────────────────────────────────────

  void _daftarkanTes(CalonTes item) {
    final tunggakan = item.keuangan?.adaTunggakan ?? false;
    final pesanTunggakan =
        item.keuangan?.pesan ?? "Santri memiliki tunggakan tagihan.";
    final isBocor = item.bocor.isNotEmpty;

    if (tunggakan || isBocor) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.new_releases_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                "Info Keuangan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tunggakan)
                    Text(
                      pesanTunggakan,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  if (isBocor) ...[
                    if (tunggakan) const SizedBox(height: 8),
                    Text(
                      "Tagihan/Piutang Santri.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    "Pendaftaran tes tetap dapat dilanjutkan.",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (item.keuangan?.detail != null &&
                      item.keuangan!.detail!.isNotEmpty) ...[
                    Text(
                      "Rincian Tagihan:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: item.keuangan!.detail!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final detail = item.keuangan!.detail![idx];
                        final formatter = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        );

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.keterangan,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Sisa: ${formatter.format(detail.sisaPiutang)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (isBocor) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Rincian Kebocoran Data:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: item.bocor.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final leak = item.bocor[idx];
                        if (leak is! Map) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Periode: ${leak['periode'] ?? '-'} (${leak['nama_jenis'] ?? '-'})",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Potensi Nominal: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(double.tryParse(leak['nominal']?.toString() ?? '0') ?? 0)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C2A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _processDaftar(item);
              },
              child: Text(
                "Lanjutkan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _processDaftar(item);
    }
  }

  void _processDaftar(CalonTes item) {
    context.read<TesCubit>().daftarkanTes(
      nis: item.nis,
      idKelas: item.idKelas.toString(),
      idKelompok: item.idKelompok.toString(),
    );
  }

  // ─── TAB 2: RIWAYAT TES ────────────────────────────────────────────────────────

  Widget _buildRiwayatTab() {
    return Column(
      children: [
        // Horizontal Month Selector
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.builder(
            controller: _monthScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _generateMonths().length,
            itemBuilder: (context, index) {
              final date = _generateMonths()[index];
              final isSelected =
                  date.year == _selectedMonth.year &&
                  date.month == _selectedMonth.month;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    DateFormat('MMM yyyy').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(
                    0xFF0F4C2A,
                  ), // Grab-like green highlight
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide.none,
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected && !isSelected) {
                      setState(() => _selectedMonth = date);
                      _loadRiwayat();
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Riwayat List
        Expanded(
          child: BlocBuilder<TesCubit, TesState>(
            buildWhen: (prev, curr) {
              // Hanya bereaksi terhadap state riwayat agar tidak terganggu proses tab lain
              return curr is TesRiwayatLoading ||
                  curr is TesRiwayatLoaded ||
                  curr is TesInitial;
            },
            builder: (context, state) {
              if (state is TesRiwayatLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F4C2A)),
                );
              }

              if (state is TesRiwayatLoaded) {
                final list = state.riwayatList;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada riwayat tes pada bulan ini.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final isLulus =
                        item.statusKelulusan.toLowerCase() == 'lulus';

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profil Santri
                            Row(
                              children: [
                                _buildAvatar(item.foto, item.namaSantri),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.namaSantri,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "NIS: ${item.nis} • ${item.kelompok}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey.shade100, height: 1),
                            const SizedBox(height: 12),
                            // Detail Grid 1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Kelas Asal",
                                    item.kelasAsal,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Naik Ke",
                                    item.naikKe,
                                    isBadge: true,
                                    badgeColor: isLulus
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    bgColor: isLulus
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    icon: isLulus
                                        ? Icons.call_made_rounded
                                        : Icons.sync_alt_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Detail Grid 2
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Tgl Test",
                                    _formatDate(item.tglTest),
                                  ),
                                ),
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Penguji",
                                    item.penguji,
                                  ),
                                ),
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Hasil",
                                    isLulus ? "LULUS" : "TIDAK LULUS",
                                    isBadge: true,
                                    badgeColor: isLulus
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    bgColor: isLulus
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Detail Grid 3: Info Pendaftaran
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Tgl Daftar",
                                    _formatDate(item.tglDaftar),
                                  ),
                                ),
                                Expanded(
                                  child: _buildRiwayatInfo(
                                    "Pendaftar",
                                    item.namaPendaftar,
                                  ),
                                ),
                                const Spacer(), // Untuk menjaga alignment
                              ],
                            ),
                            if (item.keterangan != null &&
                                item.keterangan!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  '"${item.keterangan}"',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              // Initial / Errors
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F4C2A)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatInfo(
    String label,
    String value, {
    bool isBadge = false,
    Color? badgeColor,
    Color? bgColor,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor ?? badgeColor?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 12, color: badgeColor),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr == '-' || dateStr.isEmpty || dateStr == 'null') return '-';
    try {
      // Handle format YYYY-MM-DD
      final parts = dateStr.split(' ').first.split('-');
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1]}-${parts[0]}";
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }
}
