import 'package:danamoo/data/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  HomeProvider(this._transactionRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  
}