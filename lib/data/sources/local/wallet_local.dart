import 'dart:convert';

import 'package:danamoo/data/models/wallet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletLocalSource {
  static const _keyprefix = 'wallets_';
  String _key(String userId) => '$_keyprefix$userId';

  Future<List<WalletModel>> getAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => WalletModel.fromJson(e)).toList();
  }

  Future<void> saveAll(String userId, List<WalletModel> wallets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(userId),
      jsonEncode(wallets.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
