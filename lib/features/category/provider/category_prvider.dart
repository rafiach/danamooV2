import 'package:flutter/material.dart';

import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final StorageService _storage;
  final TransactionRepository _transactionRepository;

  CategoryProvider({
    required StorageService storage,
    required TransactionRepository transactionRepository,
  }) : _storage = storage,
       _transactionRepository = transactionRepository;

  // Jumlah transaksi yang memakai kategori ini
  Future<int> countUsage(String userId, String categoryId) async {
    final txs = await _transactionRepository.getAll(userId);
    return txs.where((t) => t.categoryId == categoryId).length;
  }

  // null = valid
  String? validateName(CategoryModel category, String input) {
    final name = input.trim();
    if (name.isEmpty) return 'Nama tidak boleh kosong';
    if (name.length > 20) return 'Maksimal 20 karakter';

    final sameType = category.type == CategoryModel.incomeCategories.first.type
        ? CategoryModel.incomeCategories
        : CategoryModel.expenseCategories;
    final duplicate = sameType.any(
      (c) => c.id != category.id && c.name.toLowerCase() == name.toLowerCase(),
    );
    return duplicate ? 'Nama sudah dipakai kategori lain' : null;
  }

  Future<void> save({
    required String categoryId,
    required String name,
    String? iconKey,
  }) async {
    final next = {...CategoryModel.overrides};
    next[categoryId] = {
      'name': name.trim(),
      if (iconKey != null) 'icon': iconKey,
    };
    await _persist(next);
  }

  Future<void> reset(String categoryId) async {
    final next = {...CategoryModel.overrides}..remove(categoryId);
    await _persist(next);
  }

  Future<void> _persist(Map<String, Map<String, String>> next) async {
    CategoryModel.setOverrides(next);
    await _storage.saveCategoryOverrides(next);
    notifyListeners();
  }
}
