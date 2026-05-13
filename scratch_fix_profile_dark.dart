import 'dart:io';

void main() {
  final file = File('lib/features/profile/presentation/profile_screen.dart');
  String c = file.readAsStringSync();

  // 1. Remove static _kBg, _kText, _kSubtext - keep _kHeader & _kPrimary as accent anchors
  c = c.replaceAll(
    'const Color _kBg       = Color(0xFFF3F4F6);\n',
    '',
  );
  c = c.replaceAll(
    'const Color _kText     = Color(0xFF1F2937);\n',
    '',
  );
  c = c.replaceAll(
    'const Color _kSubtext  = Color(0xFF6B7280);\n',
    '',
  );

  // 2. Scaffold bg
  c = c.replaceAll(
    'backgroundColor: _kBg,',
    'backgroundColor: Theme.of(context).scaffoldBackgroundColor,',
  );

  // 3. _kText usages → Theme.of(context).colorScheme.onSurface
  c = c.replaceAll('color: _kText,', 'color: Theme.of(context).colorScheme.onSurface,');
  c = c.replaceAll('color: _kText)', 'color: Theme.of(context).colorScheme.onSurface)');
  c = c.replaceAll('style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _kText)',
      'style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)');

  // 4. _kSubtext → slightly muted text
  c = c.replaceAll('color: _kSubtext', 'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');

  // 5. fillColor: Colors.white in _inputDeco → use surface color
  c = c.replaceAll(
    'fillColor: Colors.white,',
    'fillColor: Theme.of(context).colorScheme.surface,',
  );

  // 6. Input border colors → theme-aware
  c = c.replaceAll(
    'borderSide: BorderSide(color: Colors.grey.shade200),',
    'borderSide: BorderSide(color: Theme.of(context).dividerColor),',
  );

  // 7. Read-only card bg & border
  c = c.replaceAll(
    'color: Colors.grey.shade50,\n        borderRadius: BorderRadius.circular(16),\n        border: Border.all(color: Colors.grey.shade200),',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.grey.shade50,\n        borderRadius: BorderRadius.circular(16),\n        border: Border.all(color: Theme.of(context).dividerColor),',
  );

  // 8. Read-only label color
  c = c.replaceAll(
    'style: TextStyle(fontSize: 13, color: const Color(0xFF374151), fontWeight: FontWeight.w600)',
    'style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)',
  );

  // 9. _SectionCard title color _kText
  c = c.replaceAll(
    '                  color: _kText,\n                  fontSize: 14,',
    '                  color: Theme.of(context).colorScheme.onSurface,\n                  fontSize: 14,',
  );

  // 10. _LabeledField label color _kSubtext
  c = c.replaceAll(
    '              color: _kSubtext,\n            ),',
    '              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),\n            ),',
  );

  // 11. Avatar background grey.shade200 → theme surface
  c = c.replaceAll(
    'backgroundColor: Colors.grey.shade200,',
    'backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,',
  );

  // 12. TERKUNCI badge bg/text
  c = c.replaceAll(
    'color: Colors.grey.shade200,\n                    borderRadius: BorderRadius.circular(4),',
    'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade200,\n                    borderRadius: BorderRadius.circular(4),',
  );
  c = c.replaceAll(
    'style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold))',
    'style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold))',
  );

  // 13. Refresh icon circle avatar (no avatar bg mentioned above is already done)

  file.writeAsStringSync(c);
  print('Profile dark mode fix applied');
}
