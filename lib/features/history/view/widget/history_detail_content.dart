import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/utils/utils.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../generated/assets.dart';

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
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Image.asset(
                _isIncome
                    ? Assets.assetsIconsIncome
                    : Assets.assetsIconsExpense,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              Text(
                _isIncome ? 'Income' : 'Expense',
                style: Constant.textBold.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Divider(color: Constant.greyLight),
        const SizedBox(height: 24),

        _buildDetailRow(
          'Amount',
          '$currency ${Utils.formatIDR(transaction.amount)}',
          isBold: true,
          valueColor: _isIncome ? Constant.violetDarker : Constant.error,
        ),
        const SizedBox(height: 20),

        _buildDetailRow('Date', Utils.formatDateShort(transaction.date)),
        const SizedBox(height: 20),

        if (!_isIncome && category != null) ...[
          _buildDetailRow('Category', category!.name),
          const SizedBox(height: 20),
        ],

        _buildDetailRow(
          'Description',
          transaction.note?.isNotEmpty == true ? transaction.note! : '-',
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Constant.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 20 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
