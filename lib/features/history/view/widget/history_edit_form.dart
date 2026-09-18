import 'package:danamoo/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/date_picker_sheet.dart';
import '../../../../core/widgets/segmented_control.dart';
import '../../../../data/models/transaction_model.dart';

class HistoryEditForm extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final DateTime selectedDate;
  final TransactionType selectedType;
  final CategoryModel? selectedCategory;
  final List<CategoryModel> categories;
  final String currency;

  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<CategoryModel?> onCategoryChanged;

  const HistoryEditForm({
    super.key,
    required this.amountController,
    required this.noteController,
    required this.selectedDate,
    required this.selectedType,
    required this.selectedCategory,
    required this.categories,
    required this.currency,
    required this.onDateChanged,
    required this.onTypeChanged,
    required this.onCategoryChanged,
  });

  bool get _isExpense => selectedType == TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final expenseCategories = categories
        .where((cat) => cat.type == TransactionType.expense)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type Toggle
        SegmentedControl(
          labels: const ['Pemasukan', 'Pengeluaran'],
          selectedIndex: _isExpense ? 1 : 0,
          onChanged: (index) => onTypeChanged(
            index == 0 ? TransactionType.income : TransactionType.expense,
          ),
          borderRadius: 24,
          height: 50,
        ),
        const SizedBox(height: 24),

        // Amount Field
        _SectionLabel('NOMINAL'),
        const SizedBox(height: 8),
        CustomTextField.standard(
          controller: amountController,
          keyboardType: TextInputType.number,
          prefixText: '$currency  ',
          hint: '0',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyInputFormatter(),
          ],
        ),
        const SizedBox(height: 24),

        // Category (Expense only)
        if (_isExpense) ...[
          _SectionLabel('KATEGORI'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: expenseCategories.map((cat) {
              final isSelected = selectedCategory?.id == cat.id;
              return _CategoryChip(
                category: cat,
                isSelected: isSelected,
                onTap: () => onCategoryChanged(cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Description
        _SectionLabel('DESKRIPSI'),
        const SizedBox(height: 8),
        CustomTextField.standard(
          controller: noteController,
          hint: 'Catatan transaksi',
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // Date Field
        _SectionLabel('TANGGAL'),
        const SizedBox(height: 8),
        _DateField(selectedDate: selectedDate, onDateChanged: onDateChanged),
      ],
    );
  }
}

// ===== SUB WIDGETS =====

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Constant.textSemiBold.copyWith(
        color: Constant.textPrimary,
        fontSize: 14,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Constant.durationShort,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Constant.limeAccentDark.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Constant.limeAccentDark : Constant.borderSubtle,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            category.icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? Constant.textPrimary
                      : Constant.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateField({required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await DatePickerSheet.show(
          context: context,
          initialDate: selectedDate,
          title: 'Pilih Tanggal',
        );
        if (picked != null) onDateChanged(picked);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Constant.surfaceCard,
          border: Border.all(color: Constant.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Constant.limeAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Utils.formatDate(selectedDate),
                style: Constant.bodyMedium.copyWith(
                  color: Constant.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== FORMATTER RUPIAH =====
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return const TextEditingValue(text: '');

    final intValue = int.parse(numericString);
    final formatted = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
