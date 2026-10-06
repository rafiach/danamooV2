import 'dart:io';

import 'package:danamoo/core/utils/wallet_utils.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/features/wallet/provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../data/models/transaction_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../transaction/provider/transaction_provider.dart';
import '../model/history_model.dart';
import 'widget/history_detail_content.dart';
import 'widget/history_edit_form.dart';

class DetailHistoryView extends StatefulWidget {
  final HistoryListItem data;

  const DetailHistoryView({super.key, required this.data});

  @override
  State<DetailHistoryView> createState() => _DetailHistoryViewState();
}

class _DetailHistoryViewState extends State<DetailHistoryView> {
  bool _isEditing = false;
  String? _selectedToWalletId;

  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  late String _selectedWalletId;

  String? _selectedCategoryId;
  CategoryModel? get _selectedCategory => _selectedCategoryId == null
      ? null
      : CategoryModel.getById(_selectedCategoryId!);

  @override
  void initState() {
    super.initState();
    final tx = widget.data.transaction;

    final formattedAmount = tx.amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    _amountController = TextEditingController(text: formattedAmount);
    _noteController = TextEditingController(text: tx.note ?? '');
    _selectedDate = tx.date;
    _selectedType = tx.type;
    _selectedCategoryId = tx.categoryId;
    _selectedWalletId = tx.walletId;
    _selectedToWalletId = tx.toWalletId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }
    _saveChanges();
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      final tx = widget.data.transaction;
      final formattedAmount = tx.amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      _amountController.text = formattedAmount;
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.date;
      _selectedType = tx.type;
      _selectedCategoryId = tx.categoryId;
      _selectedToWalletId = tx.toWalletId;
    });
  }

  Future<void> _saveChanges() async {
    final userId = context.read<AuthProvider>().user?.id ?? '';

    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final amount = double.tryParse(rawAmount) ?? 0;

    if (amount <= 0) {
      Utils.showWarningDialog(
        context,
        title: 'Nominal tidak valid',
        content: 'Masukkan nominal transaksi yang benar',
      );
      return;
    }

    if (_selectedType == TransactionType.expense &&
        _selectedCategoryId == null) {
      Utils.showWarningDialog(
        context,
        title: 'Pilih Kategori',
        content: 'Pilih kategori pengeluaran terlebih dahulu',
      );
      return;
    }

    final provider = context.read<TransactionProvider>();

    final success = await provider.update(
      userId: userId,
      transactionId: widget.data.transaction.id,
      walletId: _selectedWalletId,
      toWalletId: resolveToWalletId(
        context.read<WalletProvider>().wallets,
        _selectedWalletId,
        _selectedToWalletId,
      ),
      amount: amount,
      note: _noteController.text,
      date: _selectedDate,
      type: _selectedType,
      categoryId: _selectedCategoryId,
      createdAt: widget.data.transaction.createdAt,
    );

    if (!mounted) return;

    if (success) {
      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }

      await Utils.showSuccessDialog(
        context,
        title: 'Transaksi Diperbarui',
        content: 'Transaksi berhasil diperbarui',
        mode: StatusDialogMode.autoDismiss,
      );

      if (mounted) {
        CustomNavigator.pop(context, true);
      }
    } else {
      await Utils.showErrorDialog(
        context,
        title: 'Gagal diperbarui',
        content: 'Transaksi gagal diperbarui, mohon coba lagi',
        mode: StatusDialogMode.autoDismiss,
      );
    }
  }

  void _showDeleteDialog() {
    Utils.showWarningDialog(
      context,
      title: 'Hapus Transaksi',
      content: 'Apakah yakin ingin menghapus transaksi ini?',
      confirmText: 'Ya',
      cancelText: 'Tidak',
      onConfirm: _deleteTransaction,
    );
  }

  Future<void> _deleteTransaction() async {
    final userId = context.read<AuthProvider>().user?.id ?? '';

    final provider = context.read<TransactionProvider>();

    final success = await provider.delete(
      userId: userId,
      transactionId: widget.data.transaction.id,
    );

    if (!mounted) return;

    if (success) {
      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }

      await Utils.showSuccessDialog(
        context,
        title: 'Transaksi Dihapus',
        content: 'Transaksi berhasil dihapus',
        mode: StatusDialogMode.autoDismiss,
      );

      if (mounted) {
        CustomNavigator.pop(context, true);
      }
    } else {
      await Utils.showErrorDialog(
        context,
        title: 'Gagal Menghapus',
        content: 'Transaksi gagal dihapus, mohon coba lagi',
        mode: StatusDialogMode.autoDismiss,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.data.transaction;
    final user = context.read<AuthProvider>().user;
    final currency = user?.currency ?? 'IDR';
    final currentCategories = _selectedType == TransactionType.income
        ? CategoryModel.incomeCategories
        : CategoryModel.expenseCategories;
    final walletProvider = context.watch<WalletProvider>();
    final wallets = walletProvider.wallets;
    final toWalletId = resolveToWalletId(
      wallets,
      _selectedWalletId,
      _selectedToWalletId,
    );

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: _isEditing ? 'Edit Transaksi' : 'Detail Transaksi',
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
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isEditing
                      ? HistoryEditForm(
                          amountController: _amountController,
                          noteController: _noteController,
                          selectedDate: _selectedDate,
                          selectedType: _selectedType,
                          selectedCategory: _selectedCategory,
                          categories: currentCategories,
                          currency: currency,
                          wallets: wallets,
                          selectedWalletId: _selectedWalletId,
                          selectedToWalletId: toWalletId ?? '',
                          onWalletChanged: (w) =>
                              setState(() => _selectedCategoryId),
                          onToWalletChanged: (w) =>
                              setState(() => _selectedToWalletId = w.id),
                          onDateChanged: (date) =>
                              setState(() => _selectedDate = date),
                          onTimeChanged: (dateTime) =>
                              setState(() => _selectedDate = dateTime),
                          onTypeChanged: (type) => setState(() {
                            _selectedType = type;
                            _selectedCategoryId = type == TransactionType.income
                                ? 'inc_1'
                                : null;
                          }),
                          onCategoryChanged: (cat) =>
                              setState(() => _selectedCategoryId = cat?.id),
                        )
                      : HistoryDetailContent(
                          transaction: tx,
                          category: widget.data.category,
                          currency: currency,
                          walletName: walletProvider.nameOf(tx.walletId),
                          toWalletName: walletProvider.nameOf(tx.toWalletId),
                        ),
                ),
              ),
            ),

            // Floating actions
            if (_isEditing) ...[
              SafeArea(top: false, child: _buildEditActions()),
            ] else ...[
              SafeArea(top: false, child: _buildDetailActions()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buttonAction(
            "Edit",
            _toggleEdit,
            Constant.surfaceDark,
            Constant.limeAccent,
          ),
          const SizedBox(width: 12),
          _buttonAction(
            "Hapus",
            _showDeleteDialog,
            Constant.expenseRed,
            Constant.textWhite,
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buttonAction(
            "Simpan",
            _saveChanges,
            Constant.surfaceDark,
            Constant.limeAccent,
          ),
          const SizedBox(width: 12),
          _buttonAction(
            "Batal",
            _cancelEdit,
            Constant.expenseRed,
            Constant.textWhite,
          ),
        ],
      ),
    );
  }

  Widget _buttonAction(
    String label,
    VoidCallback onPressed,
    Color color,
    Color textColor,
  ) {
    return Expanded(
      child: CustomButton.mainButton(
        label: label,
        onPressed: onPressed,
        height: 48,
        borderRadius: 12,
        color: color,
        textColor: textColor,
        fontSize: 14,
      ),
    );
  }
}
