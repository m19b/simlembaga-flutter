import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    String content = await file.readAsString();
    if (content.contains(r'$newDest')) {
      final lines = content.split('\n');
      final newLines = lines.where((l) => !l.contains(r'$newDest')).toList();
      await file.writeAsString(newLines.join('\n'));
      print('Fixed \${file.path}');
    }
  }

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
