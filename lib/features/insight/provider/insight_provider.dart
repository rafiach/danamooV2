import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/wallet_repository.dart';
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

  double _delta(TransactionModel tx) {
    switch (tx.type) {
      case TransactionType.income:
        return tx.amount;
      case TransactionType.expense:
        return -tx.amount;
      case TransactionType.transfer:
        return 0;
    }
  }

  Future<void> fetchMonthlyData(UserModel user, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final int year = _selectedMonth.year;
      final int month = _selectedMonth.month;
      final int daysInMonth = DateTime(year, month + 1, 0).day;

      final allTransactions = await _transactionrepo.getAll(user.id);

      // ── Tab 1: Balance kumulatif ──────────────────────────────────────────
      final List<double> balance = List.filled(daysInMonth, 0.0);
      final List<String> labels = List.generate(daysInMonth, (i) => '${i + 1}');
      final wallets = await WalletRepository().getAll(user);
      double runningBalance = wallets.fold<double>(
        0,
        (s, w) => s + w.initialBalance,
      );
      final startOfMonth = DateTime(year, month, 1);

      for (var tx in allTransactions) {
        if (tx.date.isBefore(startOfMonth)) {
          runningBalance += _delta(tx);
        }
      }
      final double openingBalance = runningBalance;
      for (int i = 0; i < daysInMonth; i++) {
        for (var tx in allTransactions) {
          if (tx.date.year == year &&
              tx.date.month == month &&
              tx.date.day == i + 1) {
            runningBalance += _delta(tx);
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
          } else if (tx.type == TransactionType.expense) {
            expensePerDay[idx] += tx.amount;
          }
        }
      }

      // ── Tab 3: Total per kategori ─────────────────────────────────────
      final Map<String, double> expenseCategory = {};
      final Map<String, double> incomeCategory = {};
      for (var tx in allTransactions) {
        if (tx.date.year == year && tx.date.month == month) {
          final target = tx.type == TransactionType.expense
              ? expenseCategory
              : incomeCategory;
          target[tx.categoryId] = (target[tx.categoryId] ?? 0) + tx.amount;
        }
      }

      // ── Tab 1: pembanding bulan lalu & statistik ─────────────────────────
      final now = DateTime.now();
      final isCurrentMonth = now.year == year && now.month == month;
      final int visibleDays = isCurrentMonth ? now.day : daysInMonth;
      // Bulan berjalan dibanding "periode yang sama" bulan lalu, biar adil
      final int prevCutoff = isCurrentMonth ? now.day : 31;
      final prevMonth = DateTime(year, month - 1, 1);

      double prevIncome = 0;
      double prevExpense = 0;
      int expenseCount = 0;
      for (var tx in allTransactions) {
        if (tx.date.year == prevMonth.year &&
            tx.date.month == prevMonth.month &&
            tx.date.day <= prevCutoff) {
          if (tx.type == TransactionType.income) {
            prevIncome += tx.amount;
          } else {
            prevExpense += tx.amount;
          }
        }
        if (tx.date.year == year &&
            tx.date.month == month &&
            tx.type == TransactionType.expense) {
          expenseCount++;
        }
      }

      // ── Tren 6 bulan (berakhir di bulan terpilih) ────────────────────────
      // DateTime(year, month - 5 + i) otomatis menangani lintas tahun
      final trendMonths = List.generate(
        6,
        (i) => DateTime(year, month - 5 + i, 1),
      );
      final trendIncome = List.filled(6, 0.0);
      final trendExpense = List.filled(6, 0.0);
      for (var tx in allTransactions) {
        final idx = trendMonths.indexWhere(
          (m) => m.year == tx.date.year && m.month == tx.date.month,
        );
        if (idx == -1) continue;
        if (tx.type == TransactionType.income) {
          trendIncome[idx] += tx.amount;
        } else {
          trendExpense[idx] += tx.amount;
        }
      }

      _insightModel = InsightModel(
        balanceData: balance,
        dayLabels: labels,
        incomeData: incomePerDay,
        expenseData: expensePerDay,
        expenseByCategory: expenseCategory,
        incomeByCategory: incomeCategory,
        openingBalance: openingBalance,
        prevIncome: prevIncome,
        prevExpense: prevExpense,
        expenseCount: expenseCount,
        visibleDays: visibleDays,
        trendMonths: trendMonths,
        trendIncome: trendIncome,
        trendExpense: trendExpense,
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
