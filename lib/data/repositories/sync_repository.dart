import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/sources/local/transaction_local.dart';
import 'package:danamoo/data/sources/remote/sync_remote.dart';

class SyncResult {
  final bool success;
  final String? message;

  SyncResult({required this.success, this.message});
}

/// Mengatur operasi backup dan restore antara local dan remote.
class SyncRepository {
  final SyncRemoteSource _remote;
  final TransactionLocalSource _local;
  final StorageService _storage;

  SyncRepository(this._storage)
    : _remote = SyncRemoteSource(),
      _local = TransactionLocalSource();

  // ================= BACKUP =================
  Future<SyncResult> backup({
    required UserModel user,
    required String userId,
  }) async {
    try {
      final transactions = await _local.getAll(userId);

      final success = await _remote.backup(
        user: user,
        transactions: transactions,
      );

      if (!success) {
        return SyncResult(success: false, message: 'Backup ke server gagal');
      }

      // Update lastBackupAt di local storage
      final updatedUser = user.copyWith(lastBackupAt: DateTime.now());
      await _storage.saveUser(updatedUser.toJson());

      return SyncResult(success: true);
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ================= RESTORE =================
  Future<SyncResult> restore(String userId) async {
    try {
      final result = await _remote.restore(userId);

      if (result.user == null) {
        return SyncResult(
          success: false,
          message: 'Tidak ada data backup ditemukan',
        );
      }

      // Timpa data lokal dengan data dari remote
      await _local.saveAll(userId, result.transactions);
      await _storage.saveUser(result.user!.toJson());

      return SyncResult(success: true);
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ================= LAST BACKUP TIME =================
  DateTime? getLastBackupAt() {
    final userJson = _storage.getUser();
    if (userJson == null) return null;
    final raw = userJson['last_backup_at'];
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
