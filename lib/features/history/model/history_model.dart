import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';

class HistoryListItem {
  final TransactionModel transaction;
  final CategoryModel? category;

  HistoryListItem({required this.transaction, this.category});
}
