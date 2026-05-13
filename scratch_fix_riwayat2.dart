import 'dart:io';

void main() {
  final f = File('lib/features/progress/presentation/riwayat_global_tab.dart');
  if (!f.existsSync()) return;

  String c = f.readAsStringSync();

  // Replace hardcoded grey colors with Theme-based dynamic colors
  c = c.replaceAll('Colors.grey.shade600', 'Theme.of(context).colorScheme.onSurface.withOpacity(0.6)');
  c = c.replaceAll('Colors.grey.shade200', 'Theme.of(context).dividerColor');
  c = c.replaceAll('Colors.grey.shade400', 'Theme.of(context).colorScheme.onSurface.withOpacity(0.4)');
  c = c.replaceAll('Colors.grey.shade500', 'Theme.of(context).colorScheme.onSurface.withOpacity(0.5)');
  c = c.replaceAll('Colors.grey.shade100', 'Theme.of(context).colorScheme.surfaceContainerHighest');
  c = c.replaceAll('Colors.grey.shade700', 'Theme.of(context).colorScheme.onSurfaceVariant');
  c = c.replaceAll('Colors.indigo.shade50', 'Theme.of(context).colorScheme.primaryContainer');
  c = c.replaceAll('Colors.indigo', 'Theme.of(context).colorScheme.onPrimaryContainer');
  c = c.replaceAll('Colors.black.withValues(alpha: 0.03)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05)');

  f.writeAsStringSync(c);
  print('riwayat_global_tab.dart hardcoded colors fixed!');
}
