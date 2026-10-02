import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/models/user_model.dart';

class SyncRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _batchLimit = 400;

  Future<void> _commitInChunks<T>(
    List<T> items,
    void Function(WriteBatch batch, T item) apply,
  ) async {
    for (var i = 0; i < items.length; i += _batchLimit) {
      final batch = _firestore.batch();
      for (final item in items.skip(i).take(_batchLimit)) {
        apply(batch, item);
      }
      await batch.commit();
    }
  }

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
        'category_overrides': categoryOverrides,
      });

      final txCollection = userRef.collection('transactions');

      // Hapus dokumen cloud yang sudah dihapus di lokal, kalau tidak transaksi
      // itu muncul lagi saat restore. Dilewati kalau lokal kosong, supaya HP
      // baru yang belum sempat restore tidak mengosongkan backup.
      if (transactions.isNotEmpty) {
        final localIds = transactions.map((t) => t.id).toSet();
        final remote = await txCollection.get();
        final stale = remote.docs
            .where((d) => !localIds.contains(d.id))
            .map((d) => d.reference)
            .toList();
        await _commitInChunks(stale, (batch, ref) => batch.delete(ref));
      }

      await _commitInChunks(
        transactions,
        (batch, tx) => batch.set(txCollection.doc(tx.id), tx.toJson()),
      );

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

    await _commitInChunks(
      txSnapshot.docs.map((d) => d.reference).toList(),
      (batch, ref) => batch.delete(ref),
    );
    // Dokumen user dihapus terakhir, jadi kalau gagal di tengah masih bisa diulang
    await userRef.delete();
  }
}
