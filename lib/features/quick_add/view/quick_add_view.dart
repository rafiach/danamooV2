import 'package:danamoo/core/constants/constant.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _repository = TransactionRepository();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  CategoryModel? _selectedCategory;
  String? _userId;
  bool _loading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storage = await StorageService.getInstance();
    final user = storage.getUser();
    setState(() {
      _userId = user?['id'] as String?; // sesuaikan key kalau beda di UserModel
      _selectedCategory = CategoryModel.expenseCategories.first;
      _loading = false;
    });
  }

  List<CategoryModel> get _categories => _type == TransactionType.income
      ? CategoryModel.incomeCategories
      : CategoryModel.expenseCategories;

  Future<void> _save() async {
    if (_userId == null || _selectedCategory == null) return;

    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return;

    setState(() => _isSaving = true);

    await _repository.add(
      userId: _userId!,
      categoryId: _selectedCategory!.id,
      type: _type,
      amount: amount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Constant.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _userId == null
                  ? const _NotLoggedInMessage()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tambah Transaksi',
                          style: Constant.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<TransactionType>(
                          segments: const [
                            ButtonSegment(
                              value: TransactionType.expense,
                              label: Text('Pengeluaran'),
                            ),
                            ButtonSegment(
                              value: TransactionType.income,
                              label: Text('Pemasukan'),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (s) {
                            setState(() {
                              _type = s.first;
                              _selectedCategory = _categories.first;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Nominal',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CategoryModel>(
                          value: _selectedCategory,
                          items: _categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (c) =>
                              setState(() => _selectedCategory = c),
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan (opsional)',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => SystemNavigator.pop(),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _save,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Simpan'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotLoggedInMessage extends StatelessWidget {
  const _NotLoggedInMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Silakan login dulu di aplikasi utama.'),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
