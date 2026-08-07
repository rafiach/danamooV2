// Model khusus untuk ProfileView — sama konsepnya dengan HomeData
class ProfileModel {
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

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    this.avatarPath,
    required this.themeMode,
    required this.notifEnabled,
    required this.notifTime,
    required this.initialBalance,
    this.lastBackupAt,
    required this.createdAt,
  });

  ProfileModel copyWith({
    String? name,
    String? currency,
    String? avatarPath,
    String? themeMode,
    bool? notifEnabled,
    String? notifTime,
    double? initialBalance,
    DateTime? lastBackupAt,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      currency: currency ?? this.currency,
      avatarPath: avatarPath ?? this.avatarPath,
      themeMode: themeMode ?? this.themeMode,
      notifEnabled: notifEnabled ?? this.notifEnabled,
      notifTime: notifTime ?? this.notifTime,
      initialBalance: initialBalance ?? this.initialBalance,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      createdAt: createdAt,
    );
  }
}
