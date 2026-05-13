import 'dart:io';

void main() {
  final f = File('lib/features/progress/presentation/riwayat_global_tab.dart');
  if (f.existsSync()) {
    String c = f.readAsStringSync();
    
    // Replace kBg with scaffoldBackgroundColor
    c = c.replaceAll('color: kBg,', 'color: Theme.of(context).scaffoldBackgroundColor,');
    
    // Fix _HariSubTab date scroller colors
    c = c.replaceAll(
      'border: Border.all(color: isSelected ? kPrimary : Colors.grey.shade300),',
      'border: Border.all(color: isSelected ? kPrimary : Theme.of(context).dividerColor),'
    );
    c = c.replaceAll(
      'color: isSelected ? Colors.white : Colors.grey.shade600',
      'color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)'
    );
    c = c.replaceAll(
      'color: isSelected ? Colors.white : Colors.black87',
      'color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface'
    );
    
    // Fix _MingguSubTab text colors
    c = c.replaceAll(
      'color: isSelected ? Colors.white : Colors.grey.shade700',
      'color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface'
    );
    c = c.replaceAll(
      'color: Colors.black87, fontWeight: FontWeight.bold',
      'color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold'
    );
    c = c.replaceAll(
      'color: Colors.grey.shade800',
      'color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)'
    );
    
    // Fix _buildLegend text color
    c = c.replaceAll(
      'color: Colors.black87)',
      'color: Theme.of(context).colorScheme.onSurface)'
    );

    f.writeAsStringSync(c);
    print('riwayat_global_tab.dart fixes applied');
  }
}
