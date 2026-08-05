import 'package:flutter/material.dart';

import '../../core/constants/constant.dart';
import '../../generated/assets.dart';
import 'transaction_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final Color bgColor;
  final TransactionType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.type,
  });

  // ===== STATIC DATA KATEGORI =====
  static const List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 'inc_1',
      name: 'Income',
      icon: Assets.assetsIconsCoin,
      color: Constant.incomePrime,
      bgColor: Constant.transportSecond,
      type: TransactionType.income,
    ),
  ];

  static const List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 'exp_1',
      name: 'Makanan & Minuman',
      icon: Assets.assetsIconsHamburger,
      color: Constant.foodsPrime,
      bgColor: Constant.foodsSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_2',
      name: 'Transportasi',
      icon: Assets.assetsIconsBus,
      color: Constant.transportPrime,
      bgColor: Constant.transportSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_3',
      name: 'Belanja',
      icon: Assets.assetsIconsShoppingBag,
      color: Constant.shoppingPrime,
      bgColor: Constant.shoppingSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_4',
      name: 'Tagihan',
      icon: Assets.assetsIconsCreditCard,
      color: Constant.billsPrime,
      bgColor: Constant.billsSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_5',
      name: 'Hiburan',
      icon: Assets.assetsIconsController,
      color: Constant.entertainPrime,
      bgColor: Constant.entertainSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_7',
      name: 'Lain-lain',
      icon: Assets.assetsIconsCoin,
      color: Constant.otherPrime,
      bgColor: Constant.otherSecond,
      type: TransactionType.expense,
    ),
  ];

  static List<CategoryModel> get all => [
    ...incomeCategories,
    ...expenseCategories,
  ];

  static CategoryModel? getById(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }
}
