enum TahsinValidationStatus {
  valid,
  melebihiCheckpoint,
  melebihiTotalBuku,
  invalidHalaman,
}

class TahsinValidator {
  static TahsinValidationStatus validateHalaman({
    required double halAwal,
    required double halTotalInput,
    required double totalHalKelas,
    required bool isSelesaiBuku,
    required double? checkpointTarget,
    required String modeBelajar,
  }) {
    final double halAkhir = halAwal + halTotalInput;

    if (halTotalInput <= 0) return TahsinValidationStatus.invalidHalaman;

    // Jika kelas tidak memiliki total_hal, tidak ada batas
    if (totalHalKelas <= 0) return TahsinValidationStatus.valid;

    // Cek batas Checkpoint jika belum selesai buku dan BUKAN akselerasi
    if (modeBelajar != 'akselerasi' && !isSelesaiBuku && checkpointTarget != null && checkpointTarget > 0) {
      if (halAkhir > checkpointTarget) {
        return TahsinValidationStatus.melebihiCheckpoint;
      }
    }

    // Cek batas Maksimal Buku
    if (halAkhir > totalHalKelas) {
      return TahsinValidationStatus.melebihiTotalBuku;
    }

    return TahsinValidationStatus.valid;
  }

  static String getErrorMessage(TahsinValidationStatus status, {double? maxAllowed}) {
    switch (status) {
      case TahsinValidationStatus.melebihiCheckpoint:
        return 'Gagal: Halaman melebihi batas Checkpoint Ujian.${maxAllowed != null ? ' Maksimal input: $maxAllowed halaman.' : ''}';
      case TahsinValidationStatus.melebihiTotalBuku:
        return 'Gagal: Halaman melebihi target maksimal kelas.${maxAllowed != null ? ' Maksimal input: $maxAllowed halaman.' : ''}';
      case TahsinValidationStatus.invalidHalaman:
        return 'Halaman total tidak boleh 0 atau negatif.';
      case TahsinValidationStatus.valid:
      default:
        return '';
    }
  }
}
