import 'package:hijri/hijri_calendar.dart';
void main() {
  HijriCalendar.setLocal('ar'); // maybe id isn't supported, try default or ar
  var today = HijriCalendar.now();
  print('${today.hDay} ${today.longMonthName} ${today.hYear} H');
}
