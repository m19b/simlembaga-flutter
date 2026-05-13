import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateRangeField extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTimeRange?) onDateRangeSelected;

  const CustomDateRangeField({
    Key? key,
    required this.selectedRange,
    required this.onDateRangeSelected,
  }) : super(key: key);

  Future<void> _pickRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0F4C2A), // Emerald/Green theme
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              headerBackgroundColor: const Color(0xFF0F4C2A),
              headerForegroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      onDateRangeSelected(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dfDisplay = DateFormat('dd MMM yy', 'id_ID');
    final String textToShow = selectedRange != null
        ? '${dfDisplay.format(selectedRange!.start)} - ${dfDisplay.format(selectedRange!.end)}'
        : 'Pilih Rentang Tanggal';

    return InkWell(
      onTap: () => _pickRange(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF0F4C2A)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                textToShow,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selectedRange != null ? FontWeight.bold : FontWeight.w500,
                  color: selectedRange != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
