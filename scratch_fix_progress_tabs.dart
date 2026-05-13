import 'dart:io';

void fixProgressScreen() {
  final file = File('lib/features/progress/presentation/progress_screen.dart');
  String c = file.readAsStringSync();

  // Dropdown header background
  c = c.replaceAll(
    'decoration: BoxDecoration(\n                              color: Colors.white,',
    'decoration: BoxDecoration(\n                              color: Theme.of(context).cardColor,'
  );

  // Bottom Nav Bar background
  c = c.replaceAll(
    'decoration: BoxDecoration(\n        color: Colors.white,',
    'decoration: BoxDecoration(\n        color: Theme.of(context).cardColor,'
  );

  // SantriCard background
  c = c.replaceAll(
    'decoration: BoxDecoration(\n        color: Colors.white,',
    'decoration: BoxDecoration(\n        color: Theme.of(context).cardColor,'
  );

  // Text inside _SantriCard that might be black (e.g. name)
  c = c.replaceAll(
    'style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)',
    'style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)'
  );
  
  c = c.replaceAll(
    'color: Colors.grey.shade800,',
    'color: Theme.of(context).colorScheme.onSurface,'
  );

  file.writeAsStringSync(c);
  print('progress_screen.dart fixed');
}

void fixRiwayatGlobalTab() {
  final file = File('lib/features/progress/presentation/riwayat_global_tab.dart');
  if (!file.existsSync()) return;
  String c = file.readAsStringSync();

  c = c.replaceAll('const Color _kBg = Color(0xFFF3F4F6);\n', '');
  c = c.replaceAll('const Color _kText1 = Color(0xFF111827);\n', '');
  c = c.replaceAll('const Color _kText2 = Color(0xFF6B7280);\n', '');

  c = c.replaceAll('backgroundColor: _kBg,', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor,');
  c = c.replaceAll('color: Colors.white,', 'color: Theme.of(context).cardColor,');
  
  // Date picker boxes
  c = c.replaceAll(
    'decoration: BoxDecoration(\n          color: isSelected ? _kAccent : Colors.white,\n          borderRadius: BorderRadius.circular(12),\n          border: Border.all(\n            color: isSelected ? _kAccent : Colors.grey.shade300,\n          ),\n        ),',
    'decoration: BoxDecoration(\n          color: isSelected ? _kAccent : Theme.of(context).cardColor,\n          borderRadius: BorderRadius.circular(12),\n          border: Border.all(\n            color: isSelected ? _kAccent : Theme.of(context).dividerColor,\n          ),\n        ),'
  );

  c = c.replaceAll('color: _kText1', 'color: Theme.of(context).colorScheme.onSurface');
  c = c.replaceAll('color: _kText2', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');
  c = c.replaceAll('color: Colors.grey.shade600', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');
  c = c.replaceAll('color: Colors.grey.shade300', 'color: Theme.of(context).dividerColor');
  
  // Also handle "const Text(" and "const TextStyle(" errors if any, but let's just remove them similarly if we used Theme.of
  final RegExp constTextRegex = RegExp(r'const\s+Text\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextRegex, (match) => 'Text(${match.group(1)})');

  final RegExp constTextStyleRegex = RegExp(r'const\s+TextStyle\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextStyleRegex, (match) => 'TextStyle(${match.group(1)})');
  
  file.writeAsStringSync(c);
  print('riwayat_global_tab.dart fixed');
}

void fixInputScreen() {
  final file = File('lib/features/progress/presentation/progress_input_screen.dart');
  if (!file.existsSync()) return;
  String c = file.readAsStringSync();

  c = c.replaceAll('const Color _kBg = Color(0xFFF3F4F6);\n', '');
  c = c.replaceAll('const Color _kText = Color(0xFF1F2937);\n', '');
  c = c.replaceAll('const Color _kSubtext = Color(0xFF6B7280);\n', '');

  c = c.replaceAll('backgroundColor: _kBg,', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor,');
  c = c.replaceAll('color: _kText', 'color: Theme.of(context).colorScheme.onSurface');
  c = c.replaceAll('color: _kSubtext', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');

  // container/card backgrounds
  c = c.replaceAll('color: Colors.white,', 'color: Theme.of(context).cardColor,');
  c = c.replaceAll('backgroundColor: Colors.white,', 'backgroundColor: Theme.of(context).cardColor,');
  c = c.replaceAll('Colors.grey.shade50', 'Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade50');
  c = c.replaceAll('Colors.grey.shade100', 'Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100');
  c = c.replaceAll('Colors.grey.shade200', 'Theme.of(context).dividerColor');
  c = c.replaceAll('Colors.grey.shade300', 'Theme.of(context).dividerColor');
  c = c.replaceAll('Colors.grey.shade600', 'Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');
  c = c.replaceAll('Colors.grey.shade800', 'Theme.of(context).colorScheme.onSurface');

  final RegExp constTextRegex = RegExp(r'const\s+Text\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextRegex, (match) => 'Text(${match.group(1)})');

  final RegExp constTextStyleRegex = RegExp(r'const\s+TextStyle\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextStyleRegex, (match) => 'TextStyle(${match.group(1)})');

  file.writeAsStringSync(c);
  print('progress_input_screen.dart fixed');
}

void fixEvaluasiInputRow() {
  final file = File('lib/features/progress/presentation/widgets/evaluasi_input_row.dart');
  if (!file.existsSync()) return;
  String c = file.readAsStringSync();

  c = c.replaceAll('color: Colors.white,', 'color: Theme.of(context).cardColor,');
  c = c.replaceAll('const Color _kText = Color(0xFF1F2937);\n', '');
  c = c.replaceAll('color: _kText', 'color: Theme.of(context).colorScheme.onSurface');
  c = c.replaceAll('color: Colors.grey.shade600', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');
  c = c.replaceAll('color: Colors.grey.shade500', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)');
  c = c.replaceAll('color: Colors.grey.shade300', 'color: Theme.of(context).dividerColor');
  c = c.replaceAll('color: Colors.grey.shade200', 'color: Theme.of(context).dividerColor');
  c = c.replaceAll('color: Colors.grey.shade100', 'Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100');
  
  c = c.replaceAll('color: Colors.orange.shade50', 'color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50');

  final RegExp constTextRegex = RegExp(r'const\s+Text\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextRegex, (match) => 'Text(${match.group(1)})');

  final RegExp constTextStyleRegex = RegExp(r'const\s+TextStyle\(([^)]*Theme\.of[^)]*)\)');
  c = c.replaceAllMapped(constTextStyleRegex, (match) => 'TextStyle(${match.group(1)})');

  file.writeAsStringSync(c);
  print('evaluasi_input_row.dart fixed');
}

void main() {
  fixProgressScreen();
  fixRiwayatGlobalTab();
  fixInputScreen();
  fixEvaluasiInputRow();
}
