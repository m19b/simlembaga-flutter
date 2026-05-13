import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final bool isCompact;
  final bool isWhite;

  const CustomDateField({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isCompact = false,
    this.isWhite = false,
  }) : super(key: key);

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100), // Allowing future dates as needed
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

    if (date != null) {
      onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dfDisplay = DateFormat('dd MMM yyyy', 'id_ID');
    final String textToShow = selectedDate != null
        ? (isCompact
            ? DateFormat('dd/MM/yy').format(selectedDate!)
            : dfDisplay.format(selectedDate!))
        : 'Pilih Tanggal';

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(isCompact ? 20 : 12),
      child: Container(
        margin: isCompact ? const EdgeInsets.only(right: 8) : EdgeInsets.zero,
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isWhite ? Colors.white.withOpacity(0.15) : null,
          border: isCompact ? null : Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(isCompact ? 20 : 12),
        ),
        child: Row(
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.calendar_month,
              size: isCompact ? 14 : 18,
              color: isWhite ? Colors.white : const Color(0xFF0F4C2A),
            ),
            SizedBox(width: isCompact ? 6 : 12),
            if (!isCompact)
              Expanded(
                child: Text(
                  textToShow,
                  style: TextStyle(
                    fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                    color: selectedDate != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.grey,
                  ),
                ),
              )
            else
              Text(
                textToShow,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isWhite ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            if (!isCompact) ...[
              const Icon(Icons.edit, size: 16, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }
}
