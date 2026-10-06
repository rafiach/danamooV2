import 'package:danamoo/data/models/wallet_model.dart';
import 'package:danamoo/data/sources/local/transaction_local.dart';
import 'package:danamoo/features/wallet/provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/utils/utils.dart';
import '../../../core/utils/wallet_utils.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/date_picker_sheet.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/time_picker_sheet.dart';
import '../../../core/widgets/wallet_selector.dart';
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
  String _selectedWalletId = WalletModel.mainId;
  String? _toWalletId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories();
      cekId();
    });
  }

  void cekId() async {
    final storage = await StorageService.getInstance();
    final user = storage.getUser();
    if (user != null) {
      final transactionSource = TransactionLocalSource();
      final wallets = await transactionSource.getAll(user['id']);
      for (final w in wallets) {
        print('Wallet ID transaksi: ${w.walletId}, wallet: ${w.id}');
      }
    }
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
      Utils.showErrorDialog(
        context,
        title: 'Nominal tidak valid',
        content: 'Masukkan nominal transaksi yang benar',
        mode: StatusDialogMode.autoDismiss,
      );
      return;
    }

    final userId = context.read<AuthProvider>().user?.id ?? '';
    final provider = context.read<TransactionProvider>();

    debugPrint('1 VIEW walletId=$_selectedWalletId');
    final success = await provider.submit(
      userId: userId,
      walletId: _selectedWalletId,
      toWalletId: resolveToWalletId(
        context.read<WalletProvider>().wallets,
        _selectedWalletId,
        _toWalletId,
      ),
      amount: amount,
      note: _noteController.text,
      date: _selectedDateTime,
    );

    if (success && mounted) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }

      if (user?.notifEnabled == true && !provider.isTransfer) {
        final isIncome = !provider.isExpense;
        NotificationService.showTransactionNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: isIncome
              ? 'Pemasukan Tercatat! 💰'
              : 'Pengeluaran Tercatat! 🧾',
          body:
              '${isIncome ? "Pemasukan" : "Pengeluaran"} sebesar ${Utils.formatIDR(amount)} telah dicatat.',
          isIncome: isIncome,
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
    final wallets = context.watch<WalletProvider>().wallets;
    final toId = resolveToWalletId(wallets, _selectedWalletId, _toWalletId);
    final toWallets = wallets.where((w) => w.id != _selectedWalletId).toList();
    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Transaksi',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.bgNeutral,
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
                            labels: const [
                              'Pemasukan',
                              'Pengeluaran',
                              'Transfer',
                            ],
                            selectedIndex: provider.activeType.index,
                            onChanged: (index) =>
                                provider.setType(TransactionType.values[index]),
                            borderRadius: 24,
                            height: 50,
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
                              CurrencyInputFormatter(),
                            ],
                          ),

                          const SizedBox(height: 24),
                          // Wallet
                          _SectionLabel(
                            provider.isTransfer ? 'DARI DOMPET' : 'DOMPET',
                          ),
                          const SizedBox(height: 12),
                          WalletSelector(
                            wallets: wallets,
                            selectedId: _selectedWalletId,
                            onChanged: (w) =>
                                setState(() => _selectedWalletId = w.id),
                          ),
                          const SizedBox(height: 24),

                          if (provider.isTransfer) ...[
                            _SectionLabel('KE DOMPET'),
                            const SizedBox(height: 12),
                            if (toWallets.isEmpty)
                              Text(
                                'Buat dompet lain dulu untuk bisa transfer',
                                style: Constant.caption,
                              )
                            else
                              WalletSelector(
                                wallets: toWallets,
                                selectedId: toId!,
                                onChanged: (w) =>
                                    setState(() => _toWalletId = w.id),
                              ),
                            const SizedBox(height: 24),
                          ],
                          const SizedBox(height: 24),

                          // category
                          _SectionLabel(
                            provider.isExpense
                                ? 'KATEGORI'
                                : 'SUMBER PEMASUKAN',
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryGrid(provider),
                          const SizedBox(height: 24),

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
                                  icon: LucideIcons.calendarSearch400,
                                  onTap: _pickDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DateTimeField(
                                  label: 'WAKTU',
                                  value:
                                      '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                  icon: LucideIcons.clock8400,
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
                  color: Constant.surfaceDark,
                  textColor: Constant.limeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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
        return CategoryChip(
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
