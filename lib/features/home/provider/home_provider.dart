import 'package:flutter/material.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:danamoo/features/home/model/home_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  HomeStatus _status = HomeStatus.initial;
  HomeModel? _homeModel;
  String? _errorMessage;

  HomeProvider({required TransactionRepository transactionRepository})
    : _transactionRepository = transactionRepository;

  HomeStatus get status => _status;
  HomeModel? get homeModel => _homeModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HomeStatus.loading;

  // ================= FETCH =================
  Future<void> fetchData(UserModel user) async {
    _status = HomeStatus.loading;
    notifyListeners();

    try {
      final transactions = await _transactionRepository.getAll(user.id);
      final categories = CategoryModel.all;
      final categoryMap = {for (var c in categories) c.id: c};

      // Hitung summary pakai helper di Repository
      final income = _transactionRepository.calculateTotal(
        transactions,
        TransactionType.income,
      );
      final expense = _transactionRepository.calculateTotal(
        transactions,
        TransactionType.expense,
      );
      final balance = _transactionRepository.calculateBalance(
        transactions: transactions,
        initialBalance: user.initialBalance,
      );

      // Filter transaksi hari ini
      final now = DateTime.now();
      final todayTx = transactions
          .where(
            (t) =>
                t.date.year == now.year &&
                t.date.month == now.month &&
                t.date.day == now.day,
          )
          .toList();

      // Rakit TransactionItem
      final todayTransactions = todayTx
          .where((t) => categoryMap.containsKey(t.categoryId))
          .map((t) => TransactionItem.fromModels(t, categoryMap[t.categoryId]!))
          .toList();

      _homeModel = HomeModel(
        userName: user.name,
        userAvatar: user.avatarPath,
        balance: balance,
        totalIncome: income,
        totalExpense: expense,
        todayTransactions: todayTransactions,
      );

      _status = HomeStatus.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
      _status = HomeStatus.error;
    }

    notifyListeners();
  }

  // ================= CLEAR =================
  void clear() {
    _homeModel = null;
    _status = HomeStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
