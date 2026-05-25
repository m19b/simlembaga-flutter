import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/api/services/auth_api_service.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';

class DialogUtils {
  static Future<void> showLogoutDialog(BuildContext context) async {
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

    if (confirm == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
      try {
        await AuthApiService.logout();
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal logout: $e')),
          );
        }
      }
    }
  }

  static Future<bool?> showDoubleInputConfirmation({
    required BuildContext context,
    String? message,
    VoidCallback? onConfirm,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Konfirmasi Double Input', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Text(
            message ?? 'Terdapat input pada tanggal yang sama. Anda yakin menyimpan inputan ini?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('Tetap Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    if (confirm == true && onConfirm != null) {
      onConfirm();
    }
    return confirm;
  }
}
