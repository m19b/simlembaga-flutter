import 'package:flutter/material.dart';
import 'row_state_model.dart';

class TahsinCatatanSheet extends StatefulWidget {
  final RowStateModel row;
  final List<Map<String, dynamic>> catatanMaster;
  final ValueChanged<String> onSave;

  const TahsinCatatanSheet({
    super.key,
    required this.row,
    required this.catatanMaster,
    required this.onSave,
  });

  @override
  State<TahsinCatatanSheet> createState() => _TahsinCatatanSheetState();
}

class _TahsinCatatanSheetState extends State<TahsinCatatanSheet> {
  late List<String> _selectedCatatan;

  @override
  void initState() {
    super.initState();
    _selectedCatatan = widget.row.catatanGuru.isNotEmpty
        ? widget.row.catatanGuru.split(', ').where((e) => e.isNotEmpty).toList()
        : [];
  }

  @override
  Widget build(BuildContext context) {
    const Color kAccent = Color(0xFF22C55E);
    const Color kHeader = Color(0xFF047857);
    const Color kText2 = Color(0xFF64748B);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Catatan Master',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih catatan standar untuk santri ini:',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.catatanMaster.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Tidak ada template catatan guru untuk kelas ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.catatanMaster.map((c) {
                final str = c['teks_catatan']?.toString() ?? '';
                if (str.isEmpty) return const SizedBox.shrink();
                final isSel = _selectedCatatan.contains(str);
                return FilterChip(
                  label: Text(str),
                  selected: isSel,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedCatatan.add(str);
                      } else {
                        _selectedCatatan.remove(str);
                      }
                    });
                  },
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF374151)
                      : Colors.grey.shade100,
                  selectedColor: kAccent.withValues(alpha: 0.15),
                  checkmarkColor: kAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: isSel ? kAccent : kText2,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onSave(_selectedCatatan.join(', '));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kHeader,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Simpan Catatan',
              style: TextStyle(
                color: Theme.of(context).cardColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
