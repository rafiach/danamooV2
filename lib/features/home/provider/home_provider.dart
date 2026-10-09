import 'package:danamoo/data/repositories/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:danamoo/features/home/model/home_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/constant.dart';
import '../../../data/models/wallet_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;

  HomeStatus _status = HomeStatus.initial;
  HomeModel? _homeModel;
  String? _errorMessage;

  HomeProvider({
    required TransactionRepository transactionRepository,
    required WalletRepository walletRepository,
  }) : _transactionRepository = transactionRepository,
       _walletRepository = walletRepository;

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
      final wallets = await _walletRepository.getAll(user);
      final balances = _walletRepository.calculateBalances(
        wallets,
        transactions,
      );
      final balance = balances.values.fold<double>(0, (a, b) => a + b);
      // sesudah
      String resolveWallet(String? id) =>
          (id != null && balances.containsKey(id)) ? id : WalletModel.mainId;

      final walletItems = wallets.map((w) {
        final txs = transactions.where(
          (t) => resolveWallet(t.walletId) == w.id,
        );
        return WalletItem(
          wallet: w,
          balance: balances[w.id] ?? 0,
          income: _transactionRepository.calculateTotal(
            txs.toList(),
            TransactionType.income,
          ),
          expense: _transactionRepository.calculateTotal(
            txs.toList(),
            TransactionType.expense,
          ),
        );
      }).toList();

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
      final walletNames = {for (final w in wallets) w.id: w.name};
      String nameOf(String? id) =>
          walletNames[id] ?? walletNames[WalletModel.mainId] ?? 'Dompet Utama';

      final todayTransactions = todayTx
          .map((t) {
            if (t.type == TransactionType.transfer) {
              return TransactionItem(
                id: t.id,
                label: 'Transfer',
                icon: const Icon(LucideIcons.arrowLeftRight),
                color: Constant.greyLight,
                amount: t.amount,
                date: t.date,
                note: t.note,
                type: t.type,
                extra: '${nameOf(t.walletId)} → ${nameOf(t.toWalletId)}',
              );
            }
            final cat = categoryMap[t.categoryId];
            return cat == null ? null : TransactionItem.fromModels(t, cat);
          })
          .whereType<TransactionItem>()
          .toList();

      _homeModel = HomeModel(
        userName: user.name,
        userAvatar: user.avatarPath,
        balance: balance,
        totalIncome: income,
        totalExpense: expense,
        todayTransactions: todayTransactions,
        walletItems: walletItems,
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
