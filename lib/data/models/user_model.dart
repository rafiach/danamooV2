class UserModel {
  final String id;
  final String name;
  final String email;
  final String currency;
  final String? avatarPath;
  final String themeMode;
  final bool notifEnabled;
  final String notifTime;
  final double initialBalance;
  final DateTime? lastBackupAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.currency = 'IDR',
    this.avatarPath,
    this.themeMode = 'system',
    this.notifEnabled = true,
    this.notifTime = '20:00',
    this.initialBalance = 0,
    this.lastBackupAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // ================= FROM JSON =================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      currency: json['currency'] ?? 'IDR',
      avatarPath: json['avatar_path'],
      themeMode: json['theme_mode'] ?? 'system',
      notifEnabled: json['notif_enabled'] ?? true,
      notifTime: json['notif_time'] ?? '20:00',
      initialBalance: (json['initial_balance'] ?? 0).toDouble(),
      lastBackupAt: json['last_backup_at'] != null
          ? DateTime.parse(json['last_backup_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
      'avatar_path': avatarPath,
      'theme_mode': themeMode,
      'notif_enabled': notifEnabled,
      'notif_time': notifTime,
      'initial_balance': initialBalance,
      'last_backup_at': lastBackupAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ================= COPY WITH =================
  // Berguna untuk update sebagian data tanpa ubah semua field
  UserModel copyWith({
    String? name,
    String? email,
    String? currency,
    String? avatarPath,
    String? themeMode,
    bool? notifEnabled,
    String? notifTime,
    double? initialBalance,
    DateTime? lastBackupAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      avatarPath: avatarPath ?? this.avatarPath,
      themeMode: themeMode ?? this.themeMode,
      notifEnabled: notifEnabled ?? this.notifEnabled,
      notifTime: notifTime ?? this.notifTime,
      initialBalance: initialBalance ?? this.initialBalance,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
