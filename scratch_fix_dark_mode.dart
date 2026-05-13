import 'dart:io';

void main() {
  // 1. Fix dashboard_attendance_widget.dart
  final attFile = File('lib/features/beranda/presentation/dashboard_attendance_widget.dart');
  String attContent = attFile.readAsStringSync();
  attContent = attContent.replaceAll(
    'color: Colors.white,',
    'color: Theme.of(context).cardColor,'
  );
  attContent = attContent.replaceAll(
    'color: const Color(0xFF111827),',
    'color: Theme.of(context).colorScheme.onSurface,'
  );
  // Line 390
  attContent = attContent.replaceAll(
    'color: Color(0xFF1F2937),',
    'color: Theme.of(context).colorScheme.onSurface,'
  );
  // Bottom action bar uses gray background
  attContent = attContent.replaceAll(
    'color: Colors.grey.shade50,',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : Colors.grey.shade50,'
  );
  attFile.writeAsStringSync(attContent);

  // 2. Fix dashboard_screen.dart
  final dashFile = File('lib/features/beranda/presentation/dashboard_screen.dart');
  String content = dashFile.readAsStringSync();

  // Fix _buildSliverAppBar text colors: change context.kCardColor to Colors.white
  // _buildSliverAppBar is roughly from line 280 to 513
  // Since we know the only place where text is $name $role etc is inside SliverAppBar
  // Let's replace the specific block using regex or string replacement

  content = content.replaceAll(
    "style: TextStyle(\n                        color: context.kCardColor,",
    "style: const TextStyle(\n                        color: Colors.white,"
  );
  content = content.replaceAll(
    "color: context.kCardColor70,",
    "color: Colors.white70,"
  );
  content = content.replaceAll(
    "style: TextStyle(\n                              color: context.kCardColor,",
    "style: const TextStyle(\n                              color: Colors.white,"
  );
  content = content.replaceAll(
    "color: context.kCardColor.withOpacity(0.15),",
    "color: Colors.white.withOpacity(0.15),"
  );
  content = content.replaceAll(
    "Icon(icon, color: context.kCardColor,",
    "Icon(icon, color: Colors.white,"
  );
  content = content.replaceAll(
    "style: TextStyle(\n                color: context.kCardColor,",
    "style: const TextStyle(\n                color: Colors.white,"
  );

  // Fix background colors of Jadwal
  // We need to change the lists inside `_buildJadwalSection`
  content = content.replaceAll(
    'Colors.orange.shade50,',
    'Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade900.withOpacity(0.4) : Colors.orange.shade50,'
  );
  content = content.replaceAll(
    'Colors.blue.shade50,',
    'Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade900.withOpacity(0.4) : Colors.blue.shade50,'
  );
  content = content.replaceAll(
    'Colors.green.shade50,',
    'Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900.withOpacity(0.4) : Colors.green.shade50,'
  );
  content = content.replaceAll(
    'Colors.purple.shade50,',
    'Theme.of(context).brightness == Brightness.dark ? Colors.purple.shade900.withOpacity(0.4) : Colors.purple.shade50,'
  );
  content = content.replaceAll(
    'Colors.red.shade50,',
    'Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900.withOpacity(0.4) : Colors.red.shade50,'
  );
  content = content.replaceAll(
    'Colors.teal.shade50,',
    'Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade900.withOpacity(0.4) : Colors.teal.shade50,'
  );

  // fgMat shades should also adapt to dark mode
  content = content.replaceAll(
    'color: fgMat.shade900,',
    'color: Theme.of(context).brightness == Brightness.dark ? fgMat.shade100 : fgMat.shade900,'
  );
  content = content.replaceAll(
    'color: fgMat.shade800',
    'color: Theme.of(context).brightness == Brightness.dark ? fgMat.shade200 : fgMat.shade800'
  );
  content = content.replaceAll(
    'color: fgMat.shade700',
    'color: Theme.of(context).brightness == Brightness.dark ? fgMat.shade300 : fgMat.shade700'
  );

  // container icons inside jadwal
  content = content.replaceAll(
    'color: fgMat.shade100,',
    'color: Theme.of(context).brightness == Brightness.dark ? fgMat.shade900.withOpacity(0.6) : fgMat.shade100,'
  );
  content = content.replaceAll(
    'border: Border.all(color: fgMat.shade200),',
    'border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? fgMat.shade800 : fgMat.shade200),'
  );

  dashFile.writeAsStringSync(content);
  print('Fix applied for dark mode hardcoded colors');
}
