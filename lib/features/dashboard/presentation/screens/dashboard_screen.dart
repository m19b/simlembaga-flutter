import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_screen.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/pra_tahfidz_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/rekap_absen_screen.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';
import 'package:manajemen_tahsin_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/progress_screen.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/tahfidz_coming_soon_screen.dart';
import 'package:manajemen_tahsin_app/features/profile/presentation/profile_screen.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/features/tes/presentation/daftar_tes_screen.dart';
import 'package:manajemen_tahsin_app/features/tes/presentation/bloc/tes_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/theme_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_bottom_tabs.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/hari_libur_screen.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/repositories/hari_libur_repository.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/bloc/hari_libur_cubit.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/widgets/upcoming_holiday_widget.dart';

// --- Colors ---
const Color kBgColor = Color(0xFFF3F4F6);
const Color kHeaderColor = Color(0xFF0F4C2A);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

Color hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.tryParse('FF$h', radix: 16) ?? 0xFF000000);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(
            repository: DashboardRepository(
              networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
              localDataSource: LocalDataSourceImpl(),
            ),
            activeKelompokCubit: context.read<ActiveKelompokCubit>(),
          ),
        ),
        BlocProvider(
          create: (_) => HariLiburCubit(
            repository: HariLiburRepository(
              networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
            ),
          ),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

String mapSesi(String? sesi) {
  switch (sesi) {
    case '1': return 'Sesi Pagi';
    case '2': return 'Sesi Siang';
    case '3': return 'Sesi Sore';
    case '4': return 'Sesi Malam';
    default: return 'Sesi ${sesi ?? '-'}';
  }
}

class _DashboardViewState extends State<_DashboardView> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().fetchDashboard();
    _fetchHariLibur();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  void _fetchHariLibur() {
    final idKelompok = context.read<ActiveKelompokCubit>().state.activeId;
    context.read<HariLiburCubit>().fetch(
      tahun: DateTime.now().year,
      idKelompok: idKelompok,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pop(context); // Ttp loading
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  dynamic _getNextSchedule(List<dynamic> jadwalGuru) {
    if (jadwalGuru.isEmpty) return null;
    int currentDay = DateTime.now().weekday; // 1 = Senin, 7 = Minggu
    
    // Cari jadwal hari ini
    var todaySchedules = jadwalGuru.where((j) => (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) == currentDay).toList();
    if (todaySchedules.isNotEmpty) {
      // Cari sesi yang belum lewat jam pulangnya
      String currentTime = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:00";
      var upcomingToday = todaySchedules.where((j) => (j['jam_pulang']?.toString() ?? '23:59:59').compareTo(currentTime) >= 0).toList();
      if (upcomingToday.isNotEmpty) return upcomingToday.first;
    }
    
    // Cari jadwal di hari berikutnya
    var nextSchedules = jadwalGuru.where((j) => (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) > currentDay).toList();
    if (nextSchedules.isNotEmpty) {
      nextSchedules.sort((a, b) => (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo((int.tryParse(b['hari']?.toString() ?? '0') ?? 0)));
      return nextSchedules.first;
    }
    
    // Jika tidak ada sisa minggu ini, ambil jadwal pertama di minggu depan
    var allSorted = List.from(jadwalGuru);
    allSorted.sort((a, b) => (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo(int.tryParse(b['hari']?.toString() ?? '0') ?? 0));
    if (allSorted.isNotEmpty) return allSorted.first;
    return null;
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: kHeaderColor,
        onRefresh: () async =>
            context.read<DashboardCubit>().fetchDashboard(forceRefresh: true),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SkeletonListWidget(itemCount: 5, itemHeight: 120),
              );
            }

            if (state is DashboardError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () => context.read<DashboardCubit>().fetchDashboard(forceRefresh: true),
              );
            }

            if (state is DashboardLoaded) {
              final data = state.data;
              final nextMengajar = _getNextSchedule(data.jadwalGuru);
              final nextKelas = _getNextSchedule(data.jadwalKelas);
              
              String countdownText = 'Tidak ada jadwal';
              dynamic nearest = _getNextSchedule([...data.jadwalGuru, ...data.jadwalKelas]);
              if (nearest != null) {
                int targetDay = int.tryParse(nearest['hari']?.toString() ?? '0') ?? 0;
                int currentDay = DateTime.now().weekday;
                if (targetDay == currentDay) {
                  String jamMasuk = nearest['jam_masuk']?.toString() ?? '00:00:00';
                  List<String> parts = jamMasuk.split(':');
                  if (parts.length >= 2) {
                    DateTime now = DateTime.now();
                    DateTime targetTime = DateTime(now.year, now.month, now.day, int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0, parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0);
                    Duration diff = targetTime.difference(now);
                    if (diff.isNegative) {
                      countdownText = 'Sedang Berlangsung';
                    } else {
                      int h = diff.inHours;
                      int m = diff.inMinutes.remainder(60);
                      int s = diff.inSeconds.remainder(60);
                      if (h > 0) countdownText = 'Mulai: ${h}j ${m}m ${s}d';
                      else countdownText = 'Mulai: ${m}m ${s}d';
                    }
                  }
                } else {
                  int diffDay = targetDay - currentDay;
                  if (diffDay < 0) diffDay += 7;
                  countdownText = '${diffDay} hari lagi';
                }
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(data.guruName, data.role, data.namaKelompok,
                      data.namaKelas),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 20),
                          child: Column(
                            children: [
                              _buildDateAndCountdown(countdownText),
                              const SizedBox(height: 16),
                              _buildStatCards(data),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildChartSection(data.chartKecepatan,
                            data.summary.totalSantri.toString()),
                        _buildMenuSection(),
                        if (nextMengajar != null)
                          _buildJadwalTerdekat("Jadwal Mengajar Terdekat", nextMengajar),
                        if (nextKelas != null)
                          _buildJadwalTerdekat("Jadwal Kelas Terdekat", nextKelas),
                        // ── Libur terdekat ──
                        BlocBuilder<HariLiburCubit, HariLiburState>(
                          builder: (context, hlState) {
                            if (hlState is HariLiburLoaded) {
                              return UpcomingHolidayWidget(
                                  allHolidays: hlState.items);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        if (state.isRefreshing)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        const SizedBox(height: 16),
                        DashboardBottomTabs(data: data, currentTime: _currentTime),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
      String name, String role, String kelompok, String kelas) {
    return SliverAppBar(
      expandedHeight: 220,
      toolbarHeight: 56,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : kHeaderColor,
      actions: [
        const SizedBox(width: 4),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline,
                color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.dark_mode_outlined,
                color: Colors.amber, size: 20),
          ),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout_outlined,
                color: Colors.white, size: 20),
          ),
          onPressed: _handleLogout,
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isCollapsed = constraints.biggest.height <= (MediaQuery.of(context).padding.top + 56 + 10);
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text('$name · $role',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: GlobalHeaderBackground(),
                ),
                Positioned(
                  left: 20,
                  bottom: 50,
                  right: 20,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Assalamu'alaikum Wr. Wb.,",
                            style: GoogleFonts.dmSans(
                                color: Colors.white70, fontSize: 13)),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white, fontSize: 22),
                            children: [
                              TextSpan(
                                  text: '$name ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: '· $role',
                                  style: const TextStyle(
                                      color: Color(0xFF22C55E),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildKelompokSelector(kelompok),
                              const SizedBox(width: 8),
                              _buildCategorySelector(),
                              const SizedBox(width: 8),
                              _buildContextChip(Icons.school_outlined, kelas),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContextChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildKelompokSelector(String fallbackNama) {
    return BlocBuilder<ActiveKelompokCubit, ActiveKelompokState>(
      builder: (context, state) {
        if (state.allowedKelompok.isEmpty) {
          return _buildContextChip(Icons.business_outlined, fallbackNama);
        }

        // Pastikan activeId ada di dalam list items
        int? validActiveId = state.activeId > 0 ? state.activeId : null;
        final hasActiveId = state.allowedKelompok.any((k) {
          final id = k['id_kelompok'] ?? k['id'];
          final intId = id is String ? int.tryParse(id) : (id as int?);
          return intId == validActiveId;
        });
        if (!hasActiveId) validActiveId = null;

        return Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: validActiveId,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
              dropdownColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : kHeaderColor,
              isDense: true,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              onChanged: (val) {
                if (val != null) {
                  context.read<ActiveKelompokCubit>().changeKelompok(val);
                }
              },
              items: state.allowedKelompok.map((k) {
                final id = k['id_kelompok'] ?? k['id'];
                final intId = id is String ? int.tryParse(id) : (id as int?);
                final nama = k['kelompok'] ?? k['nama_kelompok'] ?? 'Unknown';
                return DropdownMenuItem<int>(
                  value: intId ?? 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(nama),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    final cubit = context.read<DashboardCubit>();
    final activeId = cubit.activeKategori;
    
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: activeId,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          dropdownColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : kHeaderColor,
          isDense: true,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          onChanged: (val) => cubit.setKategori(val),
          items: const [
            DropdownMenuItem(value: null, child: Text('Semua Modul')),
            DropdownMenuItem(value: 1, child: Text('📚 Tahsin')),
            DropdownMenuItem(value: 2, child: Text('📖 Tahfidz')),
            DropdownMenuItem(value: 3, child: Text('🌱 Pra Tahfidz')),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndCountdown(String countdownText) {
    final hijri = HijriCalendar.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: kHeaderColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${hijri.hDay} ${const [
                    '',
                    'Muharram',
                    'Safar',
                    'Rabiul Awal',
                    'Rabiul Akhir',
                    'Jumadil Awal',
                    'Jumadil Akhir',
                    'Rajab',
                    "Sya'ban",
                    'Ramadan',
                    'Syawal',
                    "Dzulqa'dah",
                    'Dzulhijjah',
                  ][hijri.hMonth]} ${hijri.hYear} H',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.how_to_vote_outlined,
                      color: Colors.blue.shade700, size: 14),
                  const SizedBox(width: 6),
                  Text(countdownText,
                      style: GoogleFonts.dmSans(
                          color: Colors.blue.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDetailModal(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(4)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const Spacer(),
                    IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(),
              Flexible(child: content),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatCards(dynamic data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          StatCard(
            label: 'Total Santri',
            value: data.summary.totalSantri.toString(),
            icon: Icons.people_outline,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
            onTap: () {
              Map<String, int> kelasCount = {};
              for (var s in data.santriList) {
                String k = s['tingkat']?.toString() ?? 'Lainnya';
                kelasCount[k] = (kelasCount[k] ?? 0) + 1;
              }
              _showDetailModal(
                context,
                'Rincian Total Santri',
                kelasCount.isEmpty ? const Center(child: Text('Data detail tidak tersedia')) : ListView(
                  padding: const EdgeInsets.all(16),
                  children: kelasCount.entries.toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.class_, color: Colors.blue, size: 20),
                          ),
                        ],
                      ),
                      title: Text('Kelas ${e.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${e.value} Santri', style: GoogleFonts.dmMono(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade700)),
                    );
                  }).toList(),
                )
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Sudah Absen',
            value: data.summary.hadir.toString(),
            icon: Icons.how_to_reg_rounded,
            colors: [const Color(0xFF34D399), const Color(0xFF059669)], // Emerald
            onTap: () {
              var listHadir = data.santriList.where((s) {
                 final h = s['id_kehadiran']?.toString() ?? '0';
                 return h != '0';
              }).toList();
              
              _showDetailModal(
                context,
                'Status Kehadiran',
                listHadir.isEmpty ? Center(child: Text('Belum ada data absensi hari ini. Total hadir di sistem: ${data.summary.hadir}')) : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listHadir.length,
                  itemBuilder: (_, i) {
                    final s = listHadir[i];
                    final k = s['id_kehadiran']?.toString() ?? '0';
                    Color c = Colors.grey;
                    String statusText = 'Tanpa Keterangan';
                    if (k == '1') { c = Colors.green; statusText = 'Hadir'; }
                    if (k == '3') { c = Colors.blue; statusText = 'Sakit'; }
                    if (k == '2') { c = Colors.orange; statusText = 'Izin'; }
                    if (k == '4') { c = Colors.red; statusText = 'Alpha'; }
                    
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          Icon(Icons.person, color: c),
                        ],
                      ),
                      title: Text(s['nama_santri']?.toString() ?? '-'),
                      subtitle: Text('Status: $statusText'),
                      trailing: Text(s['tingkat']?.toString() ?? ''),
                    );
                  }
                )
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Perlu\nPerhatian',
            value: data.summary.perluPerhatian.toString(),
            icon: Icons.warning_rounded,
            colors: [Colors.red.shade400, Colors.red.shade700],
            onTap: () {
              final list = data.urgentList as List<dynamic>;
              _showDetailModal(
                context,
                'Perlu Perhatian',
                list.isEmpty ? const Center(child: Text('Tidak ada santri bermasalah')) : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final s = list[i];
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          const Icon(Icons.warning, color: Colors.red),
                        ],
                      ),
                      title: Text(s['nama_santri']?.toString() ?? '-'),
                      subtitle: Text(s['jenis_masalah']?.toString() ?? 'Bermasalah'),
                      trailing: Text(s['tingkat']?.toString() ?? ''),
                    );
                  }
                )
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Siap Test',
            value: data.summary.siapTest.toString(),
            icon: Icons.assignment_turned_in,
            colors: [Colors.orange.shade400, Colors.orange.shade700],
            onTap: () {
              var listSiapTest = data.santriList.where((s) => s['harus_tes'] == 1 || s['harus_tes'] == '1').toList();
              var list = listSiapTest.isNotEmpty ? listSiapTest : (data.daftarTes as List<dynamic>);
              
              _showDetailModal(
                context,
                'Santri Siap Test',
                list.isEmpty ? Center(child: Text('Tidak ada data santri siap test secara spesifik. Total siap test sistem: ${data.summary.siapTest}.')) : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final s = list[i];
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          const Icon(Icons.assignment_turned_in, color: Colors.orange),
                        ],
                      ),
                      title: Text(s['nama_santri']?.toString() ?? '-'),
                      subtitle: Text('Tingkat: ${s['tingkat']?.toString() ?? '-'}'),
                    );
                  }
                )
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Belum Selesai',
            value: data.summary.belumDiinput.toString(),
            icon: Icons.pending_actions,
            colors: [Colors.purple.shade400, Colors.purple.shade700],
            onTap: () {
              var listBelum = data.santriList.where((s) {
                 final isInput = (int.tryParse(s['input_hari_ini']?.toString() ?? '0') ?? 0) > 0;
                 return !isInput;
              }).toList();
              
              _showDetailModal(
                context,
                'Belum Diinput',
                listBelum.isEmpty ? Center(child: Text('Terdapat ${data.summary.belumDiinput} santri yang belum diinput progresnya hari ini.')) : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listBelum.length,
                  itemBuilder: (_, i) {
                    final s = listBelum[i];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.purple.shade100,
                        child: Text('${i + 1}', style: TextStyle(color: Colors.purple.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(s['nama_santri']?.toString() ?? '-'),
                      subtitle: Text('Tingkat: ${s['tingkat']?.toString() ?? '-'}'),
                    );
                  }
                )
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<dynamic> chartData, String totalSantri) {
    if (chartData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.pie_chart_outline,
                  color: Color(0xFF16A34A), size: 20),
              const SizedBox(width: 8),
              Text(
                "Kecepatan Belajar Kelas",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: chartData.map((item) {
                          return PieChartSectionData(
                            value: (num.tryParse(item['value']?.toString() ?? '0') ?? 0).toDouble(),
                            color: hexToColor(
                                item['color']?.toString() ?? '#ccc'),
                            radius: 20.0,
                            showTitle: false,
                          );
                        }).toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalSantri,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Text('Santri',
                            style: GoogleFonts.dmSans(
                                fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: chartData.map((item) {
                    final total = double.tryParse(totalSantri) ?? 1;
                    final valNum = num.tryParse(item['value']?.toString() ?? '0') ?? 0;
                    final pct = total > 0
                        ? (valNum / total * 100).toStringAsFixed(0)
                        : '0';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: hexToColor(
                                  item['color']?.toString() ?? '#ccc'),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['label'] ?? '-',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: GoogleFonts.dmMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    final menus = [
      _MenuItemData(
          icon: Icons.trending_up_rounded,
          label: 'Progres\nTahsin',
          color: Colors.blue,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProgressScreen()))),
      _MenuItemData(
          icon: Icons.auto_stories_rounded,
          label: 'Progres Pra\nTahfidz',
          color: Colors.indigo,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PraTahfidzScreen()))),
      _MenuItemData(
          icon: Icons.auto_stories_rounded,
          label: 'Progres\nTahfidz',
          color: Colors.teal,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TahfidzScreen()))),
      _MenuItemData(
          icon: Icons.sports_basketball_outlined,
          label: 'Program\nEkstrakurikuler',
          color: Colors.deepOrange,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ComingSoonScreen(title: 'Program Ekstrakurikuler')))),
      _MenuItemData(
          icon: Icons.check_box_outlined,
          label: 'Absen\nSantri',
          color: Colors.green,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AbsenScreen()))),
      _MenuItemData(
          icon: Icons.calendar_month_outlined,
          label: 'Rekap\nAbsensi',
          color: Colors.blue.shade400,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RekapAbsenScreen()))),
      _MenuItemData(
          icon: Icons.assignment_outlined,
          label: 'Daftar\nTest',
          color: Colors.blue.shade600,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => TesCubit(), child: const DaftarTesScreen())))),
      _MenuItemData(
          icon: Icons.report_problem_outlined,
          label: 'Masalah\nSantri',
          color: Colors.red.shade400,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MasalahScreen()))),
      _MenuItemData(
          icon: Icons.calendar_month_rounded,
          label: 'Hari\nLibur',
          color: Colors.red.shade400,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HariLiburScreen()))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.grid_view_rounded,
                  color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 8),
              Text(
                "Menu Utama",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: menus.map((m) {
              return InkWell(
                onTap: m.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: m.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m.icon, color: m.color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        m.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalTerdekat(String title, dynamic item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = '${_getDayName(int.tryParse(item['hari']?.toString() ?? '0') ?? 0)}, ${mapSesi(item['sesi']?.toString())}';
    final toleransi = item['toleransi_terlambat'] ?? '0';
    final start = item['jam_masuk']?.toString().substring(0, 5) ?? '00:00';
    final end = item['jam_pulang']?.toString().substring(0, 5) ?? '00:00';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF334155)] : [Colors.teal.shade50, Colors.teal.shade100]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF475569) : Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: isDark ? Colors.tealAccent : Colors.teal.shade700, size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.teal.shade800)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.teal.shade900)),
                    Text('Toleransi Keterlambatan: $toleransi mnt', style: GoogleFonts.dmSans(color: isDark ? Colors.tealAccent.withOpacity(0.7) : Colors.teal.shade700, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.teal.shade600 : Colors.teal.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$start - $end', style: GoogleFonts.dmMono(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              )
            ],
          )
        ],
      ),
    );
  }
}


class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _MenuItemData(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

