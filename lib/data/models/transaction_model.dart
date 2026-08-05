enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String userId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (json['amount'] ?? 0).toDouble(),
      note: json['note'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'category_id': categoryId,
    'type': type.name,
    'amount': amount,
    'note': note,
    'date': date.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Tambahkan di dalam class TransactionModel, setelah toJson()
  TransactionModel copyWith({
    String? categoryId,
    TransactionType? type,
    double? amount,
    String? note,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
