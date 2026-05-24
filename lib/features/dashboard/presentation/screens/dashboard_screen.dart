import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/services/absensi_api_service.dart';
import 'package:manajemen_tahsin_app/core/api/services/auth_api_service.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_mandiri_screen.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/pra_tahfidz_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/rekap_absen_screen.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';
import 'package:manajemen_tahsin_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:manajemen_tahsin_app/features/pengaturan/presentation/bloc/header_settings_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/progress_screen.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/tahfidz_coming_soon_screen.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/features/tes/presentation/daftar_tes_screen.dart';
import 'package:manajemen_tahsin_app/features/profile/presentation/profile_screen.dart';
import 'package:manajemen_tahsin_app/core/state/sync_center_cubit.dart';
import 'package:manajemen_tahsin_app/core/utils/sync_manager.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/screens/jadwal_kelas_screen.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/screens/jadwal_guru_screen.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_bottom_tabs.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/hari_libur_screen.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/repositories/hari_libur_repository.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/bloc/hari_libur_cubit.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';
import 'package:manajemen_tahsin_app/core/constants/api_config.dart';
import 'package:manajemen_tahsin_app/features/pengaturan/presentation/pengaturan_screen.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/screens/catatan_master_screen.dart';

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
    case '1':
      return 'Sesi Pagi';
    case '2':
      return 'Sesi Siang';
    case '3':
      return 'Sesi Sore';
    case '4':
      return 'Sesi Malam';
    default:
      return 'Sesi ${sesi ?? '-'}';
  }
}

class _DashboardViewState extends State<_DashboardView> {
  late Timer _timer;
  String _currentTime = '';
  UserModel? _currentUser;
  String? _baseUrl;
  late String _randomGreeting;
  Map<String, dynamic> _statusAbsen = {};

  @override
  void initState() {
    super.initState();
    final greetings = [
      "Assalamu'alaikum Wr. Wb.",
      "Ahlan wa Sahlan!",
      "Barakallahu Fiikum",
    ];
    _randomGreeting =
        greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];

    _loadUser();
    context.read<DashboardCubit>().fetchDashboard();
    _fetchHariLibur();
    
    // Sinkronisasi data santri binaan secara background
    AbsensiApiService.syncSantriBinaan();

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  Future<void> _fetchStatusAbsen(int idKelompok) async {
    final isOnline = LocalNetworkChecker().currentStatus == LocalNetworkStatus.online;
    if (!isOnline) return;

    try {
      final res = await AbsensiApiService.getStatusAbsenMandiri(idKelompok);
      if (mounted) {
        setState(() {
          _statusAbsen =
              (res['data']?['status_absen'] as Map<String, dynamic>?) ?? {};
        });
      }
    } catch (_) {}
  }

