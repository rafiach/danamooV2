import 'package:danamoo/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../data/models/transaction_model.dart';
import '../../../generated/assets.dart';
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

  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _incomeCategories = [];
  List<CategoryModel> _expenseCategories = [];

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
    _selectedCategory = widget.data.category;

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _incomeCategories = CategoryModel.incomeCategories;
      _expenseCategories = CategoryModel.expenseCategories;
    });
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
      _selectedCategory = widget.data.category;
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

    final provider = context.read<TransactionProvider>();
    final success = await provider.update(
      userId: userId,
      transactionId: widget.data.transaction.id,
      amount: amount,
      note: _noteController.text,
      date: _selectedDate,
      type: _selectedType,
      categoryId: _selectedCategory?.id,
      createdAt: widget.data.transaction.createdAt,
    );

    if (!mounted) return;

    if (success) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }

      Utils.showAutoDismissDialog(
        context,
        title: 'Perubahan Disimpan',
        content: 'Transaksi berhasil diperbarui',
        imagePath: Assets.assetsIconsSuccess,
        onDismissed: () {
          if (mounted) CustomNavigator.pop(context, true);
        },
      );
    } else {
      Utils.showAutoDismissDialog(
        context,
        title: 'Perubahan Gagal Disimpan',
        content: 'Transaksi gagal diperbarui',
        imagePath: Assets.assetsIconsError,
        onDismissed: () {
          if (mounted) CustomNavigator.pop(context, true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.data.transaction;
    final user = context.read<AuthProvider>().user;
    final currency = user?.currency ?? 'IDR';
    final currentCategories = _selectedType == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Detail Transaksi',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.surfaceCard,
        foregroundColor: Constant.textPrimary,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEdit,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
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
                          onDateChanged: (date) =>
                              setState(() => _selectedDate = date),
                          onTypeChanged: (type) => setState(() {
                            _selectedType = type;
                            _selectedCategory = null;
                          }),
                          onCategoryChanged: (cat) =>
                              setState(() => _selectedCategory = cat),
                        )
                      : HistoryDetailContent(
                          transaction: tx,
                          category: widget.data.category,
                          currency: currency,
                        ),
                ),
              ),
            ),

            // Floating Save Button (only in edit mode)
            if (_isEditing)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: CustomButton.mainButton(
                    label: 'Simpan',
                    onPressed: _saveChanges,
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
}