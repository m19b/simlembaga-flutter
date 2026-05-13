import 'dart:io';

void main() {
  final file = File('lib/features/beranda/presentation/dashboard_screen.dart');
  String content = file.readAsStringSync();

  content = content.replaceAll('kBgColor', 'context.kBgColor');
  content = content.replaceAll('kHeaderColor', 'context.kHeaderColor');
  content = content.replaceAll('kTextPrimary', 'context.kTextPrimary');
  content = content.replaceAll('kTextSecondary', 'context.kTextSecondary');
  content = content.replaceAll('Colors.white', 'context.kCardColor');
  
  // Undo the replacement on the constants definitions themselves
  content = content.replaceAll('const Color context.kBgColor = Color(0xFFF3F4F6); // 60% Light background', 'const Color kBgColor = Color(0xFFF3F4F6); // 60% Light background');
  content = content.replaceAll('const Color context.kHeaderColor = Color(0xFF0F4C2A); // 30% Dark Green header', 'const Color kHeaderColor = Color(0xFF0F4C2A); // 30% Dark Green header');
  content = content.replaceAll('const Color context.kTextPrimary = Color(0xFF1F2937);', 'const Color kTextPrimary = Color(0xFF1F2937);');
  content = content.replaceAll('const Color context.kTextSecondary = Color(0xFF6B7280);', 'const Color kTextSecondary = Color(0xFF6B7280);');

  file.writeAsStringSync(content);
  print('Done replacing');
}
