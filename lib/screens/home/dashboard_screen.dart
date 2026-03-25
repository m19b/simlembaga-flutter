import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../absen/absen_screen.dart';
import '../absen/rekap_absen_screen.dart';

// ─── Hex Color Helper ─────────────────────────────────────────────────────────
Color hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        color: const Color(0xFF1B5E20),
        onRefresh: () async => _refresh(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
              );
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          snapshot.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!['data'] as Map<String, dynamic>;
            final guruName =
                data['guru_name'] as String? ?? widget.user.username;
            final summary = data['summary'] as Map<String, dynamic>;
            final chartData = (data['chart_kecepatan'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final urgentList = (data['urgent_list'] as List<dynamic>)
                .cast<Map<String, dynamic>>();

            return CustomScrollView(
              slivers: [
                // ─── Header AppBar ────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: const Color(0xFF1B5E20),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                      tooltip: 'Notifikasi',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$guruName (${widget.user.group})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kelas Dewasa, Kelompok 1',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Summary Cards ─────────────────────────────────
                      Transform.translate(
                        offset: const Offset(0, -36),
                        child: SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _SummaryCard(
                                label: 'Total Santri',
                                value: summary['total_santri'] ?? 0,
                                icon: Icons.people_alt_outlined,
                                color: const Color(0xFF1565C0),
                              ),
                              _SummaryCard(
                                label: 'Perlu Perhatian',
                                value: summary['perlu_perhatian'] ?? 0,
                                icon: Icons.warning_amber_rounded,
                                color: const Color(0xFFC62828),
                              ),
                              _SummaryCard(
                                label: 'Siap Test',
                                value: summary['siap_test'] ?? 0,
                                icon: Icons.check_circle_outline,
                                color: const Color(0xFF2E7D32),
                              ),
                              _SummaryCard(
                                label: 'Belum Diinput',
                                value: summary['belum_diinput'] ?? 0,
                                icon: Icons.pending_outlined,
                                color: const Color(0xFFE65100),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ─── Urgent Section ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _SectionTitle(
                          icon: Icons.priority_high_rounded,
                          title: 'Perlu Perhatian',
                          iconColor: Colors.red[700]!,
                        ),
                      ),
                      if (urgentList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            elevation: 0,
                            color: Colors.green[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const ListTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              title: Text(
                                'Alhamdulillah, tidak ada santri bermasalah hari ini.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: urgentList.map((item) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 1,
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFFFEBEE),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                    ),
                                  ),
                                  title: Text(
                                    item['nama_santri'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'NIS: ${item['nis']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['keterangan_masalah'] as String,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ─── Chart Kecepatan ───────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SectionTitle(
                          icon: Icons.pie_chart_outline,
                          title: 'Kecepatan Belajar Kelas',
                          iconColor: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _SpeedChart(chartData: chartData),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── 12 Menu Grid ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SectionTitle(
                          icon: Icons.apps_rounded,
                          title: 'Menu Utama',
                          iconColor: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _MenuGrid(onLogout: _handleLogout),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Summary Card Widget ──────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}

// ─── Donut Chart ──────────────────────────────────────────────────────────────
class _SpeedChart extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  const _SpeedChart({required this.chartData});

  @override
  State<_SpeedChart> createState() => _SpeedChartState();
}

class _SpeedChartState extends State<_SpeedChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.chartData.fold<num>(
      0,
      (sum, e) => sum + (e['value'] as num),
    );

    return Row(
      children: [
        // Donut Chart
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
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
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: widget.chartData.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isTouched = i == _touchedIndex;
                final radius = isTouched ? 58.0 : 50.0;
                return PieChartSectionData(
                  value: (item['value'] as num).toDouble(),
                  color: hexToColor(item['color'] as String),
                  radius: radius,
                  title: '${item['value']}',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.chartData.map((item) {
              final pct = total > 0
                  ? ((item['value'] as num) / total * 100).toStringAsFixed(0)
                  : '0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: hexToColor(item['color'] as String),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

// ─── 12 Menu Grid ─────────────────────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  final VoidCallback onLogout;
  const _MenuGrid({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItem(
        icon: Icons.trending_up_outlined,
        label: 'Progres\nBelajar',
        color: const Color(0xFF0288D1),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.auto_graph_outlined,
        label: 'Prediksi\nKhataman',
        color: const Color(0xFF00838F),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.emoji_events_outlined,
        label: 'Laporan\nPrestasi',
        color: const Color(0xFF558B2F),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.fact_check_outlined,
        label: 'Absen\nSantri',
        color: const Color(0xFF1B5E20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AbsenScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.calendar_month_outlined,
        label: 'Rekap\nAbsensi',
        color: const Color(0xFF4527A0),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RekapAbsenScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: 'Data\nSantri',
        color: const Color(0xFF0277BD),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.sticky_note_2_outlined,
        label: 'Data\nCatatan',
        color: const Color(0xFFAD1457),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.assignment_outlined,
        label: 'Daftar\nTest',
        color: const Color(0xFFE65100),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.history_edu_outlined,
        label: 'Riwayat\nTes',
        color: const Color(0xFF6A1B9A),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.report_problem_outlined,
        label: 'Masalah\nSantri',
        color: const Color(0xFFC62828),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.manage_accounts_outlined,
        label: 'Ubah\nProfil',
        color: const Color(0xFF00695C),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        label: 'Logout',
        color: Colors.grey[700]!,
        onTap: onLogout,
      ),
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: menus.map((m) => _MenuTile(item: m)).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 28, color: item.color),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: item.color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
