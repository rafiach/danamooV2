import 'package:danamoo/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/category_chip.dart';
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
            CurrencyInputFormatter(),
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
              return CategoryChip(
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
