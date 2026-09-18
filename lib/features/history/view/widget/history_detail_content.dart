import 'package:flutter/material.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Card
        CustomCard.surface(
          borderRadius: 20,
          color: Constant.greyLight,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isIncome
                          ? Constant.limeAccent.withValues(alpha: 0.15)
                          : Constant.expenseRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: Constant.captionBold.copyWith(
                        color: _isIncome
                            ? Constant.limeAccent
                            : Constant.expenseRed,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Utils.formatDateTimeComplete(transaction.date),
                    style: Constant.caption.copyWith(
                      color: Constant.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '${_isIncome ? '+' : '-'} ${Utils.formatIDR(transaction.amount)}',
                      style: Constant.h2.copyWith(
                        fontSize: 28,
                        color: _isIncome
                            ? Constant.incomeGreenAccentDark
                            : Constant.expenseRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!_isIncome && category != null) ...[
          CustomCard.surface(
            borderRadius: 20,
            color: Constant.greyLight,
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
                        'Kategori',
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
        const SizedBox(height: 16),

        // Description Card
        SizedBox(
          width: double.infinity,
          child: CustomCard.surface(
            borderRadius: 20,
            color: Constant.greyLight,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi',
                  style: Constant.textSemiBold.copyWith(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
