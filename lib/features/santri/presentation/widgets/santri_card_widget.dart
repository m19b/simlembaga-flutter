import 'package:flutter/material.dart';

const Color _kAccent = Color(0xFF16A34A);

class SantriCardWidget extends StatelessWidget {
  final Map<String, dynamic> santri;
  final int index;
  final VoidCallback onTap;
  const SantriCardWidget({
    required this.santri,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nama = santri['nama_santri']?.toString() ?? '-';
    final panggilan = santri['nama_panggilan']?.toString() ?? '';
    final nis = santri['nis']?.toString() ?? '-';
    final jk = santri['jenis_kelamin']?.toString() ?? '-';
    final kelas = santri['kelas']?.toString() ?? '-';
    final tglLahir = santri['tanggal_lahir']?.toString() ?? '';

    final isL = jk == 'Laki-laki';

    String tglFormatted = '-';
    if (tglLahir.isNotEmpty) {
      final parts = tglLahir.split('-');
      if (parts.length == 3) {
        final bln = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agt',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        final m = int.tryParse(parts[1]) ?? 0;
        tglFormatted =
            '${parts[2]} ${m > 0 && m < 13 ? bln[m] : parts[1]} ${parts[0]}';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$index',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: _kAccent.withValues(alpha: 0.1),
                child: Text(
                  nama[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _kAccent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nama,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (panggilan.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '($panggilan)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          nis,
                          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isL
                                ? Colors.blue.shade50
                                : Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isL ? 'L' : 'P',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isL ? Colors.blue : Colors.pink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            kelas,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.cake_outlined,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tglFormatted,
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}