import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';

/// Menampilkan detail transaksi dalam mode read-only.
class HistoryDetailContent extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final String currency;

  const HistoryDetailContent({
    super.key,
    required this.transaction,
    required this.category,
    required this.currency,
  });

  bool get _isIncome => transaction.type == TransactionType.income;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _headerInfo(),
            const SizedBox(height: 32),
            if (category != null) ...[
              CustomCard.surface(
                borderRadius: 20,
                color: Constant.surfaceCard,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Constant.limeAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: category!.icon,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isIncome ? 'Sumber Pemasukan' : 'Kategori',
                            style: Constant.caption.copyWith(
                              color: Constant.textSecondary,
                            ),
                          ),
                          Text(
                            category!.name,
                            style: Constant.textSemiBold.copyWith(
                              color: Constant.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomCard.surface(
                borderRadius: 20,
                color: Constant.surfaceCard,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal & Waktu',
                      style: Constant.textSemiBold.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Constant.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Utils.formatDateWithDay(transaction.date),
                      style: Constant.textBold.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Constant.textPrimary,
                      ),
                    ),
                    Text(
                      Utils.formatDateTimeToTime(transaction.date),
                      style: Constant.textBold.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Constant.textPrimary,
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Constant.surfaceDark.withValues(alpha: 0.4),
                    ),
                    Text(
                      'Deskripsi',
                      style: Constant.textBold.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Constant.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.note?.isNotEmpty == true
                          ? transaction.note!
                          : 'Tidak ada catatan',
                      style: Constant.bodyMedium.copyWith(
                        color: transaction.note?.isNotEmpty == true
                            ? Constant.textPrimary
                            : Constant.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerInfo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Constant.surfaceDark,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isIncome
                    ? LucideIcons.moveDownLeft400
                    : LucideIcons.moveUpRight400,
                color: Constant.limeAccent,
              ),
              const SizedBox(width: 8),
              Text(
                _isIncome ? 'Pemasukan' : 'Pengeluaran',
                style: Constant.captionBold.copyWith(
                  color: Constant.limeAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${_isIncome ? '+' : '-'} ${Utils.formatIDR(transaction.amount)}',
          textAlign: TextAlign.center,
          style: Constant.h2.copyWith(
            fontSize: 44,
            color: Constant.surfaceDark,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 10),
        Container(
          width: 56,
          height: 8,
          decoration: BoxDecoration(
            color: Constant.limeAccent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
