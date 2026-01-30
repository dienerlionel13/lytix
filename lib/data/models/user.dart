import 'package:uuid/uuid.dart';

/// User Model
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? phone;
  final String preferredCurrency;
  final bool biometricEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  User({
    String? id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.phone,
    this.preferredCurrency = 'GTQ',
    this.biometricEnabled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'phone': phone,
      'preferred_currency': preferredCurrency,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  /// Create from database Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      preferredCurrency: map['preferred_currency'] as String? ?? 'GTQ',
      biometricEnabled: (map['biometric_enabled'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? preferredCurrency,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'User{id: $id, email: $email, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
