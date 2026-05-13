import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';

class UpdateDialogHelper {
  static void showForceUpdateDialog(BuildContext context, UpdateEntity update) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force update: tidak bisa dismiss dengan klik di luar
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Force update: block tombol back OS
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Pembaruan Wajib Tersedia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Versi Terbaru: ${update.latestVersion}'),
                const SizedBox(height: 12),
                const Text(
                  'Catatan Rilis:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(update.releaseNotes),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _launchDownloadUrl(update.downloadUrl),
                  child: const Text('Unduh & Update Sekarang'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _launchDownloadUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // Wajib externalApplication untuk trigger native OS browser yang akan handle APK download
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Tidak dapat membuka URL: $url');
    }
  }
}
