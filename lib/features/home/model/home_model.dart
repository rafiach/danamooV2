import 'package:flutter/material.dart';
import 'package:danamoo/data/models/category_model.dart';
import 'package:danamoo/data/models/transaction_model.dart';

import '../../../data/models/wallet_model.dart';

class TransactionItem {
  final String id;
  final String label;
  final Icon icon;
  final Color color;
  final double amount;
  final DateTime date;
  final String? note;
  final TransactionType type;
  final String? extra;

  TransactionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
    required this.date,
    this.note,
    required this.type,
    this.extra,
  });

  factory TransactionItem.fromModels(
    TransactionModel tx,
    CategoryModel category,
  ) {
    return TransactionItem(
      id: tx.id,
      label: category.name,
      icon: category.icon,
      color: category.bgColor,
      amount: tx.amount,
      date: tx.date,
      note: tx.note,
      type: tx.type,
    );
  }
}

class WalletItem {
  final WalletModel wallet;
  final double balance;
  final double income;
  final double expense;
  WalletItem({
    required this.wallet,
    required this.balance,
    this.income = 0,
    this.expense = 0,
  });
}

class HomeModel {
  final String userName;
  final String? userAvatar;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionItem> todayTransactions;
  final List<WalletItem> walletItems;

  HomeModel({
    required this.userName,
    this.userAvatar,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.todayTransactions,
    required this.walletItems,
  });
}
