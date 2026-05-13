import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/constants/api_config.dart';
import 'package:manajemen_tahsin_app/core/api/dio_client.dart';

class SettingsDialog {
  static void show(BuildContext context) {
    final ipController = TextEditingController();

    // Simpan IP asli untuk mendeteksi apakah ada perubahan
    String originalIp = '';
    ApiConfig.getRawIp().then((currentIp) {
      ipController.text = currentIp;
      originalIp = currentIp;
    });

    showDialog(
      context: context,
      barrierDismissible:
          false, // Jangan tutup saat nge-tap di luar jika sedang loading
      builder: (ctx) {
        bool isChecking = false;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (contextDialog, setStateDialog) {
            // Evaluasi apakah text IP sama dengan original IP (agar tombol simpan non-aktif jika tdak ada prubahan)
            // ignore: unused_local_variable
            final bool hasChanged = ipController.text.trim() != originalIp;

            return AlertDialog(
              title: const Text('Pengaturan Server'),
              content: TextField(
                controller: ipController,
                keyboardType: TextInputType
                    .url, // Supaya bisa ngetik .local, port :8080, dan path
                enabled: !isChecking && !isSaving,
                onChanged: (value) {
                  // Memicu rebuild dialog saat ada yang diketik untuk update tombol disable/enable
                  setStateDialog(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'Alamat IP Server',
                  hintText: 'Contoh: 10.53.70.140',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: (isChecking || isSaving)
                      ? null
                      : () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Batal'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      (isChecking ||
                          isSaving ||
                          ipController.text.trim().isEmpty)
                      ? null
                      : () async {
                          final ip = ipController.text.trim();
                          setStateDialog(() => isChecking = true);

                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '⏳ Mengecek koneksi ke server...',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }

                          try {
                            final resolvedHost = await ApiConfig.setIp(ip);
                            DioClient.reset();
                            await ApiService.checkConnection();
                            if (!ctx.mounted) return;

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Berhasil terhubung & disimpan: $resolvedHost',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Close dialog on success
                            Navigator.pop(ctx);
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            final msg = e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ $msg'),
                                backgroundColor: Colors.red[700],
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } finally {
                            if (ctx.mounted) {
                              setStateDialog(() => isChecking = false);
                            }
                          }
                        },
                  icon: isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.wifi, size: 18),
                  label: const Text('Cek'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
