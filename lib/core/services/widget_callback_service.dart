import 'dart:async';

import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/core/utils/utils.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/widgets.dart';

const String _androidWidgetName = 'DanamooWidgetProvider';

@pragma('vm:entry-point')
FutureOr<void> widgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri == null) return;

  switch (uri.host) {
    case 'add_amount':
      final value = int.tryParse(uri.queryParameters['value'] ?? '') ?? 0;
      final current = await _getPendingAmount();
      await _setPendingAmount(current + value);
      break;
    case 'reset_amount':
      await _setPendingAmount(0);
      break;
    case 'save_expense':
      final categoryId = uri.queryParameters['category'];
      if (categoryId != null) await _saveExpense(categoryId);
      break;
  }
}

Future<int> _getPendingAmount() async {
  final raw = await HomeWidget.getWidgetData<String>(
    'pending_amount',
    defaultValue: '0',
  );
  return int.tryParse(raw ?? '0') ?? 0;
}

Future<void> _setPendingAmount(int amount) async {
  await HomeWidget.saveWidgetData('pending_amount', amount.toString());
  await HomeWidget.saveWidgetData(
    'pending_amount_label',
    Utils.formatIDR(amount.toDouble()),
  );
  await HomeWidget.updateWidget(androidName: _androidWidgetName);
}

Future<void> _saveExpense(String categoryId) async {
  final amount = await _getPendingAmount();
  if (amount <= 0) return;

  final storage = await StorageService.getInstance();
  final user = storage.getUser();
  final userId = user?['id'] as String?;
  if (userId == null) return;

  await TransactionRepository().add(
    userId: userId,
    categoryId: categoryId,
    type: TransactionType.expense,
    amount: amount.toDouble(),
  );

  await _setPendingAmount(0);
}
