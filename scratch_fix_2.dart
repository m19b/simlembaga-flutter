import 'dart:io';

void main() {
  final file = File('lib/features/beranda/presentation/dashboard_screen.dart');
  String content = file.readAsStringSync();

  // Add kCardColor70 to extension
  if (!content.contains('kCardColor70')) {
    content = content.replaceAll(
      'Color get kCardColor => Theme.of(this).cardColor;',
      'Color get kCardColor => Theme.of(this).cardColor;\n  Color get kCardColor70 => Theme.of(this).cardColor.withOpacity(0.7);'
    );
  }

  // Lines 117-120
  content = content.replaceAll(
    "const Text(\n              'Keluar',\n              style: TextStyle(color: context.kCardColor),\n            )",
    "Text(\n              'Keluar',\n              style: TextStyle(color: context.kCardColor),\n            )"
  );

  // Lines 149-151
  content = content.replaceAll(
    "const Center(\n              child: CircularProgressIndicator(color: context.kHeaderColor),\n            )",
    "Center(\n              child: CircularProgressIndicator(color: context.kHeaderColor),\n            )"
  );

  // Icon(CardColor, -> Icon(Icons.dashboard_rounded, color: context.kCardColor,
  content = content.replaceAll('Icon(CardColor,', 'Icon(Icons.dashboard_rounded, color: context.kCardColor,');
  // Icon(HeaderColor, -> Icon(Icons.circle, color: context.kHeaderColor,
  content = content.replaceAll('Icon(HeaderColor,', 'Icon(Icons.circle, color: context.kHeaderColor,');

  file.writeAsStringSync(content);
  print('Fix applied');
}
