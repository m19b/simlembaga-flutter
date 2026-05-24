import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'tahfidz_input_row.dart';

class TahfidzSantriCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> santri;
  final Map<String, dynamic> row;
  final double kelipatan;
  final List<Map<String, dynamic>> catatanMaster;
  final void Function(String key, dynamic value) onChanged;

  const TahfidzSantriCard({
    super.key,
    required this.index,
    required this.santri,
    required this.row,
    required this.kelipatan,
    this.catatanMaster = const [],
    required this.onChanged,
  });

  @override
  State<TahfidzSantriCard> createState() => _TahfidzSantriCardState();
}

class _TahfidzSantriCardState extends State<TahfidzSantriCard> {
  late TextEditingController _zAkhirCtrl;
  late TextEditingController _zTotCtrl;
  late TextEditingController _zAwalCtrl;
  late TextEditingController _sAkhirCtrl;
  late TextEditingController _sTotCtrl;
  late TextEditingController _sAwalCtrl;
  late TextEditingController _mAkhirCtrl;
  late TextEditingController _mTotCtrl;
  late TextEditingController _mAwalCtrl;

  bool _editAwalMode = false;

  @override
  void initState() {
    super.initState();
    final r = widget.row;
    _zAwalCtrl = TextEditingController(text: _fmt(r['z_aw']));
    _zAkhirCtrl = TextEditingController(text: _fmt(r['z_ak']));
    _zTotCtrl = TextEditingController(text: _fmt(r['z_tot']));
    _sAwalCtrl = TextEditingController(text: _fmt(r['s_aw']));
    _sAkhirCtrl = TextEditingController(text: _fmt(r['s_ak']));
    _sTotCtrl = TextEditingController(text: _fmt(r['s_tot']));
    _mAwalCtrl = TextEditingController(text: _fmt(r['m_aw']));
    _mAkhirCtrl = TextEditingController(text: _fmt(r['m_ak']));
    _mTotCtrl = TextEditingController(text: _fmt(r['m_tot']));
  }

