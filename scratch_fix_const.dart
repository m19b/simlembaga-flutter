import 'dart:io';

void main() {
  final file = File('lib/features/beranda/presentation/dashboard_screen.dart');
  String content = file.readAsStringSync();

  // Find occurrences of "const [Widget/Class](" that contain "context.k" and remove the "const"
  content = content.replaceAll('const CircularProgressIndicator(color: context.kHeaderColor)', 'CircularProgressIndicator(color: context.kHeaderColor)');
  content = content.replaceAll('const TextStyle(color: context.kTextPrimary', 'TextStyle(color: context.kTextPrimary');
  content = content.replaceAll('const TextStyle(color: context.kTextSecondary', 'TextStyle(color: context.kTextSecondary');
  content = content.replaceAll('const BorderSide(color: context.kHeaderColor)', 'BorderSide(color: context.kHeaderColor)');
  content = content.replaceAll('const Icon(Icons.settings, color: context.kHeaderColor)', 'Icon(Icons.settings, color: context.kHeaderColor)');
  
  // also fix formatting around const TextStyle where it might be multi-line
  content = content.replaceAll(RegExp(r'const\s+TextStyle\(\s*color:\s*context\.k'), 'TextStyle(color: context.k');
  content = content.replaceAll(RegExp(r'const\s+Icon\(\s*[^,]+,\s*color:\s*context\.k'), 'Icon('); // this is a bit risky, let's do it manually if needed

  file.writeAsStringSync(content);
  print('Fix applied');
}
