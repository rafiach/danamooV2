import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/models/wallet_model.dart';
import 'package:danamoo/data/sources/local/wallet_local.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../sources/local/transaction_local.dart';

class WalletRepository {
  final WalletLocalSource _local = WalletLocalSource();

  /// Ambil semua wallet. Kalau wallet utama belum ada (user lama / baru),
  /// dibuat otomatis dengan saldo awal = user.initialBalance.
  Future<List<WalletModel>> getAll(UserModel user) async {
    final wallets = await _local.getAll(user.id);
    if (wallets.any((w) => w.isMain)) return wallets;

    final now = DateTime.now();
    final main = WalletModel(
      id: WalletModel.mainId,
      userId: user.id,
      name: 'Dompet Utama',
      iconKey: 'wallet',
      initialBalance: user.initialBalance,
      createdAt: now,
      updatedAt: now,
    );
    final result = [main, ...wallets];
    await _local.saveAll(user.id, result);
    return result;
  }

  Future<WalletModel> add({
    required String userId,
    required String name,
    String iconKey = 'wallet',
    int colorValue = 0xFFC8FF25,
    double initialBalance = 0,
  }) async {
    final all = await _local.getAll(userId);
    final now = DateTime.now();
    final wallet = WalletModel(
      id: 'wal_${const Uuid().v4()}',
      userId: userId,
      name: name.trim(),
      iconKey: iconKey,
      colorValue: colorValue,
      initialBalance: initialBalance,
      createdAt: now,
      updatedAt: now,
    );
    await _local.saveAll(userId, [...all, wallet]);
    return wallet;
  }

  Future<bool> update(WalletModel updated) async {
    final all = await _local.getAll(updated.userId);
    final i = all.indexWhere((w) => w.id == updated.id);
    if (i == -1) return false;
    all[i] = updated.copyWith(updatedAt: DateTime.now());
    await _local.saveAll(updated.userId, all);
    return true;
  }

  /// Wallet utama tidak boleh dihapus.
  Future<bool> delete(String userId, String walletId) async {
    if (walletId == WalletModel.mainId) return false;

    final all = await _local.getAll(userId);
    final target = all.where((w) => w.id == walletId).firstOrNull;
    if (target == null) return false;

    // Pindahkan transaksi ke wallet utama
    await TransactionLocalSource().reassignWallet(
      userId,
      fromId: walletId,
      toId: WalletModel.mainId,
    );

    // Hapus wallet, lebur saldo awalnya ke wallet utama
    final result = <WalletModel>[];
    for (final w in all) {
      if (w.id == walletId) continue;
      result.add(
        w.isMain
            ? w.copyWith(
                initialBalance: w.initialBalance + target.initialBalance,
              )
            : w,
      );
    }
    await _local.saveAll(userId, result);
    return true;
  }

  Future<void> deleteAll(String userId) => _local.deleteAll(userId);

  /// Saldo tiap wallet = saldo awal + income - expense.
  /// Transaksi yang menunjuk wallet tak dikenal dihitung ke wallet utama.
  /// TODO (step transfer): tambah case transfer.
  Map<String, double> calculateBalances(
    List<WalletModel> wallets,
    List<TransactionModel> txs,
  ) {
    final map = {for (final w in wallets) w.id: w.initialBalance};
    String resolve(String? id) =>
        (id != null && map.containsKey(id)) ? id : WalletModel.mainId;

    for (final t in txs) {
      final from = resolve(t.walletId);
      switch (t.type) {
        case TransactionType.income:
          map[from] = (map[from] ?? 0) + t.amount;
        case TransactionType.expense:
          map[from] = (map[from] ?? 0) - t.amount;
        case TransactionType.transfer:
          final to = resolve(t.toWalletId);
          map[from] = (map[from] ?? 0) - t.amount;
          map[to] = (map[to] ?? 0) + t.amount;
      }
    }
    return map;
  }
}
