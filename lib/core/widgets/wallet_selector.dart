import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/wallet_model.dart';
import '../constants/constant.dart';

/// Peta iconKey (disimpan di WalletModel) -> IconData.
/// Tambah key baru di sini kalau nanti ada pilihan ikon di form wallet.
class WalletIcons {
  static IconData of(String key) {
    switch (key) {
      case 'cash':
        return LucideIcons.banknote;
      case 'bank':
        return LucideIcons.landmark;
      case 'card':
        return LucideIcons.creditCard;
      case 'phone':
        return LucideIcons.smartphone;
      default:
        return LucideIcons.wallet;
    }
  }
}

class WalletSelector extends StatelessWidget {
  final List<WalletModel> wallets;
  final String selectedId;
  final ValueChanged<WalletModel> onChanged;

  const WalletSelector({
    super.key,
    required this.wallets,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Kalau selectedId tidak ditemukan (wallet terhapus), anggap wallet utama
    final effectiveId = wallets.any((w) => w.id == selectedId)
        ? selectedId
        : WalletModel.mainId;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: wallets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final w = wallets[i];
          final isSelected = w.id == effectiveId;
          return GestureDetector(
            onTap: () => onChanged(w),
            child: AnimatedContainer(
              duration: Constant.durationShort,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Constant.surfaceDark : Constant.surfaceCard,
                border: Border.all(
                  color: isSelected
                      ? Constant.surfaceDark
                      : Constant.borderSubtle,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    WalletIcons.of(w.iconKey),
                    size: 18,
                    color: isSelected
                        ? Constant.limeAccent
                        : Constant.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    w.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Constant.limeAccent
                          : Constant.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
