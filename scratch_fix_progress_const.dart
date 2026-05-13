import 'dart:io';

void main() {
  final file = File('lib/features/progress/presentation/progress_screen.dart');
  String c = file.readAsStringSync();

  // Fix Undefined name '_kText1'
  c = c.replaceAll('onSurface: _kText1,', 'onSurface: Theme.of(context).colorScheme.onSurface,');
  c = c.replaceAll('const ColorScheme.light(', 'ColorScheme.light(');
  c = c.replaceAll('const ColorScheme.dark(', 'ColorScheme.dark(');

  // Fix const eval method invocation by removing `const ` before widgets that now have Theme.of(context)
  
  // Lines 348 - 356:
  // const Text(
  //   'Kirim Laporan Perbandingan',
  //   style: TextStyle(
  //     fontSize: 18,
  //     fontWeight: FontWeight.bold,
  //     color: Theme.of(context).colorScheme.onSurface,
  //   ),
  // ),
  c = c.replaceAll('const Text(\n                \'Kirim Laporan', 'Text(\n                \'Kirim Laporan');
  
  // Line 359 - 362:
  // const Text(
  //   'Laporan ini berisi perbandingan performa seluruh santri di kelas Anda dalam periode tertentu.',
  //   style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
  // ),
  c = c.replaceAll('const Text(\n            \'Laporan ini', 'Text(\n            \'Laporan ini');
  
  // Line 364 - 371:
  // const Text(
  //   'Periode Laporan:',
  //   style: TextStyle(
  //     fontWeight: FontWeight.bold,
  //     fontSize: 14,
  //     color: Theme.of(context).colorScheme.onSurface,
  //   ),
  // ),
  c = c.replaceAll('const Text(\n            \'Periode Laporan:', 'Text(\n            \'Periode Laporan:');
  
  // Line 892 - 895:
  // const Padding(
  //   padding: EdgeInsets.symmetric(vertical: 12),
  //   child: Divider(height: 1, color: Theme.of(context).dividerColor),
  // ),
  c = c.replaceAll('const Padding(\n                        padding: EdgeInsets.symmetric(vertical: 12),\n                        child: Divider(height: 1, color: Theme.of(context).dividerColor),\n                      ),', 'Padding(\n                        padding: const EdgeInsets.symmetric(vertical: 12),\n                        child: Divider(height: 1, color: Theme.of(context).dividerColor),\n                      ),');
  
  // Replace generic "const Text(" with "Text(" if it has "Theme.of" inside it
  final RegExp constTextRegex = RegExp(r'const\s+Text\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextRegex, (match) {
    return 'Text(${match.group(1)})';
  });

  // Replace generic "const TextStyle(" with "TextStyle(" if it has "Theme.of" inside it
  final RegExp constTextStyleRegex = RegExp(r'const\s+TextStyle\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextStyleRegex, (match) {
    return 'TextStyle(${match.group(1)})';
  });

  // Replace generic "const Icon(" with "Icon(" if it has "Theme.of" inside it
  final RegExp constIconRegex = RegExp(r'const\s+Icon\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constIconRegex, (match) {
    return 'Icon(${match.group(1)})';
  });

  // Replace generic "const Divider(" with "Divider(" if it has "Theme.of" inside it
  final RegExp constDividerRegex = RegExp(r'const\s+Divider\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constDividerRegex, (match) {
    return 'Divider(${match.group(1)})';
  });

  // Replace generic "const Padding(" with "Padding(" if it has "Theme.of" inside it
  // This is harder with regex because of nested parens.

  // Let's just blindly replace `const ` on some specific lines or just search for `const Text(` followed by `Theme.of(context)` within 5 lines.
  
  file.writeAsStringSync(c);
  print('Progress screen const errors fix applied');
}
