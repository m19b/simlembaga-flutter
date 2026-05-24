import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TahfidzInputRow extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final double awal;
  final TextEditingController awalCtrl;
  final TextEditingController akhirCtrl;
  final TextEditingController totalCtrl;
  final double kelipatan;
  final bool editAwalMode;
  final ValueChanged<String> onAwalChanged;
  final ValueChanged<String> onAkhirChanged;
  final ValueChanged<String> onTotalChanged;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;

  const TahfidzInputRow({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.awal,
    required this.awalCtrl,
    required this.akhirCtrl,
    required this.totalCtrl,
    required this.kelipatan,
    required this.editAwalMode,
    required this.onAwalChanged,
    required this.onAkhirChanged,
    required this.onTotalChanged,
    required this.onAdd,
    required this.onSubtract,
  });

  String _fmt(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '0') ?? 0;
    if (d == 0) return '0';
    return d == d.toInt()
        ? d.toInt().toString()
        : d.toStringAsFixed(1).replaceAll('.0', '');
  }

  @override
  Widget build(BuildContext context) {
    final strAwal = _fmt(awal);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri: Kolom Label
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Kanan: Input Controls
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Awal
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Awal',
                      style: TextStyle(
                        fontSize: 9,
                        color: color.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (editAwalMode)
                      Container(
                        height: 24,
                        width: 35,
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          controller: awalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          style: TextStyle(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: 12),
                          ),
                          onChanged: onAwalChanged,
                        ),
                      )
                    else
                      Text(
                        strAwal,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                // Plus-Minus Buttons (FULL HEIGHT MERGE)
                IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Minus
                        InkWell(
                          onTap: onSubtract,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                          child: Container(
                            width: 28,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.remove, size: 14),
                          ),
                        ),
                        // Total
                        Container(
                          width: 36,
                          alignment: Alignment.center,
                          child: TextFormField(
                            controller: totalCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: onTotalChanged,
                          ),
                        ),
                        // Plus
                        InkWell(
                          onTap: onAdd,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                          child: Container(
                            width: 28,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.add, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Akhir
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Akhir',
                      style: TextStyle(
                        fontSize: 9,
                        color: color.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 35,
                      alignment: Alignment.centerRight,
                      child: TextFormField(
                        controller: akhirCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 12),
                        ),
                        onChanged: onAkhirChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
