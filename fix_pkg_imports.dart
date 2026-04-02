import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final Map<String, String> externalImports = {
    'GoogleFonts': 'package:google_fonts/google_fonts.dart',
    'FlutterTts': 'package:flutter_tts/flutter_tts.dart',
    'MobileScanner': 'package:mobile_scanner/mobile_scanner.dart',
    'Permission': 'package:permission_handler/permission_handler.dart',
    'DateFormat': 'package:intl/intl.dart',
    'CameraFacing': 'package:mobile_scanner/mobile_scanner.dart',
    'MobileScannerController': 'package:mobile_scanner/mobile_scanner.dart',
    'Barcode': 'package:mobile_scanner/mobile_scanner.dart',
    'DateTime.parse': 'package:intl/intl.dart',
  };

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    String content = await file.readAsString();
    final lines = content.split('\n');
    
    int lastImportIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('import ')) {
        lastImportIndex = i;
      }
    }

    bool changed = false;
    List<String> importsToAdd = [];

    externalImports.forEach((className, importPath) {
      if (content.contains(className)) {
        final importStmt = "import '" + importPath + "';";
        if (!content.contains(importStmt)) {
          if (!importsToAdd.contains(importStmt)) {
            importsToAdd.add(importStmt);
            changed = true;
          }
        }
      }
    });

    if (changed) {
      lines.insertAll(lastImportIndex + 1, importsToAdd);
      await file.writeAsString(lines.join('\n'));
      print('Auto-imported \${importsToAdd.length} external packages in \${file.path}');
    }
  }
}