  @override
  void didUpdateWidget(covariant TahfidzSantriCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row != widget.row) {
      if (_zAwalCtrl.text != _fmt(widget.row['z_aw'])) {
        _zAwalCtrl.text = _fmt(widget.row['z_aw']);
      }
      if (_zAkhirCtrl.text != _fmt(widget.row['z_ak'])) {
        _zAkhirCtrl.text = _fmt(widget.row['z_ak']);
      }
      if (_zTotCtrl.text != _fmt(widget.row['z_tot'])) {
        _zTotCtrl.text = _fmt(widget.row['z_tot']);
      }
      if (_sAwalCtrl.text != _fmt(widget.row['s_aw'])) {
        _sAwalCtrl.text = _fmt(widget.row['s_aw']);
      }
      if (_sAkhirCtrl.text != _fmt(widget.row['s_ak'])) {
        _sAkhirCtrl.text = _fmt(widget.row['s_ak']);
      }
      if (_sTotCtrl.text != _fmt(widget.row['s_tot'])) {
        _sTotCtrl.text = _fmt(widget.row['s_tot']);
      }
      if (_mAwalCtrl.text != _fmt(widget.row['m_aw'])) {
        _mAwalCtrl.text = _fmt(widget.row['m_aw']);
      }
      if (_mAkhirCtrl.text != _fmt(widget.row['m_ak'])) {
        _mAkhirCtrl.text = _fmt(widget.row['m_ak']);
      }
      if (_mTotCtrl.text != _fmt(widget.row['m_tot'])) {
        _mTotCtrl.text = _fmt(widget.row['m_tot']);
      }
    }
  }

  String _fmt(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '0') ?? 0;
    if (d == 0) return '0';
    return d == d.toInt()
        ? d.toInt().toString()
        : d.toStringAsFixed(1).replaceAll('.0', '');
  }

  void _showCatatanDialog(BuildContext context, Map<String, dynamic> r) {
    final ctrl = TextEditingController(text: r['catatan']?.toString() ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
              const Text(
                'Catatan Santri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (widget.catatanMaster.isNotEmpty) ...[
                const SizedBox(height: 12),
                StatefulBuilder(builder: (context, setModalState) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.catatanMaster.map((cat) {
                      final textCat = cat['teks_catatan']?.toString() ?? '';
                      final isSelected = ctrl.text.contains(textCat);
                      return FilterChip(
                        label: Text(textCat, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              if (ctrl.text.isEmpty) {
                                ctrl.text = textCat;
                              } else if (!ctrl.text.contains(textCat)) {
                                ctrl.text = '${ctrl.text}, $textCat';
                              }
                            } else {
                              ctrl.text = ctrl.text
                                  .replaceFirst(', $textCat', '')
                                  .replaceFirst('$textCat, ', '')
                                  .replaceFirst(textCat, '')
                                  .trim();
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                }),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis catatan untuk santri ini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    widget.onChanged('catatan', ctrl.text);
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Simpan Catatan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _onAwalChanged(
    String prefix,
    String val,
    TextEditingController totalCtrl,
  ) {
    final aw = double.tryParse(val) ?? 0;
    widget.onChanged('${prefix}_aw', aw);
    final ak = widget.row['${prefix}_ak'] as double;
    final tot = (ak - aw).clamp(0.0, 999.0);
    widget.onChanged('${prefix}_tot', tot);
    totalCtrl.text = _fmt(tot);
  }

  void _onAkhirChanged(
    String prefix,
    String val,
    TextEditingController totalCtrl,
  ) {
    final ak = double.tryParse(val) ?? 0;
    final aw = widget.row['${prefix}_aw'] as double;
    final tot = (ak - aw).clamp(0.0, 999.0);
    widget.onChanged('${prefix}_ak', ak);
    widget.onChanged('${prefix}_tot', tot);
    totalCtrl.text = _fmt(tot);
  }

  void _onTotChanged(
    String prefix,
    String val,
    TextEditingController akhirCtrl,
  ) {
    final tot = double.tryParse(val) ?? 0;
    final aw = widget.row['${prefix}_aw'] as double;
    final ak = aw + tot;
    widget.onChanged('${prefix}_tot', tot);
    widget.onChanged('${prefix}_ak', ak);
    akhirCtrl.text = _fmt(ak);
  }

  void _addTot(
    String prefix,
    double val,
    TextEditingController totalCtrl,
    TextEditingController akhirCtrl,
  ) {
    final currentTot = widget.row['${prefix}_tot'] as double;
    final newTot = (currentTot + val).clamp(0.0, 999.0);
    _onTotChanged(prefix, newTot.toString(), akhirCtrl);
    totalCtrl.text = _fmt(newTot);
  }

  @override
  void dispose() {
    _zAwalCtrl.dispose();
    _zAkhirCtrl.dispose();
    _zTotCtrl.dispose();
    _sAwalCtrl.dispose();
    _sAkhirCtrl.dispose();
    _sTotCtrl.dispose();
    _mAwalCtrl.dispose();
    _mAkhirCtrl.dispose();
    _mTotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.santri;
    final r = widget.row;
    final idx = widget.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final nama = s['nama_santri']?.toString() ?? '-';
    final nis = s['nis']?.toString() ?? '-';

    // Label JUZ X logic (Pilar 4)
    String rawTingkat =
        s['tingkat']?.toString() ?? s['nama_kelas']?.toString() ?? '';
    if (rawTingkat.isEmpty || rawTingkat == 'null') rawTingkat = 'TAHFIDZ';
    String badge = rawTingkat;
    if (!badge.toUpperCase().contains('JUZ') &&
        badge.toUpperCase() != 'TAHFIDZ') {
      badge = 'JUZ $badge';
    } else if (badge.toUpperCase() == 'TAHFIDZ') {
      badge = 'TAHFIDZ';
    }

    bool isLulus = r['z_status'] == 'Lulus';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            nis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.indigo.withValues(alpha: 0.2)
                                  : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark
                                    ? Colors.indigo.shade300
                                    : Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Awal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 24,
                      child: Transform.scale(
                        scale: 0.7,
                        child: CupertinoSwitch(
                          value: _editAwalMode,
                          onChanged: (v) => setState(() => _editAwalMode = v),
                          activeColor: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Rows Input (Pilar 4)
            TahfidzInputRow(
              label: 'Ziyadah',
              color: Colors.blue.shade600,
              icon: Icons.arrow_upward_rounded,
              awal: r['z_aw'] as double,
              awalCtrl: _zAwalCtrl,
              akhirCtrl: _zAkhirCtrl,
              totalCtrl: _zTotCtrl,
              kelipatan: widget.kelipatan,
              editAwalMode: _editAwalMode,
              onAwalChanged: (v) => _onAwalChanged('z', v, _zTotCtrl),
              onAkhirChanged: (v) => _onAkhirChanged('z', v, _zTotCtrl),
              onTotalChanged: (v) => _onTotChanged('z', v, _zAkhirCtrl),
              onAdd: () =>
                  _addTot('z', widget.kelipatan, _zTotCtrl, _zAkhirCtrl),
              onSubtract: () =>
                  _addTot('z', -widget.kelipatan, _zTotCtrl, _zAkhirCtrl),
            ),
            const SizedBox(height: 2),
            TahfidzInputRow(
              label: 'Sabaq',
              color: Colors.orange.shade600,
              icon: Icons.refresh_rounded,
              awal: r['s_aw'] as double,
              awalCtrl: _sAwalCtrl,
              akhirCtrl: _sAkhirCtrl,
              totalCtrl: _sTotCtrl,
              kelipatan: widget.kelipatan,
              editAwalMode: _editAwalMode,
              onAwalChanged: (v) => _onAwalChanged('s', v, _sTotCtrl),
              onAkhirChanged: (v) => _onAkhirChanged('s', v, _sTotCtrl),
              onTotalChanged: (v) => _onTotChanged('s', v, _sAkhirCtrl),
              onAdd: () =>
                  _addTot('s', widget.kelipatan, _sTotCtrl, _sAkhirCtrl),
              onSubtract: () =>
                  _addTot('s', -widget.kelipatan, _sTotCtrl, _sAkhirCtrl),
            ),
            const SizedBox(height: 2),
            TahfidzInputRow(
              label: 'Manzil',
              color: Colors.green.shade600,
              icon: Icons.history_edu_rounded,
              awal: r['m_aw'] as double,
              awalCtrl: _mAwalCtrl,
              akhirCtrl: _mAkhirCtrl,
              totalCtrl: _mTotCtrl,
              kelipatan: widget.kelipatan,
              editAwalMode: _editAwalMode,
              onAwalChanged: (v) => _onAwalChanged('m', v, _mTotCtrl),
              onAkhirChanged: (v) => _onAkhirChanged('m', v, _mTotCtrl),
              onTotalChanged: (v) => _onTotChanged('m', v, _mAkhirCtrl),
              onAdd: () =>
                  _addTot('m', widget.kelipatan, _mTotCtrl, _mAkhirCtrl),
              onSubtract: () =>
                  _addTot('m', -widget.kelipatan, _mTotCtrl, _mAkhirCtrl),
            ),

            const SizedBox(height: 4),

            // Bottom Action Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final newVal = isLulus ? 'Ulang' : 'Lulus';
                      widget.onChanged('z_status', newVal);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 32,
                      decoration: BoxDecoration(
                        color: isLulus
                            ? Colors.green.withValues(alpha: 0.12)
                            : (isDark
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.red.shade50),
                        border: Border.all(
                          color: isLulus
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLulus
                                ? Icons.check_rounded
                                : Icons.refresh_rounded,
                            color: isLulus ? Colors.green : Colors.red.shade500,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isLulus ? 'Lulus' : 'Ulang',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLulus
                                    ? Colors.green
                                    : Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showCatatanDialog(context, r);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            (r['catatan'] != null &&
                                r['catatan'].toString().isNotEmpty)
                            ? Colors.blue.shade600
                            : Theme.of(context).cardColor,
                        border: Border.all(
                          color:
                              (r['catatan'] != null &&
                                  r['catatan'].toString().isNotEmpty)
                              ? Colors.blue.shade800
                              : Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            color:
                                (r['catatan'] != null &&
                                    r['catatan'].toString().isNotEmpty)
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Catatan',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    (r['catatan'] != null &&
                                        r['catatan'].toString().isNotEmpty)
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final disimak = r['disimak']?.toString() == '1';
                      widget.onChanged('disimak', disimak ? '0' : '1');
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: r['disimak']?.toString() == '1'
                            ? primaryColor.withValues(alpha: 0.12)
                            : Theme.of(context).cardColor,
                        border: Border.all(
                          color: r['disimak']?.toString() == '1'
                              ? primaryColor
                              : Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            r['disimak']?.toString() == '1'
                                ? Icons.library_books_rounded
                                : Icons.book_outlined,
                            color: r['disimak']?.toString() == '1'
                                ? primaryColor
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              r['disimak']?.toString() == '1'
                                  ? 'Disimak'
                                  : 'Tdk Disimak',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: r['disimak']?.toString() == '1'
                                    ? primaryColor
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
