import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/models/wallet_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:danamoo/data/repositories/wallet_repository.dart';
import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  final WalletRepository _repo;
  final TransactionRepository _txRepo;
  WalletProvider({
    required WalletRepository walletRepository,
    required TransactionRepository transactionRepository,
  }) : _repo = walletRepository,
       _txRepo = transactionRepository;

  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? errorMessage;

  Map<String, double> _balance = {};
  double balanceOf(String id) => _balance[id] ?? 0;

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  WalletModel? get mainWallet => _wallets.where((w) => w.isMain).firstOrNull;

  WalletModel? getById(String id) =>
      _wallets.where((w) => w.id == id).firstOrNull;

  String nameOf(String? id) =>
      getById(id ?? '')?.name ?? mainWallet?.name ?? 'Dompet Utama';

  Future<void> load(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    try {
      _wallets = await _repo.getAll(user);
      final txs = await _txRepo.getAll(user.id);
      _balance = _repo.calculateBalances(wallets, txs);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat wallet';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add(
    UserModel user, {
    required String name,
    String iconKey = 'wallet',
    int colorValue = 0xFFC8FF25,
    double initialBalance = 0,
  }) async {
    if (name.trim().isEmpty) return false;
    await _repo.add(
      userId: user.id,
      name: name,
      iconKey: iconKey,
      colorValue: colorValue,
      initialBalance: initialBalance,
    );
    await load(user);
    return true;
  }

  Future<bool> update(UserModel user, WalletModel wallet) async {
    final ok = await _repo.update(wallet);
    if (ok) await load(user);
    return ok;
  }

  Future<bool> delete(UserModel user, String walletId) async {
    final ok = await _repo.delete(user.id, walletId);
    if (ok) await load(user);
    return ok;
  }

  void clear() {
    _wallets = [];
    notifyListeners();
  }
}
