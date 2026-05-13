import 'dart:io';

void main() {
  // 1. Fix progress_input_screen.dart
  final f1 = File('lib/features/progress/presentation/progress_input_screen.dart');
  String c1 = f1.readAsStringSync();
  c1 = c1.replaceAll('const Icon(\n                      Icons.calendar_today_rounded,\n                      color: Theme.of(context).cardColor,', 'Icon(\n                      Icons.calendar_today_rounded,\n                      color: Theme.of(context).cardColor,');
  c1 = c1.replaceAll('.onSurface1', '.onSurface');
  c1 = c1.replaceAll('.onSurface2', '.onSurface.withOpacity(0.6)');
  f1.writeAsStringSync(c1);

  // 2. Fix evaluasi_input_row.dart
  final f2 = File('lib/features/progress/presentation/widgets/evaluasi_input_row.dart');
  String c2 = f2.readAsStringSync();
  c2 = c2.replaceAll('.onSurface1', '.onSurface');
  c2 = c2.replaceAll('.onSurface2', '.onSurface.withOpacity(0.6)');
  f2.writeAsStringSync(c2);
  
  print('Errors fixed');
}
