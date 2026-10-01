import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/models/user_model.dart';

class SyncRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= BACKUP =================
  Future<bool> backup({
    required UserModel user,
    required List<TransactionModel> transactions,
    required Map<String, dynamic> categoryOverrides,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(user.id);
      await userRef.set({
        ...user.toJson(),
        'category_override': categoryOverrides,
      });

      final batch = _firestore.batch();
      final txCollection = userRef.collection('transactions');
      for (var tx in transactions) {
        batch.set(txCollection.doc(tx.id), tx.toJson());
      }
      await batch.commit();

      return true;
    } catch (e) {
      return false;
    }
  }

  // ================= RESTORE =================
  Future<
    ({
      UserModel? user,
      List<TransactionModel> transactions,
      Map<String, dynamic>? categoryOverrides,
    })
  >
  restore(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists || userDoc.data() == null) {
        return (
          user: null,
          transactions: <TransactionModel>[],
          categoryOverrides: null,
        );
      }

      final data = userDoc.data()!;
      final user = UserModel.fromJson(data);

      // null = backup lama yang belum punya field ini, jangan timpa data lokal
      final rawOverrides = data['category_overrides'];
      final categoryOverrides = rawOverrides is Map
          ? Map<String, dynamic>.from(rawOverrides)
          : null;

      final txSnapshot = await userRef.collection('transactions').get();
      final transactions = txSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();

      return (
        user: user,
        transactions: transactions,
        categoryOverrides: categoryOverrides,
      );
    } catch (e) {
      return (
        user: null,
        transactions: <TransactionModel>[],
        categoryOverrides: null,
      );
    }
  }

  // ================= DELETE USER DATA =================
  Future<void> deleteUserData(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final txSnapshot = await userRef.collection('transactions').get();

    final batch = _firestore.batch();
    for (var doc in txSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(userRef);
    await batch.commit();
  }
}
