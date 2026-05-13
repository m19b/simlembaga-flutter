import 'package:flutter/material.dart';
import 'row_state_model.dart';
import 'evaluasi_input_row.dart';

class EvaluasiSantriCard extends StatefulWidget {
  final RowStateModel row;
  final int index;
  final bool isDecimalMode;
  final void Function(RowStateModel, StateSetter) onShowCatatan;

  const EvaluasiSantriCard({
    Key? key,
    required this.row,
    required this.index,
    required this.isDecimalMode,
    required this.onShowCatatan,
  }) : super(key: key);

  @override
  State<EvaluasiSantriCard> createState() => _EvaluasiSantriCardState();
}

class _EvaluasiSantriCardState extends State<EvaluasiSantriCard> {
  void _setRow(VoidCallback fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final idx = widget.index;
    final s = row.santri;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nama = s['nama_santri']?.toString() ?? '-';
    final nis = s['nis']?.toString() ?? '-';
    final kelas = s['kelas']?.toString() ?? '-';

    final double capaiHal = double.tryParse(s['capai_hal']?.toString() ?? '0') ?? 0;
    final int jmlTes = row.jmlTes;

    final String modeBelajar = row.modeBelajar;
    final nextCP = row.nextCheckpoint;
    final double cpTarget = nextCP != null
        ? (double.tryParse(nextCP['halaman_target']?.toString() ?? '0') ?? 0)
        : 0.0;

    String modeText = 'REGULER';
    Color modeColor = Colors.deepPurple;
    Color modeBg = isDark ? Colors.deepPurple.withOpacity(0.2) : Colors.deepPurple.shade50;

    final double totalHal = double.tryParse(s['total_hal']?.toString() ?? '0') ?? 0;
    final bool isFinishedReg = (totalHal > 0 && capaiHal >= totalHal);
    final double currentLimit = isFinishedReg ? totalHal : (cpTarget > 0 ? cpTarget : totalHal);
    final bool isAtCP = (!isFinishedReg && cpTarget > 0 && capaiHal >= cpTarget);
    final bool latihanSelesai = (row.santri['lat_sek'] != null &&
        double.tryParse(row.santri['lat_sek'].toString()) != null &&
        double.tryParse(row.santri['lat_sek'].toString())! >= currentLimit &&
        currentLimit > 0);
    final bool aksSelesai = (totalHal > 0 &&
        (double.tryParse(row.santri['capai_aks']?.toString() ?? '0') ?? 0) >= totalHal);

    bool isTerkunci = false;

    final bool isAkselerasiSantri = (jmlTes > 0) ||
        (double.tryParse((s['capai_aks'] ?? s['capaiAks'])?.toString() ?? '0') ?? 0) > 0 ||
        s['last_mode'] == 'akselerasi';

    if (modeBelajar == 'akselerasi') {
      modeText = jmlTes > 0 ? 'AKSELERASI $jmlTes✕' : 'AKSELERASI';
      modeColor = isDark ? Colors.red.shade400 : Colors.red.shade700;
      modeBg = isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50;
      if (aksSelesai) {
        isTerkunci = true;
      }
    } else if (modeBelajar == 'latihan') {
      modeText = isAtCP ? 'LATIHAN (CHKP)' : 'LATIHAN';
      modeColor = isAtCP ? (isDark ? Colors.orange.shade400 : Colors.orange.shade800) : (isDark ? Colors.teal.shade400 : Colors.teal);
      modeBg = isAtCP ? (isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50) : (isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50);
      if (latihanSelesai) {
        isTerkunci = true;
      }
    }

    final int jmlGagal = int.tryParse(s['jml_gagal_berturut']?.toString() ?? '0') ?? 0;
    final bool isRiwayatUlang = jmlGagal >= 2;

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isTerkunci ? Colors.green.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isRiwayatUlang
            ? Border.all(color: Colors.orange.shade300, width: 1.5)
            : (isTerkunci ? Border.all(color: Colors.green.shade200) : Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: isRiwayatUlang
                ? Colors.orange.withOpacity(0.12)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRiwayatUlang)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 13, color: isDark ? Colors.orange.shade400 : Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '$jmlGagal× Tidak Lulus Berturut-turut',
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.orange.shade300 : Colors.orange.shade800, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${idx + 1}', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(nis, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: isDark ? Colors.indigo.withOpacity(0.2) : Colors.indigo.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Text(kelas, style: TextStyle(fontSize: 9, color: isDark ? Colors.indigo.shade300 : Colors.indigo, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      enabled: !isTerkunci,
                      initialValue: modeBelajar,
                      onSelected: (newMode) => _setRow(() => row.setModeOverride(newMode)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isTerkunci ? Theme.of(context).dividerColor : modeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isTerkunci ? Colors.grey.shade400 : modeColor.withOpacity(0.2)),
                        ),
                        child: Text(modeText, style: TextStyle(fontSize: 10, color: isTerkunci ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : modeColor, fontWeight: FontWeight.bold)),
                      ),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'reguler', child: Text('Reguler', style: TextStyle(fontSize: 12))),
                        const PopupMenuItem(value: 'latihan', child: Text('Latihan', style: TextStyle(fontSize: 12))),
                        if (isAkselerasiSantri)
                          const PopupMenuItem(value: 'akselerasi', child: Text('Akselerasi', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                EvaluasiInputRow(
                  disabled: isTerkunci,
                  awal: row.halAwal,
                  jumlah: row.halTotal,
                  akhir: row.halAwal + row.halTotal,
                  tm: row.jmlKehadiran,
                  progressController: row.halCtrl,
                  tmController: row.tmCtrl,
                  onDecrementProgress: () => _setRow(() {
                    if (row.halTotal > 0) {
                      final step = widget.isDecimalMode ? 0.5 : 1.0;
                      row.halTotal = (row.halTotal - step).clamp(0.0, 999.0);
                      row.halCtrl.text = row.halTotal == row.halTotal.toInt() ? row.halTotal.toInt().toString() : row.halTotal.toString();
                    }
                  }),
                  onIncrementProgress: () => _setRow(() {
                    final step = widget.isDecimalMode ? 0.5 : 1.0;
                    row.halTotal += step;
                    row.halCtrl.text = row.halTotal == row.halTotal.toInt() ? row.halTotal.toInt().toString() : row.halTotal.toString();
                  }),
                  onDecrementTm: () => _setRow(() {
                    if (row.jmlKehadiran > 1) {
                      row.jmlKehadiran--;
                      row.tmCtrl.text = row.jmlKehadiran.toString();
                    }
                  }),
                  onIncrementTm: () => _setRow(() {
                    row.jmlKehadiran++;
                    row.tmCtrl.text = row.jmlKehadiran.toString();
                  }),
                  onProgressChanged: (val) {
                    final p = double.tryParse(val);
                    if (p != null) _setRow(() => row.halTotal = p);
                  },
                  onTmChanged: (val) {
                    final p = int.tryParse(val);
                    if (p != null && p >= 1) _setRow(() => row.jmlKehadiran = p);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: isTerkunci ? null : () => _setRow(() => row.lulus = !row.lulus),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 44,
                          decoration: BoxDecoration(
                            color: isTerkunci ? (isDark ? const Color(0xFF374151) : Colors.grey.shade100) : (row.lulus ? Colors.green.withOpacity(0.12) : (isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50)),
                            border: Border.all(color: isTerkunci ? Theme.of(context).dividerColor : (row.lulus ? Colors.green : Colors.red.shade400), width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(row.lulus ? Icons.check_rounded : Icons.refresh_rounded, color: isTerkunci ? Colors.grey.shade400 : (row.lulus ? Colors.green : Colors.red.shade500), size: 18),
                              const SizedBox(width: 4),
                              Text(row.lulus ? 'Lulus' : 'Ulang', style: TextStyle(color: isTerkunci ? Colors.grey.shade400 : (row.lulus ? Colors.green : Colors.red.shade600), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: isTerkunci ? null : () => widget.onShowCatatan(row, _setRow),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 44,
                          decoration: BoxDecoration(
                            color: isTerkunci ? (isDark ? const Color(0xFF374151) : Colors.grey.shade100) : (row.catatanGuru.isNotEmpty ? Colors.blue.shade600 : Theme.of(context).cardColor),
                            border: Border.all(color: isTerkunci ? Theme.of(context).dividerColor : (row.catatanGuru.isNotEmpty ? Colors.blue.shade600 : Theme.of(context).dividerColor)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notes_rounded, color: isTerkunci ? Colors.grey.shade400 : (row.catatanGuru.isNotEmpty ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), size: 18),
                              const SizedBox(width: 4),
                              Text('Catatan', style: TextStyle(color: isTerkunci ? Colors.grey.shade400 : (row.catatanGuru.isNotEmpty ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: isTerkunci ? null : () => _setRow(() => row.disimak = !row.disimak),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 44,
                          decoration: BoxDecoration(
                            color: isTerkunci ? (isDark ? const Color(0xFF374151) : Colors.grey.shade100) : (row.disimak ? primaryColor.withOpacity(0.12) : Theme.of(context).cardColor),
                            border: Border.all(color: isTerkunci ? Theme.of(context).dividerColor : (row.disimak ? primaryColor : Theme.of(context).dividerColor)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(row.disimak ? Icons.library_books_rounded : Icons.book_outlined, color: isTerkunci ? Colors.grey.shade400 : (row.disimak ? primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), size: 18),
                              const SizedBox(width: 4),
                              Text(row.disimak ? 'Disimak' : 'Tdk Disimak', style: TextStyle(color: isTerkunci ? Colors.grey.shade400 : (row.disimak ? primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isTerkunci) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.green.shade700 : Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 16, color: isDark ? Colors.green.shade400 : Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(child: Text('🎯 Target tercapai — Siap Tes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.green.shade300 : Colors.green.shade800))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
