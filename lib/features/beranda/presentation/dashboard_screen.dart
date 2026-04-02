import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:manajemen_tahsin_app/features/beranda/presentation/urgent_list_sheet.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/rekap_absen_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_screen.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_approval_screen.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/progress_screen.dart';
import 'package:manajemen_tahsin_app/features/santri/presentation/data_santri_screen.dart';

// --- Global Constants & Helpers ---
const Color kBgColor = Color(0xFFF3F4F6); // 60% Light background
const Color kHeaderColor = Color(0xFF0F4C2A); // 30% Dark Green header
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

Color hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.tryParse('FF$h', radix: 16) ?? 0xFF000000);
}

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ApiService.getDashboardGuru();
  }

  void _refresh() {
    setState(() {
      _dashboardFuture = ApiService.getDashboardGuru();
    });
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
      await ApiService.logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String roleUser = widget.user.group ?? 'Guru';
    if (roleUser.isNotEmpty) {
      roleUser = roleUser[0].toUpperCase() + roleUser.substring(1);
    }

    return Scaffold(
      backgroundColor: kBgColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kHeaderColor),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final rawData = snapshot.data?['data'];
          if (rawData == null) {
            return const Center(child: Text("Data tidak tersedia"));
          }

          final guruName =
              rawData['guru_name'] as String? ?? widget.user.username;
          final namaKelompok = rawData['nama_kelompok'] as String? ?? '-';
          final namaKelas = rawData['nama_kelas'] as String? ?? '-';

          final summary = rawData['summary'] as Map<String, dynamic>? ?? {};
          final chartData = (rawData['chart_kecepatan'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .toList();

          final urgentList = (rawData['urgent_list'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .toList();

          return RefreshIndicator(
            color: kHeaderColor,
            onRefresh: () async => _refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(guruName, roleUser, namaKelompok, namaKelas),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Stat Cards slightly overlapping the header
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: _buildStatCards(summary, urgentList),
                      ),
                      _buildChartSection(
                        chartData,
                        summary['total_santri']?.toString() ?? '0',
                      ),
                      _buildMenuSection(
                        _handleLogout,
                        widget.user.group?.toLowerCase() == 'admin' ||
                            widget.user.group?.toLowerCase() == 'superadmin',
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    String name,
    String role,
    String kelompok,
    String kelas,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      toolbarHeight: 56,
      pinned: true,
      elevation: 0,
      backgroundColor: kHeaderColor,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AbsenScreen()),
          ),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double collapsedHeight =
              56.0 + MediaQuery.of(context).padding.top;
          final bool isCollapsed =
              constraints.biggest.height <= collapsedHeight + 20;

          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(
              left: 16,
              bottom: 20,
              right: 90,
            ),
            title: isCollapsed
                ? AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Text(
                      '$name · $role',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: kHeaderColor),
                // Decorative Circle 1
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 30,
                      ),
                    ),
                  ),
                ),
                // Decorative Circle 2
                Positioned(
                  left: -30,
                  bottom: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 60,
                  right: 20,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selamat datang,',
                          style: GoogleFonts.dmSans(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                            children: [
                              TextSpan(
                                text: '$name ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '· $role',
                                style: TextStyle(
                                  color: const Color(0xFF22C55E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Bungkus dengan Flexible agar tidak jebol ke kanan
                            Flexible(
                              child: _buildContextChip(
                                Icons.person_outline,
                                kelompok,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: _buildContextChip(
                                Icons.school_outlined,
                                kelas,
                              ),
                            ),
                          ],
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
          // 🔴 TAMBAHKAN FLEXIBLE & OVERFLOW DI SINI
          Flexible(
            child: Text(
              label,
              maxLines: 1, // Batasi 1 baris
              overflow:
                  TextOverflow.ellipsis, // Muncul titik-titik jika kepanjangan
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(
    Map<String, dynamic> summary,
    List<Map<String, dynamic>> urgentList,
  ) {
    return Padding(
      // Memberikan jarak atas yang lebih lega agar tidak menempel dengan header
      padding: const EdgeInsets.only(top: 60, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 140, // Lebar fixed agar card seragam saat di-scroll
              child: _StatCard(
                label: 'Total\nSantri',
                value: summary['total_santri']?.toString() ?? '0',
                icon: Icons.people_outline,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),

            // 🔴 INI KARTU BARUNYA: Menampilkan "Hadir / Total" (contoh: 3/9)
            SizedBox(
              width: 140,
              child: _StatCard(
                label: 'Sudah\nAbsen',
                value:
                    '${summary['hadir'] ?? '0'}/${summary['total_santri'] ?? '0'}',
                icon: Icons.how_to_reg_rounded,
                color: Colors.teal.shade600,
              ),
            ),
            const SizedBox(width: 12),

            SizedBox(
              width: 140,
              child: _StatCard(
                label: 'Perlu\nPerhatian',
                value: summary['perlu_perhatian']?.toString() ?? '0',
                icon: Icons.warning_rounded,
                color: Colors.red.shade600,
                onTap: () => showUrgentListSheet(context, urgentList),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: _StatCard(
                label: 'Siap\nTest',
                value: summary['siap_test']?.toString() ?? '0',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: _StatCard(
                label: 'Belum\nSelesai',
                value: summary['belum_diinput']?.toString() ?? '0',
                icon: Icons.calendar_today_rounded,
                color: Colors.orange.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final msg = error.replaceFirst('Exception: ', '');
    final isSessionExpired =
        msg.toLowerCase().contains('sesi') ||
        msg.toLowerCase().contains('habis') ||
        msg.toLowerCase().contains('login');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSessionExpired ? Icons.lock_outline_rounded : Icons.wifi_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: kTextSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: kHeaderColor),
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isSessionExpired) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kHeaderColor),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (r) => false,
                  );
                },
                icon: const Icon(Icons.login_rounded, color: kHeaderColor),
                label: Text(
                  'Ke Halaman Login',
                  style: GoogleFonts.plusJakartaSans(
                    color: kHeaderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(
    List<Map<String, dynamic>> chartData,
    String totalSantri,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _SpeedChart(chartData: chartData, totalLabel: totalSantri),
        ),
      ],
    );
  }

  Widget _buildMenuSection(VoidCallback logout, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: kTextSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Menu Utama",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ),
        _MenuCategoryGrid(onLogout: logout, isAdmin: isAdmin),
      ],
    );
  }
}

// --- Specific Modular Components ---

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias, // Critical for the left border painting correctly
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Thick Left Border
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class _SpeedChart extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final String totalLabel;
  const _SpeedChart({required this.chartData, required this.totalLabel});

  @override
  State<_SpeedChart> createState() => _SpeedChartState();
}

class _SpeedChartState extends State<_SpeedChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.chartData.fold<num>(
      0,
      (sum, e) => sum + (num.tryParse(e['value']?.toString() ?? '0') ?? 0),
    );

    if (total == 0) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            "Belum ada data visualisasi",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  sections: widget.chartData.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isTouched = i == _touchedIndex;
                    final valNum =
                        num.tryParse(item['value']?.toString() ?? '0') ?? 0;
                    return PieChartSectionData(
                      value: valNum.toDouble(),
                      color: hexToColor(item['color']?.toString() ?? ''),
                      radius: isTouched ? 30.0 : 20.0,
                      showTitle:
                          false, // Total covers meaning, title can be hidden to keep it clean
                    );
                  }).toList(),
                ),
              ),
              // Inner Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.totalLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  Text(
                    'Santri',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Custom Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.chartData.map((item) {
              final valNum =
                  num.tryParse(item['value']?.toString() ?? '0') ?? 0;
              final pct = total > 0
                  ? (valNum / total * 100).toStringAsFixed(0)
                  : '0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: hexToColor(item['color']?.toString() ?? ''),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: GoogleFonts.dmMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// --- Menu Modeling & Representation ---

class _MenuItem {
  final IconData icon;
  final String label;
  final Color baseColor; // e.g. blue for group, green for group
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.baseColor,
    required this.onTap,
  });
}

class _MenuCategoryGrid extends StatelessWidget {
  final VoidCallback onLogout;
  final bool isAdmin;
  const _MenuCategoryGrid({required this.onLogout, required this.isAdmin});

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildGroupGrid(List<_MenuItem> items, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: const EdgeInsets.only(bottom: 12),
        children: items.map((m) {
          return InkWell(
            onTap: m.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.baseColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(m.icon, color: m.baseColor, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    m.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: kTextPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Family Blue
    final progresItems = [
      _MenuItem(
        icon: Icons.show_chart_rounded,
        label: 'Progres\nBelajar',
        baseColor: Colors.blue.shade600,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgressScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.layers_outlined,
        label: 'Prediksi\nKhataman',
        baseColor: Colors.blue.shade600,
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.workspace_premium_outlined,
        label: 'Laporan\nPrestasi',
        baseColor: Colors.amber.shade500,
        onTap: () {},
      ), // Amber is better for achievements
    ];

    // Family Green
    final absensiItems = [
      _MenuItem(
        icon: Icons.check_box_outlined,
        label: 'Absen\nSantri',
        baseColor: const Color(0xFF16A34A),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AbsenScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.calendar_month_outlined,
        label: 'Rekap\nAbsensi',
        baseColor: Colors.blue.shade500,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RekapAbsenScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.people_outline_rounded,
        label: 'Data\nSantri',
        baseColor: Colors.blueGrey.shade600,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DataSantriScreen()),
        ),
      ),
    ];

    // Family Amber/Yellowish
    final testItems = [
      _MenuItem(
        icon: Icons.sticky_note_2_outlined,
        label: 'Data\nCatatan',
        baseColor: Colors.orange.shade400,
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.assignment_outlined,
        label: 'Daftar\nTest',
        baseColor: Colors.blue.shade500,
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.edit_note_rounded,
        label: 'Riwayat\nTes',
        baseColor: Colors.purple.shade400,
        onTap: () {},
      ),
    ];

    // Family Red + Slate
    final lainnyaItems = [
      _MenuItem(
        icon: Icons.report_problem_outlined,
        label: 'Masalah\nSantri',
        baseColor: Colors.red.shade500,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MasalahScreen(isAdmin: isAdmin)),
        ),
      ),
      if (isAdmin)
        _MenuItem(
          icon: Icons.pending_actions_rounded,
          label: 'Approval\nMasalah',
          baseColor: Colors.orange.shade600,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MasalahApprovalScreen()),
          ),
        ),
      _MenuItem(
        icon: Icons.manage_accounts_outlined,
        label: 'Ubah\nProfil',
        baseColor: const Color(0xFF16A34A),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.logout_outlined,
        label: 'Logout',
        baseColor: Colors.grey.shade500,
        onTap: onLogout,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupTitle('PROGRES & BELAJAR'),
        _buildGroupGrid(progresItems, context),

        _buildGroupTitle('ABSENSI'),
        _buildGroupGrid(absensiItems, context),

        _buildGroupTitle('TES & CATATAN'),
        _buildGroupGrid(testItems, context),

        _buildGroupTitle('LAINNYA'),
        _buildGroupGrid(lainnyaItems, context),
      ],
    );
  }
}
