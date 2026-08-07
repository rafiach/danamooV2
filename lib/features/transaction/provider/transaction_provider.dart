import 'package:flutter/material.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';

import '../model/transaction_model.dart';

// enum TransactionType { income, expense }
enum TransactionStatus { initial, loading, loaded, saving, success, error }

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  TransactionProvider({required TransactionRepository transactionRepository})
    : _transactionRepository = transactionRepository;

  TransactionStatus _status = TransactionStatus.initial;
  TransactionFormData? _formData;
  String? _errorMessage;

  TransactionType _activeType = TransactionType.income;
  CategoryModel? _selectedCategory;

  TransactionStatus get status => _status;
  TransactionFormData? get formData => _formData;
  String? get errorMessage => _errorMessage;
  TransactionType get activeType => _activeType;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _status == TransactionStatus.loading;
  bool get isSaving => _status == TransactionStatus.saving;
  bool get isSuccess => _status == TransactionStatus.success;
  bool get isExpense => _activeType == TransactionType.expense;

  List<CategoryModel> get currentCategories =>
      _formData?.categoriesFor(_activeType) ?? [];

  // ================= LOAD CATEGORIES =================
  Future<void> loadCategories() async {
    _status = TransactionStatus.loading;
    notifyListeners();

    try {
      _formData = TransactionFormData(
        incomeCategories: CategoryModel.incomeCategories,
        expenseCategories: CategoryModel.expenseCategories,
      );
      _status = TransactionStatus.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori';
      _status = TransactionStatus.error;
    }

    notifyListeners();
  }

  // ================= TOGGLE TYPE =================
  void setType(TransactionType type) {
    if (_activeType == type) return;
    _activeType = type;
    _selectedCategory = null;
    notifyListeners();
  }

  // ================= SELECT CATEGORY =================
  void setCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ================= SUBMIT =================
  Future<bool> submit({
    required String userId,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    if (amount <= 0) {
      _errorMessage = 'Nominal harus lebih dari 0';
      _status = TransactionStatus.error;
      notifyListeners();
      return false;
    }

    if (_activeType == TransactionType.expense && _selectedCategory == null) {
      _errorMessage = 'Pilih kategori terlebih dahulu';
      _status = TransactionStatus.error;
      notifyListeners();
      return false;
    }

    _status = TransactionStatus.saving;
    _errorMessage = null;
    notifyListeners();

    final categoryId =
        _selectedCategory?.id ?? (_formData?.incomeCategories.first.id ?? '');

    final result = await _transactionRepository.add(
      userId: userId,
      categoryId: categoryId,
      type: _activeType,
      amount: amount,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      date: date,
    );

    if (result != null) {
      _status = TransactionStatus.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Gagal menyimpan transaksi';
      _status = TransactionStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ================= UPDATE =================
  Future<bool> update({
    required String userId,
    required String transactionId,
    required double amount,
    String? note,
    DateTime? date,
    TransactionType? type,
    String? categoryId,
    DateTime? createdAt,
  }) async {
    if (amount <= 0) {
      _errorMessage = 'Nominal harus lebih dari 0';
      _status = TransactionStatus.error;
      notifyListeners();
      return false;
    }

    if (type == TransactionType.expense && categoryId == null) {
      _errorMessage = 'Pilih kategori terlebih dahulu';
      _status = TransactionStatus.error;
      notifyListeners();
      return false;
    }

    _status = TransactionStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final finalCategoryId =
          categoryId ?? (_formData?.incomeCategories.first.id ?? '');

      final now = DateTime.now();
      final updatedTx = TransactionModel(
        id: transactionId,
        userId: userId,
        categoryId: finalCategoryId,
        type: type ?? TransactionType.income,
        amount: amount,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        date: date ?? now,
        createdAt: createdAt ?? now,
        updatedAt: now,
      );

      await _transactionRepository.update(updatedTx);

      _status = TransactionStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem';
      _status = TransactionStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ================= RESET =================
  void reset() {
    _activeType = TransactionType.income;
    _selectedCategory = null;
    _errorMessage = null;
    _status = _formData != null
        ? TransactionStatus.loaded
        : TransactionStatus.initial;
    notifyListeners();
  }
}
