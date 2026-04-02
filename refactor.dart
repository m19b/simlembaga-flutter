import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found');
    return;
  }

  // 1. Mapping file lama (relatif terhadap lib/) ke letak baru (relatif thd lib/)
  final Map<String, String> mapping = {
    'models/user_model.dart': 'features/auth/data/user_model.dart',
    'screens/absen/absen_screen.dart': 'features/absensi/presentation/absen_screen.dart',
    'screens/absen/bottom.dart': 'features/absensi/presentation/bottom.dart',
    'screens/absen/rekap_absen_screen.dart': 'features/absensi/presentation/rekap_absen_screen.dart',
    'screens/absen/top.dart': 'features/absensi/presentation/top.dart',
    'screens/auth/login_screen.dart': 'features/auth/presentation/login_screen.dart',
    'screens/home/dashboard_screen.dart': 'features/beranda/presentation/dashboard_screen.dart',
    'screens/home/home_screen.dart': 'features/beranda/presentation/home_screen.dart',
    'screens/home/urgent_list_sheet.dart': 'features/beranda/presentation/urgent_list_sheet.dart',
    'screens/masalah/catat_masalah_bottom_sheet.dart': 'features/masalah/presentation/catat_masalah_bottom_sheet.dart',
    'screens/masalah/masalah_approval_screen.dart': 'features/masalah/presentation/masalah_approval_screen.dart',
    'screens/masalah/masalah_screen.dart': 'features/masalah/presentation/masalah_screen.dart',
    'screens/progress/progress_detail_screen.dart': 'features/progress/presentation/progress_detail_screen.dart',
    'screens/progress/progress_input_screen.dart': 'features/progress/presentation/progress_input_screen.dart',
    'screens/progress/progress_screen.dart': 'features/progress/presentation/progress_screen.dart',
    'screens/santri/data_santri_screen.dart': 'features/santri/presentation/data_santri_screen.dart',
    'services/api_service.dart': 'core/api/api_service.dart',
    'utils/api_config.dart': 'core/constants/api_config.dart',
  };

  // 2. Baca semua file
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  for (var file in files) {
    // replace \ with / untuk mempermudah pengecekan path
    final relativePath = file.path.substring(4).replaceAll('\\', '/'); 

    String content = await file.readAsString();

    // 3. Regex untuk mencari relative import (import '../...', import './...')
    final importRegex = RegExp(r'''import\s+['"](\.{1,2}/[^'"]+)['"]''');
    
    content = content.replaceAllMapped(importRegex, (match) {
      final importStr = match.group(1)!;
      // Gunakan Uri untuk resolve relative path terhadap current file
      // Contoh: relativePath = 'screens/auth/login_screen.dart'
      // uri-nya adalah 'screens/auth/login_screen.dart' (huruf kecil)
      // kalau resolve '../../models/user_model.dart', uri-nya jadi 'models/user_model.dart'
      final resolvedUri = Uri.parse(relativePath).resolve(importStr).path;
      
      // periksa apakah file yang diimport ada di mapping
      final newDest = mapping[resolvedUri];
      if (newDest != null) {
        return "import 'package:manajemen_tahsin_app/\$newDest'";
      } else {
        return "import 'package:manajemen_tahsin_app/\$resolvedUri'";
      }
    });

    // 4. Update main.dart khusus jika ada import yang berubah
    // Save the modified content in temporary memory first
    if (mapping.containsKey(relativePath)) {
      final newPathStr = 'lib/' + mapping[relativePath]!;
      final destFile = File(newPathStr);
      await destFile.parent.create(recursive: true);
      await destFile.writeAsString(content);
      await file.delete();
      print('Moved & Updated: \$relativePath -> \${mapping[relativePath]}');
    } else {
      // It's main.dart or something else that stays in the same place
      await file.writeAsString(content);
      print('Updated Imports: \$relativePath');
    }
  }

  // 5. Clean up empty directories
  final dirsToClean = [
    Directory('lib/models'),
    Directory('lib/screens'),
    Directory('lib/services'),
    Directory('lib/utils')
  ];
  for (var dir in dirsToClean) {
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
        print('Deleted \${dir.path}');
      } catch (_) {}
    }
  }
}
