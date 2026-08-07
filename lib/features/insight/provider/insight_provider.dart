import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../model/insight_model.dart';

class InsightProvider extends ChangeNotifier {
  final TransactionRepository _transactionrepo;

  InsightProvider({required TransactionRepository transactionRepository})
    : _transactionrepo = transactionRepository {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late DateTime _selectedMonth;
  DateTime get selectedMonth => _selectedMonth;

  InsightModel? _insightModel;
  InsightModel? get insightModel => _insightModel;

  String? errorMessage;

  Future<void> fetchMonthlyData(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final int year = _selectedMonth.year;
      final int month = _selectedMonth.month;
      final int daysInMonth = DateTime(year, month + 1, 0).day;

      final allTransactions = await _transactionrepo.getAll(user.id);
      final allCategories = CategoryModel.all;
      final catMapById = {for (var c in allCategories) c.id: c.name};

      // ── Tab 1: Balance kumulatif ──────────────────────────────────────────
      final List<double> balance = List.filled(daysInMonth, 0.0);
      final List<String> labels = List.generate(daysInMonth, (i) => '${i + 1}');
      double runningBalance = user.initialBalance;
      final startOfMonth = DateTime(year, month, 1);

      for (var tx in allTransactions) {
        if (tx.date.isBefore(startOfMonth)) {
          runningBalance += tx.type == TransactionType.income
              ? tx.amount
              : -tx.amount;
        }
      }
      for (int i = 0; i < daysInMonth; i++) {
        for (var tx in allTransactions) {
          if (tx.date.year == year &&
              tx.date.month == month &&
              tx.date.day == i + 1) {
            runningBalance += tx.type == TransactionType.income
                ? tx.amount
                : -tx.amount;
          }
        }
        balance[i] = runningBalance;
      }

      // ── Tab 2: Income & Expense per hari ─────────────────────────────────
      final List<double> incomePerDay = List.filled(daysInMonth, 0.0);
      final List<double> expensePerDay = List.filled(daysInMonth, 0.0);
      for (var tx in allTransactions) {
        if (tx.date.year == year && tx.date.month == month) {
          final idx = tx.date.day - 1;
          if (tx.type == TransactionType.income) {
            incomePerDay[idx] += tx.amount;
          } else {
            expensePerDay[idx] += tx.amount;
          }
        }
      }

      // ── Tab 3: Spending per kategori ─────────────────────────────────────
      final Map<String, double> categoryMap = {};
      for (var tx in allTransactions) {
        if (tx.date.year == year &&
            tx.date.month == month &&
            tx.type == TransactionType.expense) {
          final catName = catMapById[tx.categoryId] ?? 'Lainnya';
          categoryMap[catName] = (categoryMap[catName] ?? 0) + tx.amount;
        }
      }

      _insightModel = InsightModel(
        balanceData: balance,
        dayLabels: labels,
        incomeData: incomePerDay,
        expenseData: expensePerDay,
        spendingByCategory: categoryMap,
      );
    } catch (e) {
      errorMessage = 'Gagal memuat data insight: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void changeMonth(DateTime newMonth, UserModel user) {
    _selectedMonth = newMonth;
    fetchMonthlyData(user);
  }
}
