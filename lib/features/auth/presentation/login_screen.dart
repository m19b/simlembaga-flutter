import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/constants/api_config.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:manajemen_tahsin_app/features/beranda/presentation/dashboard_screen.dart';

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
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Settings Dialog ────────────────────────────────────────────────────────
  void _showSettingsDialog() {
    final ipController = TextEditingController();
    ApiConfig.getRawIp().then((currentIp) {
      ipController.text = currentIp;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan Server'),
        content: TextField(
          controller: ipController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Alamat IP Server',
            hintText: 'Contoh: 10.53.70.140',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.dns),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ip = ipController.text.trim();
              if (ip.isEmpty) return;
              await ApiConfig.setIp(ip);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ IP Server berhasil disimpan'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
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
      final UserModel user = await ApiService.login(identity, password);

      if (!mounted) return;

      // Navigasi ke DashboardScreen, hapus semua route sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
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
            onPressed: _showSettingsDialog,
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mosque, size: 80, color: Colors.green[800]),
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
                'ZhaaL v1.2',
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
