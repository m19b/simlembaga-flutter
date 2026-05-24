import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TahfidzHeaderWidget extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;
  final String tglUpdateCache;
  final DateTime tanggal;
  final int? selectedKelasId;
  final List<dynamic> kelasList;
  final int? selectedSesi;
  final List<dynamic> jadwalList;
  final String selectedStatusAbsen;
  final TextEditingController kelipatanCtrl;

  final VoidCallback onUrutkanTap;
  final VoidCallback onTanggalTap;
  final ValueChanged<int?> onKelasChanged;
  final ValueChanged<int?> onSesiChanged;
  final ValueChanged<bool> onStatusAbsenChanged;
  final ValueChanged<String> onKelipatanChanged;

  const TahfidzHeaderWidget({
    super.key,
    required this.isDark,
    required this.primaryColor,
    required this.tglUpdateCache,
    required this.tanggal,
    required this.selectedKelasId,
    required this.kelasList,
    required this.selectedSesi,
    required this.jadwalList,
    required this.selectedStatusAbsen,
    required this.kelipatanCtrl,
    required this.onUrutkanTap,
    required this.onTanggalTap,
    required this.onKelasChanged,
    required this.onSesiChanged,
    required this.onStatusAbsenChanged,
    required this.onKelipatanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.95)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onUrutkanTap,
                child: Row(
                  children: [
                    Icon(Icons.sort_rounded, size: 16, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'Urutkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Sync: $tglUpdateCache',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primaryColor.withValues(alpha: 0.8),
                ),
              ),
              GestureDetector(
                onTap: onTanggalTap,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('d MMM yyyy', 'id_ID').format(tanggal),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedKelasId,
                      isDense: true,
                      isExpanded: true,
                      hint: const Text('Kelas', style: TextStyle(fontSize: 10)),
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onChanged: onKelasChanged,
                      items: () {
                        final seen = <int?>{};
                        return kelasList
                            .map((k) {
                              final id = int.tryParse(k['id_kelas']?.toString() ?? '');
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(k['tingkat']?.toString() ?? '-'),
                              );
                            })
                            .where((item) {
                              if (item.value == null || seen.contains(item.value)) {
                                return false;
                              }
                              seen.add(item.value);
                              return true;
                            })
                            .toList();
                      }(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 4,
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: jadwalList.isNotEmpty
                      ? DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedSesi,
                            isExpanded: true,
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down, size: 16, color: primaryColor),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            onChanged: onSesiChanged,
                            items: () {
                              final seen = <int>{};
                              return jadwalList
                                  .map((j) {
                                    final sj = j['sesi'] as int;
                                    final h = (j['hari'] ?? '').toString();
                                    String hariStr = h;
                                    if (h == '1') {
                                      hariStr = 'Sen';
                                    } else if (h == '2') {
                                      hariStr = 'Sel';
                                    } else if (h == '3') {
                                      hariStr = 'Rab';
                                    } else if (h == '4') {
                                      hariStr = 'Kam';
                                    } else if (h == '5') {
                                      hariStr = 'Jum';
                                    } else if (h == '6') {
                                      hariStr = 'Sab';
                                    } else if (h == '7') {
                                      hariStr = 'Min';
                                    } else if (j['nama_hari'] != null) {
                                      hariStr = j['nama_hari'].toString().substring(0, 3);
                                    }
                                    
                                    final s = sj.toString();
                                    String sesiStr = 'Sesi $s';
                                    if (s == '1') {
                                      sesiStr = 'Pagi';
                                    } else if (s == '2') {
                                      sesiStr = 'Siang';
                                    } else if (s == '3') {
                                      sesiStr = 'Sore';
                                    } else if (s == '4') {
                                      sesiStr = 'Malam';
                                    }
                                    
                                    return DropdownMenuItem<int>(
                                      value: sj,
                                      child: Text(
                                        '$hariStr - $sesiStr',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  })
                                  .where((item) {
                                    if (item.value == null || seen.contains(item.value)) {
                                      return false;
                                    }
                                    seen.add(item.value!);
                                    return true;
                                  })
                                  .toList();
                            }(),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: primaryColor.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Belum ada',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor.withValues(alpha: 0.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hadir', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Transform.scale(
                    scale: 0.6,
                    child: Switch(
                      value: selectedStatusAbsen == 'hanya_hadir',
                      onChanged: onStatusAbsenChanged,
                      activeTrackColor: primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Center(
                  child: TextFormField(
                    controller: kelipatanCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    onChanged: onKelipatanChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
