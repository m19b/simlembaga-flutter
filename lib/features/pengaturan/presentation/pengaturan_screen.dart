import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/theme/theme_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/screens/initial_sync_screen.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:manajemen_tahsin_app/features/pengaturan/presentation/pengaturan_indikator_screen.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  Future<void> _handleHapusDatabase(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Hapus Total Data', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
            'Tindakan ini akan menghapus SELURUH data offline dari memori perangkat. Anda akan diarahkan ke halaman Login ulang untuk memastikan sinkronisasi dari awal.\n\nApakah Anda yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        await IsarDb.instance.writeTxn(() async {
          await IsarDb.instance.clear();
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('LOGGED_IN_USER'); // Logout the user as well since data is gone
        
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'cached_password');
        await storage.delete(key: 'jwt_token');
        
        if (!context.mounted) return;
        Navigator.pop(context); // close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database berhasil dikosongkan.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Arahkan kembali ke Login karena data (termasuk kelomok list dll) sudah hilang
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleMuatUlang(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const InitialSyncScreen()),
      (route) => false, // Start from clean navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Stack(
          children: [
            const Positioned.fill(
              child: GlobalHeaderBackground(),
            ),
            AppBar(
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                'Pengaturan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SEGMEN TAMPILAN
          _buildSectionHeader(context, 'Tampilan', Icons.palette_outlined),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.amber : Colors.orange,
              ),
              title: const Text('Tema Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Ubah tampilan aplikasi menjadi gelap'),
              trailing: Switch(
                value: isDark,
                activeColor: Colors.blue,
                onChanged: (val) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),
          ),
          
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ListTile(
              leading: const Icon(Icons.wifi_tethering, color: Colors.blue),
              title: const Text('Kustomisasi Indikator Jaringan', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Ubah warna, transparansi, ketebalan, & teks indikator online'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanIndikatorScreen()));
              },
            ),
          ),

          // SEGMEN DATABASE
          _buildSectionHeader(context, 'Database & Sinkronisasi', Icons.storage_rounded),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync, color: Colors.blue),
                  title: const Text('Muat Ulang Database', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ambil ulang data terbaru dari server'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _handleMuatUlang(context),
                ),
                Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Hapus Total Data Offline', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                  subtitle: const Text('Kosongkan memori perangkat dari data aplikasi'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () => _handleHapusDatabase(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Versi Aplikasi 1.0.0\nSIM Biza App',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
