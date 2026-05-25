import 'dart:io';

void main() {
  final dir = Directory('lib/features/pra_tahfidz');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  final list = [];
  for (var f in files) {
    final lines = f.readAsLinesSync().length;
    list.add({'name': f.path, 'lines': lines});
  }
  
  list.sort((a, b) => b['lines'].compareTo(a['lines']));
  for (var item in list) {
    print('${item['lines'].toString().padLeft(5)} lines : ${item['name']}');
  }
}
