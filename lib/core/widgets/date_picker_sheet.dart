import 'package:flutter/material.dart';
import '../constants/constant.dart';
import '../widgets/custom_button.dart';

class DatePickerSheet {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DatePickerSheetContent(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
        title: title ?? 'Pilih Tanggal',
      ),
    );
  }
}

class _DatePickerSheetContent extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const _DatePickerSheetContent({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  @override
  State<_DatePickerSheetContent> createState() =>
      _DatePickerSheetContentState();
}

class _DatePickerSheetContentState extends State<_DatePickerSheetContent> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Constant.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Constant.greyMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Constant.h6.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: Constant.textMedium.copyWith(
                      color: Constant.expenseRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
              currentDate: DateTime.now(),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton.mainButton(
              label: 'OK',
              color: Constant.limeAccentDark,
              textColor: Constant.textPrimary,
              onPressed: () => Navigator.pop(context, _selectedDate),
              height: 52,
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
