import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';

class DashboardHijriCard extends StatefulWidget {
  final DashboardModel data;
  final DateTime currentTime;

  const DashboardHijriCard({
    super.key,
    required this.data,
    required this.currentTime,
  });

  @override
  State<DashboardHijriCard> createState() => _DashboardHijriCardState();
}

class _DashboardHijriCardState extends State<DashboardHijriCard> {
  final List<String> _hijriMonths = [
    'Muharram',
    'Safar',
    'Rabi\'ul Awal',
    'Rabi\'ul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  dynamic _getNextSchedule(List<dynamic> jadwalGuru) {
    if (jadwalGuru.isEmpty) return null;
    int currentDay = widget.currentTime.weekday;

    var todaySchedules = jadwalGuru
        .where(
          (j) =>
              (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) == currentDay,
        )
        .toList();
    if (todaySchedules.isNotEmpty) {
      String currentTimeStr =
          "${widget.currentTime.hour.toString().padLeft(2, '0')}:${widget.currentTime.minute.toString().padLeft(2, '0')}:${widget.currentTime.second.toString().padLeft(2, '0')}";
      var upcomingToday = todaySchedules
          .where(
            (j) =>
                (j['jam_pulang']?.toString() ?? '23:59:59').compareTo(
                  currentTimeStr,
                ) >=
                0,
          )
          .toList();
      if (upcomingToday.isNotEmpty) {
        // Sort by jam masuk
        upcomingToday.sort(
          (a, b) => (a['jam_masuk']?.toString() ?? '').compareTo(
            b['jam_masuk']?.toString() ?? '',
          ),
        );
        return upcomingToday.first;
      }
    }

    var nextSchedules = jadwalGuru
        .where(
          (j) => (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) > currentDay,
        )
        .toList();
    if (nextSchedules.isNotEmpty) {
      nextSchedules.sort((a, b) {
        int cmp = (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo(
          (int.tryParse(b['hari']?.toString() ?? '0') ?? 0),
        );
        if (cmp != 0) return cmp;
        return (a['jam_masuk']?.toString() ?? '').compareTo(
          b['jam_masuk']?.toString() ?? '',
        );
      });
      return nextSchedules.first;
    }

    var allSorted = List.from(jadwalGuru);
    allSorted.sort((a, b) {
      int cmp = (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo(
        (int.tryParse(b['hari']?.toString() ?? '0') ?? 0),
      );
      if (cmp != 0) return cmp;
      return (a['jam_masuk']?.toString() ?? '').compareTo(
        b['jam_masuk']?.toString() ?? '',
      );
    });
    if (allSorted.isNotEmpty) return allSorted.first;
    return null;
  }

  String _getCountdownText(dynamic schedule) {
    if (schedule == null) return 'Tidak ada jadwal';

    int targetHari = int.tryParse(schedule['hari']?.toString() ?? '0') ?? 0;
    String jamMasuk = schedule['jam_masuk']?.toString() ?? '00:00:00';
    List<String> parts = jamMasuk.split(':');
    int h = int.tryParse(parts[0]) ?? 0;
    int m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    int s = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;

    int daysToAdd = (targetHari - widget.currentTime.weekday) % 7;
    if (daysToAdd < 0) daysToAdd += 7;

    DateTime targetDate = DateTime(
      widget.currentTime.year,
      widget.currentTime.month,
      widget.currentTime.day,
      h,
      m,
      s,
    ).add(Duration(days: daysToAdd));

    // If it's today but the start time has passed (meaning we are inside the class schedule since _getNextSchedule filters by jam_pulang)
    if (daysToAdd == 0 && targetDate.isBefore(widget.currentTime)) {
      return 'Sedang Berlangsung';
    }

    // If targetDate is somehow in the past but it shouldn't be based on daysToAdd, fix it for next week
    if (targetDate.isBefore(widget.currentTime)) {
      targetDate = targetDate.add(const Duration(days: 7));
    }

    Duration diff = targetDate.difference(widget.currentTime);

    int d = diff.inDays;
    int hr = diff.inHours % 24;
    int min = diff.inMinutes % 60;
    int sec = diff.inSeconds % 60;

    if (d > 0) {
      return 'Mulai: ${d}h ${hr}j ${min}m';
    } else {
      return 'Mulai: ${hr}j ${min}m ${sec}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get Hijri Date
    var today = HijriCalendar.fromDate(widget.currentTime);
    String hijriStr =
        '${today.hDay} ${_hijriMonths[today.hMonth - 1]} ${today.hYear} H';

    // Get Schedule
    var nextSchedule = _getNextSchedule(widget.data.jadwalGuru);
    String countdownStr = _getCountdownText(nextSchedule);

    bool isOngoing = countdownStr == 'Sedang Berlangsung';

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date section (Masehi & Hijri)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, d MMM yyyy', 'id_ID').format(widget.currentTime),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.brightness_3,
                      color: Colors.green.shade700,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hijriStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Countdown section
          if (nextSchedule != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOngoing
                    ? Colors.green.withOpacity(0.15)
                    : Colors.blue.shade50.withOpacity(isDark ? 0.1 : 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isOngoing ? Icons.play_arrow_rounded : Icons.timer_outlined,
                    color: isOngoing
                        ? Colors.green.shade600
                        : Colors.blue.shade600,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    countdownStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOngoing
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
