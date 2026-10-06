import '../../data/models/wallet_model.dart';

/// Dompet tujuan transfer yang valid: tidak boleh sama dengan dompet asal.
String? resolveToWalletId(
  List<WalletModel> wallets,
  String fromId,
  String? currentToId,
) {
  final others = wallets.where((w) => w.id != fromId).toList();
  if (currentToId != null && others.any((w) => w.id == currentToId)) {
    return currentToId;
  }
  return others.isEmpty ? null : others.first.id;
}
