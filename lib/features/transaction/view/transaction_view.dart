import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constant.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
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
    final date = await showDatePicker(
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
    final time = await showTimePicker(
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
    // Hapus format titik (ribuan) untuk dikembalikan ke angka murni
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final userId = context.read<AuthProvider>().user?.id ?? '';
    final provider = context.read<TransactionProvider>();

    final success = await provider.submit(
      userId: userId,
      amount: amount,
      note: _noteController.text,
      date: _selectedDateTime,
    );

    if (success && mounted) {
      // Refresh home data setelah transaksi berhasil
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }

      // Tampilkan Notifikasi Sistem
      if (user?.notifEnabled == true) {
        NotificationService.showNotification(
          // ID unik agar notifikasi tidak tertumpuk menimpa satu sama lain
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
        title: 'Complete your transaction!',
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
      backgroundColor: Constant.violetDarker,
      appBar: CustomAppBar.standard(
        title: 'Transaction',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.violetDarker,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Container(
        color: Constant.violet50,
        child: SafeArea(
          top: false,
          child: _SubmitButton(
            isLoading: provider.isSaving,
            onPressed: _onSubmit,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    color: Constant.violetDarker,
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child:
                        // ===== TOGGLE INCOME / EXPENSE =====
                        _TypeToggle(
                          activeType: provider.activeType,
                          onChanged: provider.setType,
                        ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Constant.violet50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== AMOUNT =====
                            Text(
                              'NOMINAL',
                              style: Constant.bodyLarge.copyWith(
                                color: Constant.violetDarker,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
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

                            const SizedBox(height: 16),

                            // ===== CATEGORY (hanya expense) =====
                            if (provider.isExpense) ...[
                              const SizedBox(height: 8),

                              Text(
                                'Category',
                                style: Constant.bodyLarge.copyWith(
                                  color: Constant.violetDarker,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: provider.currentCategories.map((cat) {
                                  final isSelected =
                                      provider.selectedCategory?.id == cat.id;
                                  return GestureDetector(
                                    onTap: () => provider.setCategory(cat),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? cat.color.withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? cat.color
                                              : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            cat.icon,
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            cat.name,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? cat.color
                                                  : Colors.grey.shade700,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // ===== DESCRIPTION =====
                            Text(
                              'Description',
                              style: Constant.bodyLarge.copyWith(
                                color: Constant.violetDarker,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CustomTextField.standard(
                              controller: _noteController,
                              labelColor: Constant.violetDarker,
                              hint: 'Describe your transaction',
                              maxLines: 5,
                            ),

                            // ===== DATE & TIME =====
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // DATE FIELD
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DATE',
                                        style: Constant.bodyLarge.copyWith(
                                          color: Constant.violetDarker,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: _pickDate,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Constant.white,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                                  '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // TIME FIELD
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TIME',
                                        style: Constant.bodyLarge.copyWith(
                                          color: Constant.violetDarker,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: _pickTime,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Constant.white,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 20,
                                                color: Constant.violetDarker,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // // ===== SUBMIT BUTTON =====
                  // _SubmitButton(
                  //   isLoading: provider.isSaving,
                  //   onPressed: _onSubmit,
                  // ),
                ],
              ),
            ),
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

// ===== WIDGETS =====

class _TypeToggle extends StatelessWidget {
  final TransactionType activeType;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.activeType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isIncome = activeType == TransactionType.income;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Constant.violet200,
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
              color: isActive ? Constant.violetDarker : Constant.textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Constant.expensePrime,
            foregroundColor: Constant.greenPrime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constant.textWhite,
                  ),
                ),
        ),
      ),
    );
  }
}
