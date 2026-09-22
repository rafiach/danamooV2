import 'package:flutter/material.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/models/user_model.dart';
import 'package:danamoo/data/repositories/auth_repository.dart';
import 'package:danamoo/data/repositories/sync_repository.dart';

import '../../../data/repositories/transaction_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  late final AuthRepository _authRepository;
  late final SyncRepository _syncRepository;
  late final TransactionRepository _transactionRepository;
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ================= INIT SERVICE =================
  void initService(
    StorageService storage,
    TransactionRepository transactionRepo,
  ) {
    _authRepository = AuthRepository(storage);
    _syncRepository = SyncRepository(storage);
    _transactionRepository = transactionRepo;
  }

  // ================= CHECK SESSION =================
  Future<void> checkSession() async {
    _status = AuthStatus.loading;
    notifyListeners();

    if (_authRepository.isLoggedIn) {
      _user = _authRepository.getCurrentUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // ================= LOGIN =================
  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    if (result.success) {
      // Auto restore dari cloud saat login
      if (result.user != null) {
        await _syncRepository.restore(result.user!.id);
        // Ambil ulang user dari storage karena restore mungkin timpa data
        _user = _authRepository.getCurrentUser() ?? result.user;
      }
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.message;
    }

    notifyListeners();
    return result.success;
  }

  Future<bool> loginWithGoogle() async {
    _setLoading();

    final result = await _authRepository.loginWithGoogle();

    if (result.success) {
      if (result.user != null) {
        await _syncRepository.restore(result.user!.id);
        _user = _authRepository.getCurrentUser() ?? result.user;
      }
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.message;
    }

    notifyListeners();
    return result.success;
  }

  // ================= REGISTER =================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _authRepository.register(
      name: name,
      email: email,
      password: password,
    );

    if (result.success) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.message;
    }

    notifyListeners();
    return result.success;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _setLoading();
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
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
    double? initialBalance,
    DateTime? lastBackupAt,
  }) async {
    if (_user == null) return false;
    _setLoading();

    final updatedUser = _user!.copyWith(
      name: name,
      currency: currency,
      avatarPath: avatarPath,
      themeMode: themeMode,
      notifEnabled: notifEnabled,
      notifTime: notifTime,
      initialBalance: initialBalance,
      lastBackupAt: lastBackupAt,
      updatedAt: DateTime.now(),
    );

    try {
      await _authRepository.updateUser(updatedUser);
      _user = updatedUser;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Gagal memperbarui profil';
      notifyListeners();
      return false;
    }
  }

  // ================= DELETE ACCOUNT =================
  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    _setLoading();

    final userId = _user!.id;

    await _syncRepository.deleteRemoteData(userId);
    await _transactionRepository.deleteAll(userId);

    final result = await _authRepository.deleteAccount();

    if (result.success) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.message;
    }

    notifyListeners();
    return result.success;
  }

  // ================= CLEAR ERROR =================
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ================= INTERNAL =================
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
