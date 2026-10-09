class WalletModel {
  static const String mainId = 'wal_default';

  final String id;
  final String userId;
  final String name;
  final String iconKey;
  final int colorValue;
  final double initialBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    this.iconKey = 'wallet',
    this.colorValue = 0xFFC8FF25,
    this.initialBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isMain => id == mainId;

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    id: json['id'] ?? '',
    userId: json['user_id'] ?? '',
    name: json['name'] ?? '',
    iconKey: json['icon_key'] ?? 'wallet',
    colorValue: json['color_value'] ?? 0xFFC8FF25,
    initialBalance: (json['initial_balance'] ?? 0).toDouble(),
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'icon_key': iconKey,
    'color_value': colorValue,
    'initial_balance': initialBalance,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  WalletModel copyWith({
    String? name,
    String? iconKey,
    int? colorValue,
    double? initialBalance,
    DateTime? updatedAt,
  }) => WalletModel(
    id: id,
    userId: userId,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorValue: colorValue ?? this.colorValue,
    initialBalance: initialBalance ?? this.initialBalance,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
