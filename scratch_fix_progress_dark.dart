import 'dart:io';

void main() {
  final file = File('lib/features/progress/presentation/progress_screen.dart');
  String c = file.readAsStringSync();

  // 1. Remove _kBg and _kText constants, keep _kHeader and _kAccent
  c = c.replaceAll("const Color _kBg = Color(0xFFF3F4F6);\n", '');
  c = c.replaceAll("const Color _kText1 = Color(0xFF111827);\n", '');
  c = c.replaceAll("const Color _kText2 = Color(0xFF6B7280);\n", '');

  // 2. Scaffold background
  c = c.replaceAll('backgroundColor: _kBg,', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor,');

  // 3. _kText1 usages
  c = c.replaceAll('color: _kText1,', 'color: Theme.of(context).colorScheme.onSurface,');
  c = c.replaceAll('color: _kText1)', 'color: Theme.of(context).colorScheme.onSurface)');

  // 4. _kText2 usages
  c = c.replaceAll('color: _kText2,', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),');
  c = c.replaceAll('color: _kText2)', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))');

  // 5. Tab chip selection colors (light/dark)
  c = c.replaceAll(
    'color: isSelected ? const Color(0xFFF0FDF4) : Colors.transparent,',
    'color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? _kHeader.withOpacity(0.4) : const Color(0xFFF0FDF4)) : Colors.transparent,',
  );
  c = c.replaceAll(
    'color: isSel ? _kHeader : Colors.grey.shade100,',
    'color: isSel ? _kHeader : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100),',
  );
  c = c.replaceAll(
    'border: Border.all(color: isSel ? _kHeader : Colors.grey.shade300),',
    'border: Border.all(color: isSel ? _kHeader : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF4B5563) : Colors.grey.shade300)),',
  );
  c = c.replaceAll(
    'color: isSel ? Colors.white : _kText2,',
    'color: isSel ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),',
  );

  // 6. Card backgrounds
  c = c.replaceAll(
    'color: Colors.grey.shade100,\n        borderRadius: BorderRadius.circular',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100,\n        borderRadius: BorderRadius.circular',
  );
  c = c.replaceAll(
    'color: Colors.grey.shade100,\n      borderRadius:',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100,\n      borderRadius:',
  );

  // 7. Catatan search field fill
  c = c.replaceAll(
    'fillColor: Colors.grey.shade100,',
    'fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100,',
  );

  // 8. Border colors grey.shade300
  c = c.replaceAll(
    'border: Border.all(color: Colors.grey.shade300),',
    'border: Border.all(color: Theme.of(context).dividerColor),',
  );
  // grey.shade200
  c = c.replaceAll(
    'border: Border.all(color: Colors.grey.shade200)',
    'border: Border.all(color: Theme.of(context).dividerColor)',
  );

  // 9. Catatan item container
  c = c.replaceAll(
    'color: Colors.grey.shade100,\n      child:',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.grey.shade100,\n      child:',
  );

  // 10. Divider in detail
  c = c.replaceAll(
    'child: Divider(height: 1, color: Color(0xFFF3F4F6)),',
    'child: Divider(height: 1, color: Theme.of(context).dividerColor),',
  );

  // 11. Catatan list card bg
  c = c.replaceAll(
    'color: Colors.grey.shade100,\n            border:',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.grey.shade100,\n            border:',
  );

  file.writeAsStringSync(c);
  print('Progress screen dark mode fix applied');
}
