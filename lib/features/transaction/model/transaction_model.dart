// features/transaction/model/transaction_form_data.dart
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';

class TransactionFormData {
  final List<CategoryModel> incomeCategories;
  final List<CategoryModel> expenseCategories;

  TransactionFormData({
    required this.incomeCategories,
    required this.expenseCategories,
  });

  List<CategoryModel> categoriesFor(TransactionType type) {
    return type == TransactionType.income
        ? incomeCategories
        : expenseCategories;
  }
}
