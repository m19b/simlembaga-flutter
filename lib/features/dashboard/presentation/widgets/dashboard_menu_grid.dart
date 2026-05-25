import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/progress_screen.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/pra_tahfidz_screen.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/rekap_absen_screen.dart';
import 'package:manajemen_tahsin_app/features/tes/presentation/daftar_tes_screen.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_screen.dart';
import 'package:manajemen_tahsin_app/features/pengaturan/presentation/pengaturan_screen.dart';
import 'package:manajemen_tahsin_app/features/profile/presentation/profile_screen.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/screens/catatan_master_screen.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/tahfidz_coming_soon_screen.dart';

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

class DashboardMenuGrid extends StatelessWidget {
  final DashboardModel data;
  final VoidCallback onLogout;

  const DashboardMenuGrid({
    super.key,
    required this.data,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItemData(
        icon: Icons.trending_up_rounded,
        label: 'P. Tahsin',
        color: Colors.blue,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
      ),
      _MenuItemData(
        icon: Icons.auto_stories_rounded,
        label: 'PP. Tahfidz',
        color: Colors.indigo,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PraTahfidzScreen())),
      ),
      _MenuItemData(
        icon: Icons.auto_stories_rounded,
        label: 'P. Tahfidz',
        color: Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TahfidzScreen())),
      ),
      _MenuItemData(
        icon: Icons.sports_basketball_outlined,
        label: 'Ekstra',
        color: Colors.deepOrange,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Program Ekstrakurikuler'))),
      ),
      _MenuItemData(
        icon: Icons.check_box_outlined,
        label: 'Absen',
        color: Colors.green,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AbsenScreen())),
      ),
      _MenuItemData(
        icon: Icons.calendar_month_outlined,
        label: 'Rekap',
        color: Colors.blue.shade400,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RekapAbsenScreen())),
      ),
      _MenuItemData(
        icon: Icons.assignment_outlined,
        label: 'Tes',
        color: Colors.blue.shade600,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarTesScreen())),
      ),
      _MenuItemData(
        icon: Icons.report_problem_outlined,
        label: 'Masalah',
        color: Colors.red.shade400,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MasalahScreen())),
      ),
      _MenuItemData(
        icon: Icons.settings,
        label: 'Pengaturan',
        color: Colors.blueGrey,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanScreen())),
      ),
      _MenuItemData(
        icon: Icons.person,
        label: 'Profil',
        color: Colors.purple.shade400,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      ),
      _MenuItemData(
        icon: Icons.list_alt_outlined,
        label: 'Catatan',
        color: Colors.teal.shade400,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatanMasterScreen())),
      ),
      _MenuItemData(
        icon: Icons.logout_outlined,
        label: 'Logout',
        color: Colors.redAccent.shade400,
        onTap: onLogout,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: Color(0xFF6B7280), size: 20),
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
