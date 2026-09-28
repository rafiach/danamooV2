import 'package:flutter/material.dart';
import '../constants/constant.dart';
import '../widgets/custom_button.dart';

class TimePickerSheet {
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? title,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimePickerSheetContent(
        initialTime: initialTime,
        title: title ?? 'Pilih Waktu',
      ),
    );
  }
}

class _TimePickerSheetContent extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;

  const _TimePickerSheetContent({
    required this.initialTime,
    required this.title,
  });

  @override
  State<_TimePickerSheetContent> createState() =>
      _TimePickerSheetContentState();
}

class _TimePickerSheetContentState extends State<_TimePickerSheetContent> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
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
                      color: Constant.limeAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: _TimeSelectorColumn(
                    label: 'JAM',
                    selectedValue: _selectedHour,
                    maxValue: 23,
                    onChanged: (value) => setState(() => _selectedHour = value),
                    formatter: (v) => v.toString().padLeft(2, '0'),
                  ),
                ),
                Container(
                  width: 1,
                  color: Constant.borderSubtle,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                ),
                Expanded(
                  child: _TimeSelectorColumn(
                    label: 'MENIT',
                    selectedValue: _selectedMinute,
                    maxValue: 59,
                    step: 5,
                    onChanged: (value) =>
                        setState(() => _selectedMinute = value),
                    formatter: (v) => v.toString().padLeft(2, '0'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton.mainButton(
              label: 'OK',
              onPressed: () => Navigator.pop(
                context,
                TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
              ),
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

class _TimeSelectorColumn extends StatefulWidget {
  final String label;
  final int selectedValue;
  final int maxValue;
  final int step;
  final ValueChanged<int> onChanged;
  final String Function(int) formatter;

  const _TimeSelectorColumn({
    required this.label,
    required this.selectedValue,
    required this.maxValue,
    required this.onChanged,
    required this.formatter,
    this.step = 1,
  });

  @override
  State<_TimeSelectorColumn> createState() => _TimeSelectorColumnState();
}

class _TimeSelectorColumnState extends State<_TimeSelectorColumn> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();

    final initialIndex = widget.selectedValue ~/ widget.step;

    _controller = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = List.generate(
      (widget.maxValue ~/ widget.step) + 1,
      (i) => i * widget.step,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: Constant.captionBold.copyWith(color: Constant.textSecondary),
          ),
        ),

        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 56,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            magnification: 1.2,
            overAndUnderCenterOpacity: 0.3,
            useMagnifier: true,

            onSelectedItemChanged: (index) {
              if (index >= 0 && index < values.length) {
                widget.onChanged(values[index]);
              }
            },

            childDelegate: ListWheelChildBuilderDelegate(
              childCount: values.length,
              builder: (context, index) {
                final value = values[index];
                final isSelected = value == widget.selectedValue;

                return Center(
                  child: Text(
                    widget.formatter(value),
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 22,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Constant.limeAccent
                          : Constant.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