  Future<void> _handleAbsenMandiri(String tipe, int idKelompok) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await AbsensiApiService.postAbsenMandiri(
        tipe: tipe,
        idKelompok: ActiveKelompokCubit.activeKelompokId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Berhasil absen $tipe'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchStatusAbsen(idKelompok);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal absen: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('LOGGED_IN_USER');
    _baseUrl = await ApiConfig.getBaseUrl();

    if (userStr != null) {
      if (mounted) {
        setState(() {
          _currentUser = UserModel.fromJson(json.decode(userStr));
        });
      }
    }

    // Hard Sync Profile to get fresh foto_url directly from backend (mirrors profile_screen.dart)
    final isOnline = LocalNetworkChecker().currentStatus == LocalNetworkStatus.online;
    if (!isOnline) return;

    try {
      final resp = await AuthApiService.getProfile();
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          final freshFoto = data['foto_url']?.toString();
          if (freshFoto != null &&
              freshFoto.isNotEmpty &&
              _currentUser != null) {
            _currentUser = UserModel(
              id: _currentUser!.id,
              username: _currentUser!.username,
              email: _currentUser!.email,
              group: _currentUser!.group,
              nig: _currentUser!.nig,
              idKelompok: _currentUser!.idKelompok,
              kelompokList: _currentUser!.kelompokList,
              fotoUser: freshFoto,
              logoMetode: _currentUser!.logoMetode,
              logoLembaga: _currentUser!.logoLembaga,
            );
            prefs.setString('LOGGED_IN_USER', json.encode(_currentUser!.toJson()));
            prefs.setString('cached_foto_profil', freshFoto);
            prefs.setString('cached_nama_guru', _currentUser!.username);
          }
        });
      }
    } catch (e) {
      log('Sync profile failed on dashboard: $e');
    }
  }

  Widget _buildAbsImage(
    String? rawUrl,
    IconData fallbackIcon, {
    double size = 40,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final iconColor = isDark ? Theme.of(context).colorScheme.primary : Colors.white;
        final bgColor = isDark
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.15);

        return SizedBox(
          width: size,
          height: size,
          child: ClipOval(
            child: Builder(
              builder: (context) {
                final url = _fixUrl(rawUrl);
                if (url != null && url.isNotEmpty) {
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: bgColor,
                      child: Icon(fallbackIcon, color: iconColor, size: 24),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: bgColor,
                      child: Icon(fallbackIcon, color: iconColor, size: 24),
                    ),
                  );
                }
                return Container(
                  color: bgColor,
                  child: Icon(fallbackIcon, color: iconColor, size: 24),
                );
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.black26,
              border: Border.all(color: isDark ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? Theme.of(context).colorScheme.primary : Colors.white,
            ),
          ),
        );
      }
    );
  }

  String? _fixUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (_baseUrl == null) return path;

    String baseUrl = _baseUrl!;
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return baseUrl + path.substring(1);
    } else if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return '$baseUrl/$path';
    }
    return baseUrl + path;
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
      await AuthApiService.logout();
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
    var todaySchedules = jadwalGuru
        .where(
          (j) =>
              (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) == currentDay,
        )
        .toList();
    if (todaySchedules.isNotEmpty) {
      // Cari sesi yang belum lewat jam pulangnya
      String currentTime =
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:00";
      var upcomingToday = todaySchedules
          .where(
            (j) =>
                (j['jam_pulang']?.toString() ?? '23:59:59').compareTo(
                  currentTime,
                ) >=
                0,
          )
          .toList();
      if (upcomingToday.isNotEmpty) return upcomingToday.first;
    }

    // Cari jadwal di hari berikutnya
    var nextSchedules = jadwalGuru
        .where(
          (j) => (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) > currentDay,
        )
        .toList();
    if (nextSchedules.isNotEmpty) {
      nextSchedules.sort(
        (a, b) => (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo(
          (int.tryParse(b['hari']?.toString() ?? '0') ?? 0),
        ),
      );
      return nextSchedules.first;
    }

    // Jika tidak ada sisa minggu ini, ambil jadwal pertama di minggu depan
    var allSorted = List.from(jadwalGuru);
    allSorted.sort(
      (a, b) => (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo(
        int.tryParse(b['hari']?.toString() ?? '0') ?? 0,
      ),
    );
    if (allSorted.isNotEmpty) return allSorted.first;
    return null;
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[50]
          : null,
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
                onRetry: () => context.read<DashboardCubit>().fetchDashboard(
                  forceRefresh: true,
                ),
              );
            }

            if (state is DashboardLoaded) {
              final data = state.data;

              String countdownText = 'Tidak ada jadwal';
              dynamic nearest = _getNextSchedule([
                ...data.jadwalGuru,
                ...data.jadwalKelas,
              ]);
              if (nearest != null) {
                int targetDay =
                    int.tryParse(nearest['hari']?.toString() ?? '0') ?? 0;
                int currentDay = DateTime.now().weekday;
                if (targetDay == currentDay) {
                  String jamMasuk =
                      nearest['jam_masuk']?.toString() ?? '00:00:00';
                  List<String> parts = jamMasuk.split(':');
                  if (parts.length >= 2) {
                    DateTime now = DateTime.now();
                    DateTime targetTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      int.tryParse(parts[0]) ?? 0,
                      int.tryParse(parts[1]) ?? 0,
                      parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
                    );
                    Duration diff = targetTime.difference(now);
                    if (diff.isNegative) {
                      countdownText = 'Sedang Berlangsung';
                    } else {
                      int h = diff.inHours;
                      int m = diff.inMinutes.remainder(60);
                      int s = diff.inSeconds.remainder(60);
                      if (h > 0) {
                        countdownText = 'Mulai: ${h}j ${m}m ${s}d';
                      } else {
                        countdownText = 'Mulai: ${m}m ${s}d';
                      }
                    }
                  }
                } else {
                  int diffDay = targetDay - currentDay;
                  if (diffDay < 0) diffDay += 7;
                  countdownText = '$diffDay hari lagi';
                }
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                      _buildSliverAppBar(
                        data.guruName,
                        data.role,
                        data.namaKelompok,
                        data.namaKelas,
                        state.availableKategori,
                        state.availableKelas,
                        state.selectedKelas,
                      ),
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
                            const SizedBox(height: 24),
                            _buildMenuSection(data),
                            const SizedBox(height: 24),
                            _buildJadwalSection(data),
                            const SizedBox(height: 24),
                            _buildChartSection(
                              data.chartKecepatan,
                              data.summary.totalSantri.toString(),
                            ),
                            const SizedBox(height: 24),
                            if (state.isRefreshing)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            DashboardBottomTabs(
                              data: data,
                              currentTime: _currentTime,
                            ),
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
    String name,
    String role,
    String kelompok,
    String kelas,
    List<Map<String, dynamic>> availableKategori,
    List<Map<String, dynamic>> availableKelas,
    Map<String, dynamic>? selectedKelas,
  ) {
    return SliverAppBar(
      expandedHeight: 280,
      toolbarHeight: 64,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : kHeaderColor,
      actions: [
        _buildSyncBtn(),
        const SizedBox(width: 4),
        _buildActionBtn(Icons.logout_outlined, _handleLogout),
        const SizedBox(width: 8),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isCollapsed =
              constraints.biggest.height <=
              (MediaQuery.of(context).padding.top + 64 + 10);
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            collapseMode: CollapseMode.pin,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Row(
                children: [
                  _buildAbsImage(
                    _currentUser?.fotoUser,
                    Icons.person,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  _buildAbsImage(
                    _currentUser?.logoMetode,
                    Icons.menu_book_outlined,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  _buildAbsImage(
                    _currentUser?.logoLembaga,
                    Icons.account_balance_outlined,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 130,
                  ), // Prevent text bleeding into actions
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(child: GlobalHeaderBackground()),
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<HeaderSettingsCubit, List<HeaderImageConfig>>(
                          builder: (context, headerConfigList) {
                            final List<Widget> imageWidgets = [];
                            
                            for (final config in headerConfigList) {
                              if (!config.isVisible) continue;
                              
                              Widget? imgWidget;
                              if (config.id == 'profil') {
                                imgWidget = _buildAbsImage(_currentUser?.fotoUser, Icons.person, size: 48);
                              } else if (config.id == 'metode') {
                                imgWidget = _buildAbsImage(_currentUser?.logoMetode, Icons.menu_book_outlined, size: 48);
                              } else if (config.id == 'lembaga') {
                                imgWidget = _buildAbsImage(_currentUser?.logoLembaga, Icons.account_balance_outlined, size: 48);
                              }
                              
                              if (imgWidget != null) {
                                imageWidgets.add(imgWidget);
                                imageWidgets.add(const SizedBox(width: 6));
                              }
                            }
                            
                            // Hapus SizedBox terakhir jika ada
                            if (imageWidgets.isNotEmpty) {
                              imageWidgets.removeLast();
                            }
                            
                            return Row(children: imageWidgets);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _randomGreeting,
                          style: GoogleFonts.dmSans(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildKelompokSelector(kelompok),
                              const SizedBox(width: 8),
                              _buildCategorySelector(availableKategori),
                              const SizedBox(width: 8),
                              _buildKelasSelector(availableKelas, selectedKelas),
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

  Widget _buildSyncBtn() {
    return BlocBuilder<SyncCenterCubit, SyncCenterState>(
      builder: (context, state) {
        final hasQueue = state.totalAntrean > 0;
        final icon = hasQueue ? Icons.cloud_upload : Icons.cloud_done;
        final color = hasQueue ? Colors.orange : Colors.white;

        Widget btn = IconButton(
          icon: Icon(icon, color: color),
          onPressed: () {
            _showSyncBottomSheet(context);
          },
        );

        if (hasQueue) {
          btn = Stack(
            alignment: Alignment.center,
            children: [
              btn,
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${state.totalAntrean}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          );
        }

        return btn;
      },
    );
  }

  void _showSyncBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<SyncCenterCubit, SyncCenterState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.totalAntrean == 0) ...[
                    const Icon(Icons.check_circle_outline, size: 50, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Semua Data Tersinkronisasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Ada ${state.totalAntrean} data tertunda karena masalah jaringan. Data ini tersimpan aman di HP Anda.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.daftarAntrean.length,
                        itemBuilder: (context, index) {
                          final item = state.daftarAntrean[index];
                          // Format payload summary for UI
                          String detail = item.endpoint;
                          try {
                            final map = json.decode(item.payloadJson);
                            if (map is Map) {
                              if (map.containsKey('nis')) detail = 'NIS: ${map['nis']}';
                              if (map.containsKey('rows')) detail = 'Massal: ${map['rows'].length} santri';
                            }
                          } catch (_) {}

                          return ListTile(
                            leading: const Icon(Icons.sync_problem, color: Colors.orange),
                            title: Text(
                              DateFormat('dd MMM HH:mm').format(item.timestamp),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: Text(
                              detail,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF0F4C2A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          
                          // Tampilkan loading overlay
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            },
                          );
                          
                          try {
                            await OfflineSyncManager().syncQueueManual();
                          } finally {
                            // Tutup loading overlay
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          'Sinkronkan Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContextChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
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
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: validActiveId,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 16,
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : kHeaderColor,
              isDense: true,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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
                      const Icon(
                        Icons.business_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
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

  Widget _buildCategorySelector(List<Map<String, dynamic>> availableKategori) {
    final cubit = context.read<DashboardCubit>();
    final activeId = cubit.activeKategori;

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: activeId,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 16,
          ),
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : kHeaderColor,
          isDense: true,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (val) => cubit.setKategori(val),
          items: availableKategori.map((kat) {
            return DropdownMenuItem<int?>(
              value: kat['id'],
              child: Text(kat['nama']),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Dropdown Kelas — Cascading Level-2 (mengikuti kategori aktif)
  Widget _buildKelasSelector(
    List<Map<String, dynamic>> availableKelas,
    Map<String, dynamic>? selectedKelas,
  ) {
    final cubit = context.read<DashboardCubit>();
    final isEmpty = availableKelas.isEmpty;

    // Gunakan String? (id_kelas) sebagai value agar Flutter equality bekerja.
    // Map<String,dynamic> tidak comparable by value — jika referensi berbeda,
    // Flutter akan melempar "There should be exactly one item with value null" error.
    final String? currentId = selectedKelas?['id_kelas']?.toString();
    final bool isValid = currentId == null ||
        availableKelas.any((k) => k['id_kelas']?.toString() == currentId);
    final String? safeId = isValid ? currentId : null;

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isEmpty
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeId,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isEmpty ? Colors.white38 : Colors.white,
            size: 16,
          ),
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : kHeaderColor,
          isDense: true,
          onChanged: isEmpty
              ? null
              : (val) {
                  if (val == null) {
                    cubit.setKelas(null);
                  } else {
                    // Cari objek kelas yang sesuai berdasarkan id_kelas string
                    final found = availableKelas.where(
                      (k) => k['id_kelas']?.toString() == val,
                    ).toList();
                    cubit.setKelas(found.isNotEmpty ? found.first : null);
                  }
                },
          style: GoogleFonts.dmSans(
            color: isEmpty ? Colors.white38 : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          items: [
            // "Semua Kelas" selalu ada di urutan pertama
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    isEmpty ? 'Pilih Kategori' : 'Semua Kelas',
                    style: GoogleFonts.dmSans(
                      color: isEmpty ? Colors.white38 : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Daftar kelas dinamis dari state (value = id_kelas sebagai String)
            ...availableKelas.map((kelas) {
              return DropdownMenuItem<String?>(
                value: kelas['id_kelas']?.toString(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.class_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      kelas['tingkat']?.toString() ?? '-',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
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
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: kHeaderColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${hijri.hDay} ${const ['', 'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir', 'Jumadil Awal', 'Jumadil Akhir', 'Rajab', "Sya'ban", 'Ramadan', 'Syawal', "Dzulqa'dah", 'Dzulhijjah'][hijri.hMonth]} ${hijri.hYear} H',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                  Icon(
                    Icons.how_to_vote_outlined,
                    color: Colors.blue.shade700,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    countdownText,
                    style: GoogleFonts.dmSans(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(child: content),
            ],
          ),
        );
      },
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
                kelasCount.isEmpty
                    ? const Center(child: Text('Data detail tidak tersedia'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: kelasCount.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              final i = entry.key;
                              final e = entry.value;
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${i + 1}.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.class_,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  'Kelas ${e.key}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  '${e.value} Santri',
                                  style: GoogleFonts.dmMono(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Sudah Absen',
            value: data.summary.hadir.toString(),
            icon: Icons.how_to_reg_rounded,
            colors: [
              const Color(0xFF34D399),
              const Color(0xFF059669),
            ], // Emerald
            onTap: () {
              var listHadir = data.santriList.where((s) {
                final h = s['id_kehadiran']?.toString() ?? '0';
                return h != '0';
              }).toList();

              _showDetailModal(
                context,
                'Status Kehadiran',
                listHadir.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data absensi hari ini. Total hadir di sistem: ${data.summary.hadir}',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listHadir.length,
                        itemBuilder: (_, i) {
                          final s = listHadir[i];
                          final k = s['id_kehadiran']?.toString() ?? '0';
                          Color c = Colors.grey;
                          String statusText = 'Tanpa Keterangan';
                          if (k == '1') {
                            c = Colors.green;
                            statusText = 'Hadir';
                          }
                          if (k == '3') {
                            c = Colors.blue;
                            statusText = 'Sakit';
                          }
                          if (k == '2') {
                            c = Colors.orange;
                            statusText = 'Izin';
                          }
                          if (k == '4') {
                            c = Colors.red;
                            statusText = 'Alpha';
                          }

                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${i + 1}.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.person, color: c),
                              ],
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text('Status: $statusText'),
                            trailing: Text(s['tingkat']?.toString() ?? ''),
                          );
                        },
                      ),
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
                list.isEmpty
                    ? const Center(child: Text('Tidak ada santri bermasalah'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${i + 1}.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.warning, color: Colors.red),
                              ],
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text(
                              s['jenis_masalah']?.toString() ?? 'Bermasalah',
                            ),
                            trailing: Text(s['tingkat']?.toString() ?? ''),
                          );
                        },
                      ),
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
              var listSiapTest = data.santriList
                  .where((s) => s['harus_tes'] == 1 || s['harus_tes'] == '1')
                  .toList();
              var list = listSiapTest.isNotEmpty
                  ? listSiapTest
                  : (data.daftarTes as List<dynamic>);

              _showDetailModal(
                context,
                'Santri Siap Test',
                list.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data santri siap test secara spesifik. Total siap test sistem: ${data.summary.siapTest}.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${i + 1}.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text(
                              'Tingkat: ${s['tingkat']?.toString() ?? '-'}',
                            ),
                          );
                        },
                      ),
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
                final isInput =
                    (int.tryParse(s['input_hari_ini']?.toString() ?? '0') ??
                        0) >
                    0;
                return !isInput;
              }).toList();

              _showDetailModal(
                context,
                'Belum Diinput',
                listBelum.isEmpty
                    ? Center(
                        child: Text(
                          'Terdapat ${data.summary.belumDiinput} santri yang belum diinput progresnya hari ini.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listBelum.length,
                        itemBuilder: (_, i) {
                          final s = listBelum[i];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.purple.shade100,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text(
                              'Tingkat: ${s['tingkat']?.toString() ?? '-'}',
                            ),
                          );
                        },
                      ),
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
              const Icon(
                Icons.pie_chart_outline,
                color: Color(0xFF16A34A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Kecepatan Belajar Kelas",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
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
                            value:
                                (num.tryParse(
                                          item['value']?.toString() ?? '0',
                                        ) ??
                                        0)
                                    .toDouble(),
                            color: hexToColor(
                              item['color']?.toString() ?? '#ccc',
                            ),
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Santri',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
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
                    final valNum =
                        num.tryParse(item['value']?.toString() ?? '0') ?? 0;
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
                                item['color']?.toString() ?? '#ccc',
                              ),
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
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: GoogleFonts.dmMono(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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

  Widget _buildJadwalSection(DashboardModel data) {
    dynamic nextJadwalKelas = _getNextSchedule(data.jadwalKelas);
    dynamic nextJadwalGuru = _getNextSchedule(data.jadwalGuru);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildJadwalTerdekatCard('Jadwal Kelas', nextJadwalKelas, Icons.class_outlined, Colors.indigo, () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalKelasScreen(jadwalList: data.jadwalKelas)));
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildJadwalTerdekatCard('Jadwal Guru', nextJadwalGuru, Icons.person_outline, Colors.teal, () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalGuruScreen(jadwalList: data.jadwalGuru)));
                })),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildAbsenCard(data)),
                const SizedBox(width: 12),
                Expanded(
                  child: BlocBuilder<HariLiburCubit, HariLiburState>(
                    builder: (context, hlState) {
                      if (hlState is HariLiburLoaded) {
                        return _buildLiburCard(hlState.items);
                      }
                      return _buildLiburCard([]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenCard(DashboardModel data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sudahDatang = _statusAbsen['sudah_datang'] == true;
    final sudahPulang = _statusAbsen['sudah_pulang'] == true;
    
    String jamMasuk = _statusAbsen['jam_masuk']?.toString() ?? '--:--';
    if (jamMasuk.length > 5) jamMasuk = jamMasuk.substring(0, 5);
    String jamPulang = _statusAbsen['jam_keluar']?.toString() ?? '--:--';
    if (jamPulang.length > 5) jamPulang = jamPulang.substring(0, 5);

    // Fetch status lazily when card is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_statusAbsen.isEmpty) {
        _fetchStatusAbsen(data.idKelompok);
      }
    });

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AbsenMandiriScreen(
          namaGuru: data.guruName,
          nig: data.nig,
          idKelompok: data.idKelompok,
        )));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.shade600.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: Colors.blue.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Absen',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'M: $jamMasuk',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'P: $jamPulang',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: sudahDatang && sudahPulang
                  ? null
                  : () => _handleAbsenMandiri(
                      sudahDatang ? 'pulang' : 'datang', data.idKelompok),
              style: ElevatedButton.styleFrom(
                backgroundColor: sudahDatang
                    ? (isDark ? const Color(0xFF374151) : Colors.grey.shade200)
                    : const Color(0xFF16A34A),
                foregroundColor: sudahDatang ? Colors.grey : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                sudahDatang
                    ? (sudahPulang ? '✓' : 'Pulang')
                    : 'Masuk',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiburCard(List<HariLiburModel> allHolidays) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    HariLiburModel? nearest;
    for (var h in allHolidays) {
      if (h.tanggalMulai.compareTo(todayStr) >= 0 || (h.tanggalAkhir.isNotEmpty && h.tanggalAkhir.compareTo(todayStr) >= 0)) {
        nearest = h;
        break;
      }
    }

    String title = 'Libur Terdekat';
    String timeInfo = 'Tidak ada libur';

    if (nearest != null) {
      final kategoriText = (nearest.kategori != null && nearest.kategori!.isNotEmpty) 
          ? nearest.kategori! 
          : 'Terdekat';
      title = 'Libur $kategoriText';
      
      try {
        final parsedMulai = DateTime.parse(nearest.tanggalMulai);
        String dateText = '${parsedMulai.day}/${parsedMulai.month}/${parsedMulai.year}';
        
        if (nearest.tanggalAkhir.isNotEmpty && nearest.tanggalAkhir != nearest.tanggalMulai) {
          final parsedAkhir = DateTime.parse(nearest.tanggalAkhir);
          dateText += ' - ${parsedAkhir.day}/${parsedAkhir.month}/${parsedAkhir.year}';
        }
        
        timeInfo = '$dateText\n${nearest.namaLibur}';
      } catch (_) {
        String dateText = nearest.tanggalMulai;
        if (nearest.tanggalAkhir.isNotEmpty && nearest.tanggalAkhir != nearest.tanggalMulai) {
          dateText += ' s.d. ${nearest.tanggalAkhir}';
        }
        timeInfo = '$dateText\n${nearest.namaLibur}';
      }
    }

    return InkWell(
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => const HariLiburScreen()));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade400.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: Colors.red.shade400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              timeInfo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: nearest != null ? Colors.red.shade400 : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalTerdekatCard(String title, dynamic jadwal, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String timeInfo = 'Tidak ada jadwal';
    
    if (jadwal != null) {
      int targetDay = int.tryParse(jadwal['hari']?.toString() ?? '0') ?? 0;
      String dayName = _getDayName(targetDay);
      String jamMasuk = jadwal['jam_masuk']?.toString() ?? '-';
      if (jamMasuk.length > 5) jamMasuk = jamMasuk.substring(0, 5);
      String jamPulang = jadwal['jam_pulang']?.toString() ?? '-';
      if (jamPulang.length > 5) jamPulang = jamPulang.substring(0, 5);
      timeInfo = '$dayName\n$jamMasuk - $jamPulang';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              timeInfo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: jadwal != null ? color : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(DashboardModel data) {
    final menus = [
      _MenuItemData(
        icon: Icons.trending_up_rounded,
        label: 'P. Tahsin',
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgressScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.auto_stories_rounded,
        label: 'PP. Tahfidz',
        color: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PraTahfidzScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.auto_stories_rounded,
        label: 'P. Tahfidz',
        color: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TahfidzScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.sports_basketball_outlined,
        label: 'Ekstra',
        color: Colors.deepOrange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ComingSoonScreen(title: 'Program Ekstrakurikuler'),
          ),
        ),
      ),
      _MenuItemData(
        icon: Icons.check_box_outlined,
        label: 'Absen',
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AbsenScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.calendar_month_outlined,
        label: 'Rekap',
        color: Colors.blue.shade400,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RekapAbsenScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.assignment_outlined,
        label: 'Tes',
        color: Colors.blue.shade600,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DaftarTesScreen(),
          ),
        ),
      ),
      _MenuItemData(
        icon: Icons.report_problem_outlined,
        label: 'Masalah',
        color: Colors.red.shade400,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MasalahScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.settings,
        label: 'Pengaturan',
        color: Colors.blueGrey,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PengaturanScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.person,
        label: 'Profil',
        color: Colors.purple.shade400,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.list_alt_outlined,
        label: 'Catatan',
        color: Colors.teal.shade400,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CatatanMasterScreen()),
        ),
      ),
      _MenuItemData(
        icon: Icons.logout_outlined,
        label: 'Logout',
        color: Colors.redAccent.shade400,
        onTap: _handleLogout,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: 4,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Menu Utama",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.only(bottom: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: menus.map((m) {
              return Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                elevation: 0,
                child: InkWell(
                  onTap: m.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade200
                            : Colors.white12,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          m.icon,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Theme.of(context).colorScheme.primary
                              : Colors.greenAccent,
                          size: 32,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            m.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _MenuItemData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
