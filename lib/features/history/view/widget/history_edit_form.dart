import 'package:danamoo/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== TOGGLE INCOME / EXPENSE =====
        _TypeToggle(activeType: selectedType, onChanged: onTypeChanged),
        const SizedBox(height: 24),

        // ===== AMOUNT =====
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
        const SizedBox(height: 20),

        // ===== CATEGORY (hanya expense) =====
        if (_isExpense) ...[
          _SectionLabel('CATEGORY'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = selectedCategory?.id == cat.id;
              return _CategoryChip(
                category: cat,
                isSelected: isSelected,
                onTap: () => onCategoryChanged(cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // ===== DESCRIPTION =====
        _SectionLabel('DESCRIPTION'),
        const SizedBox(height: 12),
        CustomTextField.standard(
          controller: noteController,
          hint: 'Describe your transaction',
          maxLines: 5,
        ),
        const SizedBox(height: 20),

        // ===== DATE =====
        _SectionLabel('DATE'),
        const SizedBox(height: 12),
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
      style: Constant.bodyLarge.copyWith(
        color: Constant.violetDarker,
        fontWeight: FontWeight.bold,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? category.color : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(category.icon, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? category.color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final picked = await Utils.pickDate(context, initialDate: selectedDate);
        if (picked != null) onDateChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Constant.white,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: Constant.violetDarker,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Utils.formatDateShort(selectedDate),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final TransactionType activeType;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.activeType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isIncome = activeType == TransactionType.income;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Constant.violetDarker,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'Income',
            isActive: isIncome,
            onTap: () => onChanged(TransactionType.income),
          ),
          _ToggleItem(
            label: 'Expense',
            isActive: !isIncome,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Constant.expensePrime : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Constant.textWhite,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
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
