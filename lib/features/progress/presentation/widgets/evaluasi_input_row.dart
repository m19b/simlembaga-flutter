import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);

/// Custom widget: Progress Stepper + TM input dalam SATU baris horizontal.
class EvaluasiInputRow extends StatelessWidget {
  final num awal;
  final num jumlah;
  final num akhir;
  final int tm;
  final VoidCallback onDecrementProgress;
  final VoidCallback onIncrementProgress;
  final VoidCallback onDecrementTm;
  final VoidCallback onIncrementTm;
  final ValueChanged<String> onProgressChanged;
  final ValueChanged<String> onTmChanged;
  final TextEditingController progressController;
  final TextEditingController tmController;
  final bool disabled;

  const EvaluasiInputRow({
    super.key,
    required this.awal,
    required this.jumlah,
    required this.akhir,
    required this.tm,
    required this.onDecrementProgress,
    required this.onIncrementProgress,
    required this.onDecrementTm,
    required this.onIncrementTm,
    required this.onProgressChanged,
    required this.onTmChanged,
    required this.progressController,
    required this.tmController,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                // ── Tombol AWAL (Kiri) ──
                Expanded(
                  flex: 2,
                  child: Material(
                    color: disabled ? Theme.of(context).disabledColor.withOpacity(0.05) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.blue.shade50),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                    child: InkWell(
                      onTap: disabled ? null : onDecrementProgress,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                      child: Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_rounded, size: 16, color: disabled ? Colors.grey.shade400 : _kText1),
                            const SizedBox(width: 2),
                            _infoCol(context, 'Awal', _fmt(awal), disabled: disabled),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── TOTAL HALAMAN (Tengah) ──
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Hal', style: TextStyle(fontSize: 9, color: disabled ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 24,
                          child: TextFormField(
                            controller: progressController,
                            enabled: !disabled,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: disabled ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.onSurface),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                            onChanged: onProgressChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tombol AKHIR (Kanan) ──
                Expanded(
                  flex: 2,
                  child: Material(
                    color: disabled ? Theme.of(context).disabledColor.withOpacity(0.05) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.blue.shade50),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                    child: InkWell(
                      onTap: disabled ? null : onIncrementProgress,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                      child: Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _infoCol(context, 'Akhir', _fmt(akhir), color: disabled ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary, disabled: disabled),
                            const SizedBox(width: 2),
                            Icon(Icons.add_rounded, size: 16, color: disabled ? Colors.grey.shade400 : _kText1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ── TM Input (Kecil) ──
        GestureDetector(
          onTap: () {
            // Tampilkan dialog kecil atau simple increment jika diklik?
            // Sesuai request: "kecilkan saja atau buat menjadi tombol kecil"
            // Kita buat input kecil saja yang bisa diketik/diklik.
          },
          child: Container(
            width: 50,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('TM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                IntrinsicWidth(
                  child: TextFormField(
                    controller: tmController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    onChanged: onTmChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(num v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString();
  }

  Widget _stepperBtn(VoidCallback? onTap, IconData icon, {bool disabled = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: disabled ? Colors.grey.shade300 : _kText1),
      ),
    );
  }

  Widget _infoCol(BuildContext context, String label, String val, {Color? color, bool disabled = false}) {
    return SizedBox(
      width: 40, // Slightly wider to accommodate bigger text
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.replaceAll('Hal ', ''), // Shorten label: 'Awal' instead of 'Hal Awal'
            style: TextStyle(fontSize: 9, color: disabled ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            val,
            style: TextStyle(fontSize: 14, color: disabled ? Theme.of(context).disabledColor : (color ?? Theme.of(context).colorScheme.primary), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
