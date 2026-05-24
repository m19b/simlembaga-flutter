import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/core/api/services/auth_api_service.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/screens/initial_sync_screen.dart';
import 'package:manajemen_tahsin_app/core/widgets/settings_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final results = await Future.wait([
        const FlutterSecureStorage().read(key: 'jwt_token'),
        SharedPreferences.getInstance().then(
          (p) => p.getString('LOGGED_IN_USER'),
        ),
      ]).timeout(const Duration(seconds: 3));

      final token = results[0];
      final userStr = results[1];

      if (!mounted) return;

      if (token != null &&
          token.isNotEmpty &&
          userStr != null &&
          userStr.isNotEmpty) {
        final user = UserModel.fromJson(json.decode(userStr));

        // Inisialisasi ActiveKelompokCubit
        await context.read<ActiveKelompokCubit>().initialize(user.kelompokList);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InitialSyncScreen()),
        );
      }
    } catch (e) {
      // Jika terjadi timeout atau error, biarkan user di halaman login
      debugPrint("Sesi check error/timeout: $e");
    }
  }

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Login Logic (SUDAH DIPERBAIKI) ─────────────────────────────────────────
  Future<void> _handleLogin() async {
    // 🌟 1. WAJIB: Tutup keyboard paksa saat tombol ditekan
    FocusManager.instance.primaryFocus?.unfocus();

    final identity = _identityController.text.trim();
    final password = _passwordController.text.trim();

    if (identity.isEmpty || password.isEmpty) {
      _showSnackBar('Harap isi semua kolom', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserModel user = await AuthApiService.login(identity, password);

      if (!mounted) return;

      // Inisialisasi ActiveKelompokCubit
      await context.read<ActiveKelompokCubit>().initialize(user.kelompokList);

      if (!mounted) return;

      // Navigasi ke InitialSyncScreen, hapus semua route sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const InitialSyncScreen()),
        (route) => false,
      );
    } catch (e, stacktrace) {
      // 🌟 2. JEBAKAN ERROR: Print ke console agar kita tahu persis masalahnya
      debugPrint('=== ERROR LOGIN TERDEKTEKSI ===');
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());

      if (!mounted) return;
      // Tampilkan pesan error dari API / jaringan di layar HP
      final message = e.toString().replaceFirst('Exception: ', '');
      _showSnackBar(message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => SettingsDialog.show(context),
            tooltip: 'Pengaturan Server',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icon
              Container(
                padding: const EdgeInsets.all(
                  12,
                ), // Mengurangi padding agar logo lebih terlihat
                decoration: BoxDecoration(
                  color: Colors
                      .white, // Mengganti background menjadi putih agar netral untuk logo
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 70,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SIM Lembaga',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bismillah',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 36),

              // Field Identity (Username/Email)
              TextField(
                controller: _identityController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username / Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Field Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
