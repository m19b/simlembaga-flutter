import 'package:flutter/material.dart';

class RowStateModel {
  final Map<String, dynamic> santri;
  double halAwal;
  final int jmlTes;
  final Map<String, dynamic>? nextCheckpoint;
  String modeBelajar; // 'reguler' | 'latihan' | 'akselerasi'

  double halTotal = 0;
  int jmlKehadiran = 1;
  bool lulus = true;
  bool disimak = true;
  String catatanGuru = '';

  final TextEditingController halCtrl = TextEditingController();
  final TextEditingController tmCtrl = TextEditingController(text: '1');

  RowStateModel({
    required this.santri,
    required this.halAwal,
    required this.jmlTes,
    required this.modeBelajar,
    this.nextCheckpoint,
  }) {
    final double capaiHal =
        double.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
    final double cpTarget = nextCheckpoint != null
        ? (double.tryParse(
                nextCheckpoint!['halaman_target']?.toString() ?? '0',
              ) ??
              0)
        : 0.0;
    final double totalHal =
        double.tryParse(santri['total_hal']?.toString() ?? '0') ?? 0;

    final bool isFinishedReg = (totalHal > 0 && capaiHal >= totalHal);
    final double currentLimit = isFinishedReg
        ? totalHal
        : (cpTarget > 0 ? cpTarget : totalHal);
    final bool latihanSelesai =
        (santri['lat_sek'] != null &&
        double.tryParse(santri['lat_sek'].toString()) != null &&
        double.tryParse(santri['lat_sek'].toString())! >= currentLimit &&
        currentLimit > 0);
    final bool aksSelesai =
        (totalHal > 0 &&
        (double.tryParse(santri['capai_aks']?.toString() ?? '0') ?? 0) >=
            totalHal);

    bool isTerkunci = false;
    // Akselerasi hanya dikunci jika benar-benar SUDAH SELESAI (capai_aks >= total_hal)
    // jmlTes > 0 hanya berarti santri ini punya kegagalan tes, BUKAN berarti selesai
    if (modeBelajar == 'akselerasi') {
      if (aksSelesai) isTerkunci = true;
    } else if (modeBelajar == 'latihan') {
      if (latihanSelesai) isTerkunci = true;
    }

    // Siap Test flag (reguler mode saja):
    final bool isAtCP =
        (!isFinishedReg && cpTarget > 0 && capaiHal >= cpTarget);
    if (isAtCP && modeBelajar == 'reguler') isTerkunci = true;

    halTotal = isTerkunci ? 0.0 : 1.0;
    halCtrl.text = halTotal == halTotal.toInt()
        ? halTotal.toInt().toString()
        : halTotal.toString();
  }

  void setModeOverride(String newMode) {
    modeBelajar = newMode;
    
    final String lastMode = santri['last_mode']?.toString() ?? '';
    final String lastStatus = santri['last_status']?.toString() ?? '';
    final double lastHalAkhir = double.tryParse(santri['last_hal_akhir']?.toString() ?? '0') ?? 0;
    
    if (newMode == lastMode && lastHalAkhir > 0) {
        final double lastHalTotal = double.tryParse(santri['last_hal_total']?.toString() ?? '0') ?? 0;
        halAwal = lastStatus.toLowerCase() == 'lulus' ? lastHalAkhir : (lastHalAkhir - lastHalTotal);
    } else {
        if (newMode == 'akselerasi') {
          halAwal = double.tryParse(santri['capai_aks']?.toString() ?? '0') ?? 0;
        } else if (newMode == 'latihan') {
          halAwal = double.tryParse(santri['lat_sek']?.toString() ?? '0') ?? 0;
        } else {
          halAwal = double.tryParse(santri['capai_hal']?.toString() ?? '0') ?? 0;
        }
    }
    
    // Setel default form
    halTotal = 1.0;
    halCtrl.text = '1';
  }

  Map<String, dynamic> toPayload() => {
    'nis': santri['nis'],
    'id_kelas': santri['id_kelas'],
    'id_kelompok': santri['id_kelompok'],
    'hal_awal': halAwal,
    'hal_total': halTotal,
    'jml_kehadiran': jmlKehadiran,
    'jml_tes': jmlTes,
    'mode_belajar': modeBelajar,
    'lulus': lulus ? '1' : '0',
    'disimak': disimak ? '1' : '0',
    'catatan_guru': catatanGuru,
  };

  void dispose() {
    halCtrl.dispose();
    tmCtrl.dispose();
  }
}

// --- Screen -------------------------------------------------------------------