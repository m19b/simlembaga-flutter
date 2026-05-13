import 'dart:io';

void main() {
  final f = File('../silembaga/app/Models/Akademik/PrestasiModel.php');
  if (!f.existsSync()) {
    print('File not found!');
    return;
  }
  String c = f.readAsStringSync();

  // Fix wrong column name: status_kehadiran -> id_kehadiran with numeric values
  c = c.replaceAll(
    "pr.status_kehadiran = 'H'",
    "pr.id_kehadiran = 1",
  );
  c = c.replaceAll(
    "pr.status_kehadiran NOT IN ('I', 'S')",
    "pr.id_kehadiran NOT IN (2, 3)",
  );

  f.writeAsStringSync(c);
  print('PrestasiModel.php filter column fixed: status_kehadiran -> id_kehadiran!');
}
