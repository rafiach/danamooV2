import 'dart:convert';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TransactionLocalSource {
  static const _keyPrefix = 'transactions_';

  // Key per user supaya data tidak campur
  String _key(String userId) => '$_keyPrefix$userId';

  // ================= GET ALL =================
  Future<List<TransactionModel>> getAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];

    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => TransactionModel.fromJson(e)).toList();
  }

  // ================= GET BY DATE RANGE =================
  Future<List<TransactionModel>> getByDateRange(
    String userId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final all = await getAll(userId);
    return all
        .where(
          (t) =>
              t.date.isAfter(from.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(to.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  // ================= GET TODAY =================
  Future<List<TransactionModel>> getToday(String userId) async {
    final now = DateTime.now();
    return getByDateRange(
      userId,
      from: DateTime(now.year, now.month, now.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getAll(userId);

      final now = DateTime.now();
      final newTx = TransactionModel(
        id: const Uuid().v4(),
        userId: userId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        note: note,
        date: date ?? now,
        createdAt: now,
        updatedAt: now,
      );

      all.add(newTx);
      await prefs.setString(
        _key(userId),
        jsonEncode(all.map((e) => e.toJson()).toList()),
      );
      return newTx;
    } catch (_) {
      return null;
    }
  }

  // ================= UPDATE =================
  Future<bool> update(TransactionModel updated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getAll(updated.userId);

      final index = all.indexWhere((t) => t.id == updated.id);
      if (index == -1) return false;

      all[index] = updated;
      await prefs.setString(
        _key(updated.userId),
        jsonEncode(all.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= DELETE =================
  Future<bool> delete(String userId, String transactionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = await getAll(userId);

      final filtered = all.where((t) => t.id != transactionId).toList();
      await prefs.setString(
        _key(userId),
        jsonEncode(filtered.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= SAVE ALL (FOR RESTORE) =================
  Future<void> saveAll(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(userId),
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }
}
