import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
// import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Memberikan jeda singkat agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Tambahkan timeout untuk mencegah aplikasi hang/stuck selamanya
      // jika FlutterSecureStorage atau SharedPreferences nyangkut.
      final results = await Future.wait([
        const FlutterSecureStorage().read(key: 'jwt_token'),
        SharedPreferences.getInstance().then((p) => p.getString('LOGGED_IN_USER')),
      ]).timeout(const Duration(seconds: 3));

      final token = results[0];
      final userStr = results[1];

      if (!mounted) return;

      if (token != null && token.isNotEmpty && userStr != null && userStr.isNotEmpty) {
        // Data ada, langsung ke Dashboard
        final user = UserModel.fromJson(json.decode(userStr));
        
        // Inisialisasi ActiveKelompokCubit sebelum redirect ke Dashboard
        await context.read<ActiveKelompokCubit>().initialize(user.kelompokList);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        // Tidak ada sesi, ke halaman Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Jika terjadi error parsing, timeout, atau storage error, paksa kembali ke Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.menu_book_rounded, size: 80, color: Colors.green[800]),
            ),
            const SizedBox(height: 24),
            Text(
              'SIM Lembaga',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Memeriksa Sesi...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
