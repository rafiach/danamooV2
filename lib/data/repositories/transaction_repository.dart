import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/sources/local/transaction_local.dart';

/// Satu-satunya pintu akses data transaksi dari luar (provider dsb).
/// Provider tidak perlu tahu data datang dari mana — local atau remote.
class TransactionRepository {
  final TransactionLocalSource _local;

  TransactionRepository() : _local = TransactionLocalSource();

  // ================= GET ALL =================
  Future<List<TransactionModel>> getAll(String userId) async {
    final transactions = await _local.getAll(userId);
    // Sort newest first — logika bisnis ada di sini, bukan di provider
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // ================= GET BY DATE RANGE =================
  Future<List<TransactionModel>> getByDateRange(
    String userId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final transactions = await _local.getByDateRange(
      userId,
      from: from,
      to: to,
    );
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // ================= GET TODAY =================
  Future<List<TransactionModel>> getToday(String userId) async {
    final transactions = await _local.getToday(userId);
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // ================= ADD =================
  Future<TransactionModel?> add({
    required String userId,
    required String categoryId,
    required TransactionType type,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    return _local.add(
      userId: userId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      note: note,
      date: date,
    );
  }

  // ================= UPDATE =================
  Future<bool> update(TransactionModel transaction) async {
    final updated = transaction.copyWith(updatedAt: DateTime.now());
    return _local.update(updated);
  }

  // ================= DELETE =================
  Future<bool> delete(String userId, String transactionId) async {
    return _local.delete(userId, transactionId);
  }

  // ================= SAVE ALL (FOR RESTORE) =================
  Future<void> saveAll(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    return _local.saveAll(userId, transactions);
  }

  // ================= CALCULATE BALANCE =================
  // Logika hitung saldo ada di Repository, bukan Provider
  double calculateBalance({
    required List<TransactionModel> transactions,
    required double initialBalance,
  }) {
    final total = transactions.fold<double>(0, (sum, t) {
      return t.type == TransactionType.income ? sum + t.amount : sum - t.amount;
    });
    return initialBalance + total;
  }

  // ================= CALCULATE TOTAL BY TYPE =================
  double calculateTotal(
    List<TransactionModel> transactions,
    TransactionType type,
  ) {
    return transactions
        .where((t) => t.type == type)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // ================= DELETE ALL =================
  Future<void> deleteAll(String userId) async {
    return _local.deleteAll(userId);
  }
}
