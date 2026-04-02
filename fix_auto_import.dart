import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final Map<String, String> requiredImports = {
    'ApiService': 'package:manajemen_tahsin_app/core/api/api_service.dart',
    'ApiConfig': 'package:manajemen_tahsin_app/core/constants/api_config.dart',
    'UserModel': 'package:manajemen_tahsin_app/features/auth/data/user_model.dart',
    'DashboardScreen': 'package:manajemen_tahsin_app/features/beranda/presentation/dashboard_screen.dart',
    'HomeScreen': 'package:manajemen_tahsin_app/features/beranda/presentation/home_screen.dart',
    'UrgentListSheet': 'package:manajemen_tahsin_app/features/beranda/presentation/urgent_list_sheet.dart',
    'LoginScreen': 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart',
    'RekapAbsenScreen': 'package:manajemen_tahsin_app/features/absensi/presentation/rekap_absen_screen.dart',
    'AbsenScreen': 'package:manajemen_tahsin_app/features/absensi/presentation/absen_screen.dart',
    'TopHeader': 'package:manajemen_tahsin_app/features/absensi/presentation/top.dart', 
    'BottomNav': 'package:manajemen_tahsin_app/features/absensi/presentation/bottom.dart', 
    'CatatMasalahBottomSheet': 'package:manajemen_tahsin_app/features/masalah/presentation/catat_masalah_bottom_sheet.dart',
    'MasalahApprovalScreen': 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_approval_screen.dart',
    'MasalahScreen': 'package:manajemen_tahsin_app/features/masalah/presentation/masalah_screen.dart',
    'ProgressDetailScreen': 'package:manajemen_tahsin_app/features/progress/presentation/progress_detail_screen.dart',
    'ProgressInputScreen': 'package:manajemen_tahsin_app/features/progress/presentation/progress_input_screen.dart',
    'ProgressScreen': 'package:manajemen_tahsin_app/features/progress/presentation/progress_screen.dart',
    'DataSantriScreen': 'package:manajemen_tahsin_app/features/santri/presentation/data_santri_screen.dart',
  };

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    String content = await file.readAsString();
    
    // Hilangkan semua baris yang mengandung $importPath yang error kemarin
    final lines = content.split('\n');
    final cleanedLines = lines.where((l) => !l.contains(r'$importPath')).toList();
    
    int lastImportIndex = 0;
    for (int i = 0; i < cleanedLines.length; i++) {
      if (cleanedLines[i].startsWith('import ')) {
        lastImportIndex = i;
      }
    }

    bool changed = false;
    List<String> importsToAdd = [];

    final contentStr = cleanedLines.join('\n');
    requiredImports.forEach((className, importPath) {
      if (contentStr.contains(className)) {
        final currentFileUri = file.path.replaceAll(r'\', '/');
        // Pastikan tidak melooping import dirinya sendiri
        if (!importPath.contains(currentFileUri.replaceAll('lib/', ''))) {
          // GUNAKAN PENGGABUNGAN STRING BIASA AGAR AMAN
          final importStmt = "import '" + importPath + "';";
          if (!contentStr.contains(importStmt)) {
            importsToAdd.add(importStmt);
            changed = true;
          }
        }
      }
    });

    if (changed) {
      cleanedLines.insertAll(lastImportIndex + 1, importsToAdd);
      await file.writeAsString(cleanedLines.join('\n'));
      print('Fixed and Auto-imported ' + importsToAdd.length.toString() + ' packages in ' + file.path);
    } else if (lines.length != cleanedLines.length) {
      await file.writeAsString(cleanedLines.join('\n'));
      print('Cleaned corrupted lines in ' + file.path);
    }
  }
}
