import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

class PraTahfidzMassalCard extends StatefulWidget {
  final Map<String, dynamic> santri;
  final Map<String, dynamic> rowData;
  final double kelipatan;

  const PraTahfidzMassalCard({
    super.key,
    required this.santri,
    required this.rowData,
    required this.kelipatan,
  });

  @override
  State<PraTahfidzMassalCard> createState() => _PraTahfidzMassalCardState();
}

class _PraTahfidzMassalCardState extends State<PraTahfidzMassalCard> {
  late TextEditingController _awalCtrl;
  late TextEditingController _akhirCtrl;
  late TextEditingController _totalCtrl;

  @override
  void initState() {
    super.initState();
    final hAwal = widget.rowData['hal_awal'] as double? ?? 0.0;
    final hAkhir = widget.rowData['hal_akhir'] as double? ?? 0.0;
    final tHal = widget.rowData['total_hal'] as double? ?? 0.0;
    
    _awalCtrl = TextEditingController(text: _fmtVal(hAwal));
    _akhirCtrl = TextEditingController(text: _fmtVal(hAkhir));
    _totalCtrl = TextEditingController(text: _fmtVal(tHal));

    _awalCtrl.addListener(_onHalChanged);
    _akhirCtrl.addListener(_onHalChanged);
  }

  @override
  void didUpdateWidget(covariant PraTahfidzMassalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika kelipatan berubah, hitung ulang total hal tanpa menyentuh controller
    if (oldWidget.kelipatan != widget.kelipatan) {
      _recalcTotalFromAwalAkhir();
    }
  }

  @override
  void dispose() {
    _awalCtrl.removeListener(_onHalChanged);
    _akhirCtrl.removeListener(_onHalChanged);
    _awalCtrl.dispose();
    _akhirCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  String _fmtVal(double val) {
    if (val == 0) return '';
    return val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  void _onHalChanged() {
    _recalcTotalFromAwalAkhir();
  }

  void _recalcTotalFromAwalAkhir() {
    final awal = double.tryParse(_awalCtrl.text.replaceAll(',', '.')) ?? 0;
    final akhir = double.tryParse(_akhirCtrl.text.replaceAll(',', '.')) ?? 0;

    double diff = akhir - awal;
    double t = 0;

    if (diff > 0) {
      t = (diff * widget.kelipatan) + widget.kelipatan;
    } else if (diff == 0 && _awalCtrl.text.isNotEmpty && _akhirCtrl.text.isNotEmpty) {
      t = widget.kelipatan;
    }

    if (t != (double.tryParse(_totalCtrl.text) ?? 0)) {
      _totalCtrl.text = _fmtVal(t);
    }
    
    // Update parent's rowData Map!
    widget.rowData['hal_awal'] = awal;
    widget.rowData['hal_akhir'] = akhir;
    widget.rowData['total_hal'] = t;
  }

  void _onTotalChanged(String val) {
    final t = double.tryParse(val.replaceAll(',', '.')) ?? 0;
    widget.rowData['total_hal'] = t;
  }

  void _setStatus(String st) {
    setState(() {
      widget.rowData['status_bacaan'] = st;
    });
  }

  Widget _buildStatusBtn(String label, String currentStatus, Color defaultColor) {
    final isSelected = currentStatus == label;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _setStatus(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? defaultColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? defaultColor : colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? defaultColor : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusBacaan = widget.rowData['status_bacaan'] as String? ?? 'Sesuai Target';

    Color borderCard;
    if (statusBacaan == 'Lebih') {
      borderCard = styles.success;
    } else if (statusBacaan == 'Kurang') {
      borderCard = styles.warning;
    } else {
      borderCard = colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCard.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderCard.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: borderCard.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.santri['nama_santri'] ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  'Sesi ${widget.rowData['sesi'] ?? 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: borderCard,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pointer Terakhir',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _fmtVal(double.tryParse(widget.santri['pointer_halaman']?.toString() ?? '0') ?? 0),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hal. Awal  -  Hal. Akhir',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(_awalCtrl, 'Awal', colorScheme),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('-'),
                              ),
                              Expanded(
                                child: _buildTextField(_akhirCtrl, 'Akhir', colorScheme),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Hal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: borderCard,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildTextField(
                            _totalCtrl,
                            'Total',
                            colorScheme,
                            textColor: borderCard,
                            onChanged: _onTotalChanged,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusBtn('Lebih', statusBacaan, styles.success),
                    const SizedBox(width: 8),
                    _buildStatusBtn('Sesuai Target', statusBacaan, colorScheme.primary),
                    const SizedBox(width: 8),
                    _buildStatusBtn('Kurang', statusBacaan, styles.warning),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    ColorScheme colorScheme, {
    Color? textColor,
    Function(String)? onChanged,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: TextField(
          controller: ctrl,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor ?? colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ),
    );
  }
}
