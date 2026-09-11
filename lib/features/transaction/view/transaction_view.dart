import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/date_picker_sheet.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/time_picker_sheet.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../../home/provider/home_provider.dart';
import '../provider/transaction_provider.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({super.key});

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await DatePickerSheet.show(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await TimePickerSheet.show(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time != null && mounted) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();

    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    if (amount <= 0) {
      Utils.showWarningDialog(
        context,
        title: 'Nominal tidak valid',
        content: 'Masukkan nominal transaksi yang benar',
      );
      return;
    }

    final userId = context.read<AuthProvider>().user?.id ?? '';
    final provider = context.read<TransactionProvider>();

    final success = await provider.submit(
      userId: userId,
      amount: amount,
      note: _noteController.text,
      date: _selectedDateTime,
    );

    if (success && mounted) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }

      if (user?.notifEnabled == true) {
        NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'Transaksi Berhasil! 🎉',
          body:
              'Data ${provider.isExpense ? "pengeluaran" : "pemasukan"} sebesar ${Utils.formatIDR(amount)} telah dicatat.',
        );
      }

      CustomNavigator.pop(context);
    } else if (mounted) {
      Utils.showWarningDialog(
        context,
        title: 'Lengkapi Transaksi',
        content: provider.errorMessage ?? 'Terjadi kesalahan',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final user = context.read<AuthProvider>().user;
    final currency = user?.currency ?? 'IDR';

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Transaksi',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.surfaceCard,
        foregroundColor: Constant.textPrimary,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Constant.limeAccentDark,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Toggle
                          SegmentedControl(
                            labels: const ['Pemasukan', 'Pengeluaran'],
                            selectedIndex: provider.isExpense ? 1 : 0,
                            onChanged: (index) => provider.setType(
                              index == 0
                                  ? TransactionType.income
                                  : TransactionType.expense,
                            ),
                            borderRadius: 24,
                            height: 50,
                            backgroundColor: Constant.greyLight,
                          ),
                          const SizedBox(height: 24),

                          // Amount Field
                          _SectionLabel('NOMINAL'),
                          const SizedBox(height: 8),
                          CustomTextField.standard(
                            controller: _amountController,
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
                          if (provider.isExpense) ...[
                            _SectionLabel('KATEGORI'),
                            const SizedBox(height: 12),
                            _buildCategoryGrid(provider),
                            const SizedBox(height: 24),
                          ],

                          // Description
                          _SectionLabel('DESKRIPSI'),
                          const SizedBox(height: 8),
                          CustomTextField.standard(
                            controller: _noteController,
                            hint: 'Catatan transaksi',
                            maxLines: 4,
                          ),

                          const SizedBox(height: 24),

                          // Date & Time
                          _SectionLabel('TANGGAL & WAKTU'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _DateTimeField(
                                  label: 'TANGGAL',
                                  value: Utils.formatDateShort(
                                    _selectedDateTime,
                                  ),
                                  icon: Icons.calendar_today_outlined,
                                  onTap: _pickDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DateTimeField(
                                  label: 'WAKTU',
                                  value:
                                      '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                  icon: Icons.access_time_outlined,
                                  onTap: _pickTime,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 100,
                          ), // Space for floating button
                        ],
                      ),
                    ),
            ),

            // Floating Save Button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: CustomButton.mainButton(
                  label: 'Simpan',
                  textColor: Constant.textPrimary,
                  fontSize: 16,
                  onPressed: _onSubmit,
                  isLoading: provider.isSaving,
                  height: 56,
                  borderRadius: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(TransactionProvider provider) {
    final categories = provider.currentCategories;

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: categories.map((cat) {
        final isSelected = provider.selectedCategory?.id == cat.id;
        return _CategoryChip(
          category: cat,
          isSelected: isSelected,
          onTap: () => provider.setCategory(cat),
        );
      }).toList(),
    );
  }
}

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
            Image.asset(category.icon, width: 22, height: 22),
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

class _DateTimeField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Constant.captionBold.copyWith(color: Constant.textSecondary),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Constant.greyLight,
              border: Border.all(color: Constant.borderSubtle, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Constant.limeAccentDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: Constant.bodyMedium.copyWith(
                      color: Constant.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===== FORMATTER =====
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
