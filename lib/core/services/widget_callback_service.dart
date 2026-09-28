import 'dart:async';

import 'package:danamoo/core/services/storage_service.dart';
import 'package:danamoo/core/utils/utils.dart';
import 'package:danamoo/data/models/transaction_model.dart';
import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

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
    case 'select_category':
      final categoryId = uri.queryParameters['id'];
      if (categoryId != null) {
        await HomeWidget.saveWidgetData('selected_category', categoryId);
        await HomeWidget.updateWidget(androidName: _androidWidgetName);
      }
      break;
    case 'reset_all':
      await _resetAll();
      break;
    case 'send':
      await _send();
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

Future<void> _resetAll() async {
  await HomeWidget.saveWidgetData('pending_amount', '0');
  await HomeWidget.saveWidgetData('pending_amount_label', 'Rp 0');
  await HomeWidget.saveWidgetData('selected_category', '');
  await HomeWidget.updateWidget(androidName: _androidWidgetName);
}

Future<void> _send() async {
  final amount = await _getPendingAmount();
  final categoryId = await HomeWidget.getWidgetData<String>(
    'selected_category',
    defaultValue: '',
  );
  if (amount <= 0 || categoryId == null || categoryId.isEmpty) return;

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

  await _resetAll();
}
