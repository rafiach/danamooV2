import 'package:flutter/material.dart';

import '../../core/constants/constant.dart';
import 'transaction_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryModel {
  final String id;
  final String name;
  final Icon icon;
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

  CategoryModel copyWith({String? name, Icon? icon}) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color,
      bgColor: bgColor,
      type: type,
    );
  }

  // ===== DEFAULT (hardcode, ID tidak boleh berubah) =====
  static const List<CategoryModel> _defaultIncome = [
    CategoryModel(
      id: 'inc_1',
      name: 'Lain-lain',
      icon: Icon(LucideIcons.wallet),
      color: Constant.incomePrime,
      bgColor: Constant.incomeSecond,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_2',
      name: 'Gaji',
      icon: Icon(LucideIcons.banknote),
      color: Constant.incomePrime,
      bgColor: Constant.incomeSecond,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_3',
      name: 'Bonus',
      icon: Icon(LucideIcons.badgeDollarSign),
      color: Constant.incomePrime,
      bgColor: Constant.incomeSecond,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_4',
      name: 'Freelance',
      icon: Icon(LucideIcons.laptop),
      color: Constant.incomePrime,
      bgColor: Constant.incomeSecond,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_5',
      name: 'Investasi',
      icon: Icon(LucideIcons.trendingUp),
      color: Constant.incomePrime,
      bgColor: Constant.incomeSecond,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_6',
      name: 'Hadiah',
      icon: Icon(LucideIcons.gift),
      color: Constant.incomePrime,
      bgColor: Constant.incomeSecond,
      type: TransactionType.income,
    ),
  ];

  static const List<CategoryModel> _defaultExpense = [
    CategoryModel(
      id: 'exp_1',
      name: 'Makanan',
      icon: Icon(LucideIcons.salad),
      color: Constant.foodsPrime,
      bgColor: Constant.foodsSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_2',
      name: 'Transportasi',
      icon: Icon(LucideIcons.carFront),
      color: Constant.transportPrime,
      bgColor: Constant.transportSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_3',
      name: 'Belanja',
      icon: Icon(LucideIcons.shoppingBag),
      color: Constant.shoppingPrime,
      bgColor: Constant.shoppingSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_4',
      name: 'Tagihan',
      icon: Icon(LucideIcons.creditCard),
      color: Constant.billsPrime,
      bgColor: Constant.billsSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_5',
      name: 'Hiburan',
      icon: Icon(LucideIcons.clapperboard),
      color: Constant.entertainPrime,
      bgColor: Constant.entertainSecond,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_7',
      name: 'Lain-lain',
      icon: Icon(LucideIcons.coins),
      color: Constant.otherPrime,
      bgColor: Constant.otherSecond,
      type: TransactionType.expense,
    ),
  ];

  // ===== PILIHAN IKON UNTUK USER =====
  // Kalau ada nama yang error di versi lucide_icons_flutter kamu, hapus/ganti barisnya.
  static const Map<String, IconData> iconOptions = {
    'wallet': LucideIcons.wallet,
    'salad': LucideIcons.salad,
    'carFront': LucideIcons.carFront,
    'shoppingBag': LucideIcons.shoppingBag,
    'creditCard': LucideIcons.creditCard,
    'clapperboard': LucideIcons.clapperboard,
    'coins': LucideIcons.coins,
    'banknote': LucideIcons.banknote,
    'badgeDollarSign': LucideIcons.badgeDollarSign,
    'laptop': LucideIcons.laptop,
    'trendingUp': LucideIcons.trendingUp,
    'gift': LucideIcons.gift,
    'utensils': LucideIcons.utensils,
    'coffee': LucideIcons.coffee,
    'bus': LucideIcons.bus,
    'house': LucideIcons.house,
    'heart': LucideIcons.heart,
    'gamepad2': LucideIcons.gamepad2,
    'briefcase': LucideIcons.briefcase,
    'graduationCap': LucideIcons.graduationCap,
    'plane': LucideIcons.plane,
    'smartphone': LucideIcons.smartphone,
    'zap': LucideIcons.zap,
    'piggyBank': LucideIcons.piggyBank,
  };

  // ===== OVERRIDE DARI USER: id -> {name, icon} =====
  static Map<String, Map<String, String>> _overrides = {};

  static Map<String, Map<String, String>> get overrides =>
      Map.unmodifiable(_overrides);

  static void setOverrides(Map<String, dynamic> raw) {
    _overrides = raw.map(
      (id, v) => MapEntry(id, Map<String, String>.from(v as Map)),
    );
  }

  static CategoryModel _apply(CategoryModel c) {
    final o = _overrides[c.id];
    if (o == null) return c;
    final iconData = iconOptions[o['icon']];
    return c.copyWith(
      name: o['name'],
      icon: iconData != null ? Icon(iconData) : null,
    );
  }

  // ===== GETTER PUBLIK (API lama tetap sama) =====
  static List<CategoryModel> get incomeCategories =>
      _defaultIncome.map(_apply).toList();

  static List<CategoryModel> get expenseCategories =>
      _defaultExpense.map(_apply).toList();

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
