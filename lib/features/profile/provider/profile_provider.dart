import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/repositories/auth_repository.dart';
import 'package:danamoo/data/repositories/sync_repository.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:danamoo/features/profile/model/profile_model.dart';

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SyncRepository _syncRepository;
  final TransactionRepository _transactionRepository;

  ProfileStatus _status = ProfileStatus.initial;
  ProfileModel? _profileModel;
  String? _errorMessage;

  ProfileProvider({
    required AuthRepository authRepository,
    required SyncRepository syncRepository,
    required TransactionRepository transactionRepository,
  }) : _authRepository = authRepository,
       _syncRepository = syncRepository,
       _transactionRepository = transactionRepository;

  ProfileStatus get status => _status;
  ProfileModel? get profileModel => _profileModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSaving => _status == ProfileStatus.saving;

  // ================= LOAD =================
  void load() {
    final user = _authRepository.getCurrentUser();
    if (user == null) return;

    _profileModel = _toProfileModel(user);
    _status = ProfileStatus.loaded;
    notifyListeners();
  }

  // ================= UPDATE PROFILE =================
  Future<bool> updateProfile({
    String? name,
    String? currency,
    String? avatarPath,
    String? themeMode,
    bool? notifEnabled,
    String? notifTime,
  }) async {
    if (_profileModel == null) return false;
    _status = ProfileStatus.saving;
    notifyListeners();

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      _status = ProfileStatus.error;
      _errorMessage = 'User tidak ditemukan';
      notifyListeners();
      return false;
    }

    final updated = user.copyWith(
      name: name,
      currency: currency,
      avatarPath: avatarPath,
      themeMode: themeMode,
      notifEnabled: notifEnabled,
      notifTime: notifTime,
      updatedAt: DateTime.now(),
    );

    try {
      await _authRepository.updateUser(updated);
      _profileModel = _toProfileModel(updated);
      _status = ProfileStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'Gagal menyimpan perubahan';
    }

    notifyListeners();
    return _status == ProfileStatus.loaded;
  }

  // ================= UPDATE INITIAL BALANCE =================
  Future<bool> updateInitialBalance(double amount) async {
    if (_profileModel == null) return false;
    _status = ProfileStatus.saving;
    notifyListeners();

    final user = _authRepository.getCurrentUser();
    if (user == null) return false;

    final updated = user.copyWith(
      initialBalance: amount,
      updatedAt: DateTime.now(),
    );

    try {
      await _authRepository.updateUser(updated);
      _profileModel = _profileModel!.copyWith(initialBalance: amount);
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'Gagal update saldo awal';
    }

    notifyListeners();
    return _status == ProfileStatus.loaded;
  }

  // ================= EXPORT EXCEL =================
  Future<void> exportDataToExcel(String userId, {bool isShare = false}) async {
    final transactions = await _transactionRepository.getAll(userId);
    final categoryMap = {for (var c in CategoryModel.all) c.id: c.name};

    var excel = Excel.createExcel();
    Sheet sheet = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    sheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('Tipe'),
      TextCellValue('Kategori'),
      TextCellValue('Deskripsi'),
      TextCellValue('Nominal'),
    ]);

    for (var tx in transactions) {
      sheet.appendRow([
        TextCellValue(tx.date.toIso8601String()),
        TextCellValue(tx.type.name),
        TextCellValue(categoryMap[tx.categoryId] ?? 'Tidak Diketahui'),
        TextCellValue(tx.note ?? '-'),
        DoubleCellValue(tx.amount),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes == null) return;

    if (isShare) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Laporan_Transaksi.xlsx';
      await File(filePath).writeAsBytes(fileBytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Berikut adalah laporan transaksi Anda.',
        ),
      );
    } else {
      await FileSaver.instance.saveAs(
        name: 'Laporan_Transaksi',
        bytes: Uint8List.fromList(fileBytes),
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }

  // ================= BACKUP =================
  Future<bool> backupData() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) return false;

    _status = ProfileStatus.saving;
    notifyListeners();

    final result = await _syncRepository.backup(user: user, userId: user.id);

    if (result.success) {
      // Update lastBackupAt di local
      await _authRepository.updateUser(
        user.copyWith(lastBackupAt: DateTime.now()),
      );
      load(); // reload untuk update UI
    } else {
      _status = ProfileStatus.error;
      _errorMessage = result.message ?? 'Gagal melakukan backup data';
      notifyListeners();
    }

    return result.success;
  }

  // ================= RESTORE =================
  Future<bool> restoreData() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) return false;

    _status = ProfileStatus.saving;
    notifyListeners();

    final result = await _syncRepository.restore(user.id);
    load();
    return result.success;
  }

  // ================= HELPER =================
  ProfileModel _toProfileModel(UserModel user) {
    return ProfileModel(
      id: user.id,
      name: user.name,
      email: user.email,
      currency: user.currency,
      avatarPath: user.avatarPath,
      themeMode: user.themeMode,
      notifEnabled: user.notifEnabled,
      notifTime: user.notifTime,
      initialBalance: user.initialBalance,
      lastBackupAt: user.lastBackupAt,
      createdAt: user.createdAt,
    );
  }

  void clear() {
    _profileModel = null;
    _status = ProfileStatus.initial;
    notifyListeners();
  }
}
