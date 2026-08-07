import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

import '../../../data/models/category_model.dart';
import '../model/history_model.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepositori;

  HistoryProvider({required TransactionRepository transactionRepositori})
    : _transactionRepositori = transactionRepositori;

  HistoryStatus _status = HistoryStatus.initial;
  String? _errorMessage;

  // Raw data
  List<TransactionModel> _allTransactions = [];
  List<CategoryModel> _allCategories = [];
  Map<String, CategoryModel> _categoryMap = {};

  // Filter state
  String _searchQuery = '';
  String _selectedType = 'All'; // 'All' | 'Income' | 'Expense'
  String? _selectedCategory; // nama kategori expense, nullable
  DateTime? _selectedDate;

  // Getters
  HistoryStatus get status => _status;
  bool get isLoading => _status == HistoryStatus.loading;
  String? get errorMessage => _errorMessage;
  List<CategoryModel> get categories => _allCategories;
  String get selectedType => _selectedType;
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;

  // Filtered list
  List<HistoryListItem> get filteredTransactions {
    List<TransactionModel> filtered = _allTransactions.where((t) {
      // Filter by type
      if (_selectedType == 'Income' && t.type != TransactionType.income) {
        return false;
      }
      if (_selectedType == 'Expense' && t.type != TransactionType.expense) {
        return false;
      }

      // Filter by category (hanya aktif saat Expense dipilih)
      if (_selectedType == 'Expense' && _selectedCategory != null) {
        final cat = _categoryMap[t.categoryId];
        if (cat?.name != _selectedCategory) return false;
      }

      // Filter by date
      if (_selectedDate != null) {
        if (t.date.year != _selectedDate!.year ||
            t.date.month != _selectedDate!.month ||
            t.date.day != _selectedDate!.day) {
          return false;
        }
      }

      // Filter by search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final note = t.note?.toLowerCase() ?? '';
        final catName = _categoryMap[t.categoryId]?.name.toLowerCase() ?? '';
        if (!note.contains(query) && !catName.contains(query)) return false;
      }

      return true;
    }).toList();

    return filtered.map((tx) {
      return HistoryListItem(
        transaction: tx,
        category: _categoryMap[tx.categoryId],
      );
    }).toList();
  }

  // ================= ACTIONS =================

  Future<void> fetchData(String userId) async {
    _status = HistoryStatus.loading;
    notifyListeners();

    try {
      final transactions = await _transactionRepositori.getAll(userId);

      _allCategories = CategoryModel.all;
      _allTransactions = transactions..sort((a, b) => b.date.compareTo(a.date));

      _categoryMap = {for (var c in _allCategories) c.id: c};
      _status = HistoryStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load history data.';
      _status = HistoryStatus.error;
    }
    notifyListeners();
  }

  void setType(String type) {
    if (_selectedType == type) return;
    _selectedType = type;
    _selectedCategory = null; // reset kategori saat ganti tipe
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearDate() {
    _selectedDate = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedType = 'All';
    _selectedCategory = null;
    _selectedDate = null;
    _searchQuery = '';
  }
}
