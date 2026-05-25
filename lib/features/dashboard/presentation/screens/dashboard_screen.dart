import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/api/services/absensi_api_service.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/bloc/initial_sync_cubit.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/bloc/initial_sync_state.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/screens/initial_sync_screen.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/bloc/hari_libur_cubit.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_mandiri_screen.dart';

// UI Components
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_bottom_tabs.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_summary.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_menu_grid.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_info_cards.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_hijri_card.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_kecepatan_chart.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/offline_banner_sliver.dart';
import 'package:manajemen_tahsin_app/core/utils/dialog_utils.dart';
import 'package:manajemen_tahsin_app/core/widgets/section_title_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardCubit _dashboardCubit;
  UserModel? _currentUser;
  String? _baseUrl;

  Map<String, dynamic> _statusAbsen = {};
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  final List<String> _greetings = [
    'Assalamu\'alaikum,',
    'Ahlan wa Sahlan,',
    'Semangat Mengajar,',
    'Barakallahu fiik,',
    'Selamat Bertugas,',
    'Halo Ustadz/Ustadzah,',
  ];
  late String _randomGreeting;

  @override
  void initState() {
    super.initState();
    _randomGreeting =
        _greetings[DateTime.now().millisecond % _greetings.length];
    _dashboardCubit = context.read<DashboardCubit>();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    _loadUserAndBaseUrl();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkKelompokAndLoadData();
    });
  }

  Future<void> _loadUserAndBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('LOGGED_IN_USER');
    if (userStr != null) {
      if (mounted) {
        setState(() {
          _currentUser = UserModel.fromJson(json.decode(userStr));
        });
      }
    }
    final baseUrl = prefs.getString('server_base_url');
    if (baseUrl != null && mounted) {
      setState(() {
        _baseUrl = baseUrl;
      });
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkKelompokAndLoadData() async {
    _dashboardCubit.fetchDashboard();
    _loadLibur();
  }

  void _loadLibur() {
    final activeId = context.read<ActiveKelompokCubit>().state.activeId;
    if (activeId > 0) {
      context.read<HariLiburCubit>().fetch(
        tahun: DateTime.now().year,
        idKelompok: activeId,
      );
    }
  }

  Future<void> _fetchStatusAbsen(int idKelompok) async {
    try {
      final status = await AbsensiApiService.getStatusAbsenMandiri(idKelompok);
      if (mounted) {
        setState(() {
          _statusAbsen = status;
        });
      }
    } catch (e) {
      debugPrint('Error getStatusAbsenMandiri: $e');
    }
  }

  Future<void> _handleLogout() async {
    await DialogUtils.showLogoutDialog(context);
  }

  void _handleAbsenMandiriFromInfoCard(String tipe, int idKelompok) async {
    final data = _dashboardCubit.state is DashboardLoaded
        ? (_dashboardCubit.state as DashboardLoaded).data
        : null;

    if (data != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbsenMandiriScreen(
            namaGuru: data.guruName,
            nig: data.nig,
            idKelompok: data.idKelompok,
          ),
        ),
      );
      _fetchStatusAbsen(data.idKelompok);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveKelompokCubit, ActiveKelompokState>(
      listenWhen: (previous, current) =>
          previous.activeId != current.activeId && current.activeId != 0,
      listener: (context, state) {
        _dashboardCubit.fetchDashboard();
        _fetchStatusAbsen(state.activeId);
        _loadLibur();
      },
      child: BlocBuilder<InitialSyncCubit, InitialSyncState>(
        builder: (context, syncState) {
          if (syncState is InitialSyncInProgress) {
            return const InitialSyncScreen();
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: RefreshIndicator(
              color: const Color(0xFF0F4C2A),
              onRefresh: () async {
                await _loadUserAndBaseUrl();
                _dashboardCubit.fetchDashboard(forceRefresh: true);
                _loadLibur();
                final state = context.read<ActiveKelompokCubit>().state;
                if (state.activeId > 0) {
                  await _fetchStatusAbsen(state.activeId);
                }
              },
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: GlobalSkeletonWidget(
                        itemCount: 5,
                        itemHeight: 120,
                      ),
                    );
                  }

                  if (state is DashboardError) {
                    return GlobalErrorWidget(
                      message: state.message,
                      onRetry: () => _dashboardCubit.fetchDashboard(),
                    );
                  }

                  if (state is DashboardLoaded) {
                    final data = state.data;
                    String role = data.role.isNotEmpty
                        ? data.role
                        : 'Role tidak ditemukan';

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        DashboardHeader(
                          name: data.guruName,
                          role: role,
                          kelompok: data.namaKelompok,
                          kelas: data.namaKelas,
                          availableKategori: state.availableKategori,
                          availableKelas: state.availableKelas,
                          selectedKelas: state.selectedKelas,
                          randomGreeting: _randomGreeting,
                          currentUser: _currentUser,
                          baseUrl: _baseUrl,
                          onLogout: _handleLogout,
                        ),
                        const OfflineBannerSliver(),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                DashboardHijriCard(
                                  data: data,
                                  currentTime: _currentTime,
                                ),
                                DashboardSummary(data: data),
                                DashboardMenuGrid(
                                  data: data,
                                  onLogout: _handleLogout,
                                ),
                                const SizedBox(height: 8),
                                const SectionTitleWidget(
                                  title: "Informasi Hari Ini",
                                  icon: Icons.info_outline,
                                  iconColor: Color(0xFF6B7280),
                                ),
                                DashboardInfoCards(
                                  data: data,
                                  statusAbsen: _statusAbsen,
                                  onRefreshStatusAbsen: () async {
                                    await _fetchStatusAbsen(data.idKelompok);
                                  },
                                  onAbsenMandiri:
                                      _handleAbsenMandiriFromInfoCard,
                                ),
                                const SizedBox(height: 24),
                                DashboardBottomTabs(
                                  data: data,
                                  currentTime: _currentTime,
                                ),
                                const SizedBox(height: 16),
                                SectionTitleWidget(
                                  title: "Kecepatan Belajar Kelas",
                                  icon: Icons.pie_chart_outline,
                                  iconColor: Colors.green.shade600,
                                ),
                                DashboardKecepatanChart(
                                  chartKecepatan: data.chartKecepatan,
                                  totalSantri: data.summary.totalSantri,
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
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
        },
      ),
    );
  }
}
