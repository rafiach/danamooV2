import 'package:firebase_auth/firebase_auth.dart';
import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/data/models/user_model.dart';

/// Hasil dari setiap operasi auth
class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  AuthResult({required this.success, this.message, this.user});
}

/// Satu-satunya pintu akses data auth dari luar (provider dsb).
/// Pakai Firebase Auth untuk register/login, StorageService untuk cache session lokal.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final StorageService _storage;

  AuthRepository(this._storage) : _firebaseAuth = FirebaseAuth.instance;

  // ================= REGISTER =================
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult(success: false, message: 'Registrasi gagal');
      }

      // Update display name di Firebase
      await firebaseUser.updateDisplayName(name);

      final now = DateTime.now();
      final newUser = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        createdAt: now,
        updatedAt: now,
        // field lain pakai default value dari UserModel
      );

      // Cache user ke local storage
      await _storage.setLoggedIn(true);
      await _storage.saveUser(newUser.toJson());

      return AuthResult(success: true, user: newUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ================= LOGIN =================
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult(success: false, message: 'Login gagal');
      }

      // Cek apakah sudah ada data user di local cache
      // Kalau ada, pakai itu (supaya setting seperti currency, notif, dll terjaga)
      // Kalau tidak ada (misal install ulang), buat UserModel baru dari Firebase
      UserModel user;
      final cachedJson = _storage.getUser();

      if (cachedJson != null && cachedJson['id'] == firebaseUser.uid) {
        user = UserModel.fromJson(cachedJson);
      } else {
        final now = DateTime.now();
        user = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? email.split('@').first,
          email: email,
          createdAt: now,
          updatedAt: now,
        );
      }

      await _storage.setLoggedIn(true);
      await _storage.saveUser(user.toJson());

      return AuthResult(success: true, user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _storage.clearAuth();
  }

  // ================= GET CURRENT USER =================
  UserModel? getCurrentUser() {
    final userJson = _storage.getUser();
    if (userJson == null) return null;
    return UserModel.fromJson(userJson);
  }

  // ================= UPDATE USER =================
  // Dipanggil dari ProfileProvider saat user update setting
  Future<void> updateUser(UserModel user) async {
    await _storage.saveUser(user.toJson());

    // Sync display name ke Firebase kalau berubah
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null && firebaseUser.displayName != user.name) {
      await firebaseUser.updateDisplayName(user.name);
    }
  }

  // ================= IS LOGGED IN =================
  bool get isLoggedIn => _storage.isLoggedIn;

  // ================= FIREBASE ERROR MAPPING =================
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password minimal 6 karakter';
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'network-request-failed':
        return 'Periksa koneksi internet kamu';
      default:
        return 'Terjadi kesalahan ($code)';
    }
  }
}
