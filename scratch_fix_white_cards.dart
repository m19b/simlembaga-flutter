import 'dart:io';

void main() {
  final f1 = File('lib/features/progress/presentation/progress_screen.dart');
  if (f1.existsSync()) {
    String c1 = f1.readAsStringSync();
    
    // Fix RefreshIndicator color to have a dark background
    c1 = c1.replaceAll(
      'RefreshIndicator(\n                  onRefresh: _load,\n                  color: _kAccent,',
      'RefreshIndicator(\n                  onRefresh: _load,\n                  color: _kAccent,\n                  backgroundColor: Theme.of(context).cardColor,'
    );

    // Fix _buildFilterBar white background
    c1 = c1.replaceAll(
      'Widget _buildFilterBar() {\n    if (_kelompokList.length <= 1 && _kelasList.length <= 1)\n      return const SizedBox.shrink();\n    return Container(\n      color: Colors.white,',
      'Widget _buildFilterBar() {\n    if (_kelompokList.length <= 1 && _kelasList.length <= 1)\n      return const SizedBox.shrink();\n    return Container(\n      color: Theme.of(context).scaffoldBackgroundColor,'
    );

    // Fix _SkeletonCard white background
    c1 = c1.replaceAll(
      'decoration: BoxDecoration(\n          color: Colors.white,\n          borderRadius: BorderRadius.circular(16),\n        ),',
      'decoration: BoxDecoration(\n          color: Theme.of(context).cardColor,\n          borderRadius: BorderRadius.circular(16),\n        ),'
    );

    f1.writeAsStringSync(c1);
    print('progress_screen.dart fixes applied');
  }

  final f2 = File('lib/features/progress/presentation/progress_input_screen.dart');
  if (f2.existsSync()) {
    String c2 = f2.readAsStringSync();
    
    c2 = c2.replaceAll(
      'RefreshIndicator(\n                color: _kAccent,\n                onRefresh: _loadSantri,',
      'RefreshIndicator(\n                color: _kAccent,\n                backgroundColor: Theme.of(context).cardColor,\n                onRefresh: _loadSantri,'
    );

    c2 = c2.replaceAll(
      'Widget _buildFilterBar() {\n    if (_kelompokList.length <= 1) return const SizedBox.shrink();\n    return Container(\n      color: Colors.white,',
      'Widget _buildFilterBar() {\n    if (_kelompokList.length <= 1) return const SizedBox.shrink();\n    return Container(\n      color: Theme.of(context).scaffoldBackgroundColor,'
    );

    c2 = c2.replaceAll(
      'decoration: BoxDecoration(\n            color: Colors.white,\n            borderRadius: BorderRadius.circular(16),\n          ),',
      'decoration: BoxDecoration(\n            color: Theme.of(context).cardColor,\n            borderRadius: BorderRadius.circular(16),\n          ),'
    );

    f2.writeAsStringSync(c2);
    print('progress_input_screen.dart fixes applied');
  }
}
