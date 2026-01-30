import 'package:uuid/uuid.dart';

/// Card Type Enum
enum CardType { visa, mastercard, amex, other }

/// Credit Card Model
class CreditCard {
  final String id;
  final String userId;
  final String name;
  final String bankName;
  final CardType cardType;
  final String? lastFourDigits;
  final double creditLimit;
  final double currentBalance;
  final String currency;
  final int cutOffDay;
  final int paymentDay;
  final String? color;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  CreditCard({
    String? id,
    required this.userId,
    required this.name,
    required this.bankName,
    this.cardType = CardType.visa,
    this.lastFourDigits,
    required this.creditLimit,
    this.currentBalance = 0,
    this.currency = 'GTQ',
    required this.cutOffDay,
    required this.paymentDay,
    this.color = '#667eea',
    this.isActive = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // =============================================
  // COMPUTED PROPERTIES
  // =============================================

  /// Currency symbol
  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  /// Available credit
  double get availableCredit => creditLimit - currentBalance;

  /// Credit utilization percentage (0.0 to 1.0)
  double get utilizationPercentage {
    if (creditLimit == 0) return 0.0;
    return (currentBalance / creditLimit).clamp(0.0, 1.0);
  }

  /// Usage percentage (0 to 100)
  double get usagePercentage => utilizationPercentage * 100;

  /// Formatted credit limit
  String get formattedCreditLimit {
    return '$currencySymbol ${creditLimit.toStringAsFixed(2)}';
  }

  /// Alias for formattedCreditLimit
  String get formattedLimit => formattedCreditLimit;

  /// Formatted available credit
  String get formattedAvailableCredit {
    return '$currencySymbol ${availableCredit.toStringAsFixed(2)}';
  }

  /// Alias for formattedAvailableCredit
  String get formattedAvailable => formattedAvailableCredit;

  /// Formatted current balance
  String get formattedCurrentBalance {
    return '$currencySymbol ${currentBalance.toStringAsFixed(2)}';
  }

  /// Alias for formattedCurrentBalance
  String get formattedBalance => formattedCurrentBalance;

  /// Display name with bank
  String get displayName => '$name - $bankName';

  /// Masked card number
  String get maskedNumber {
    if (lastFourDigits == null) return '**** **** **** ****';
    return '**** **** **** $lastFourDigits';
  }

  /// Next cut-off date
  DateTime get nextCutOffDate {
    final now = DateTime.now();
    var year = now.year;
    var month = now.month;

    if (now.day > cutOffDay) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = cutOffDay > daysInMonth ? daysInMonth : cutOffDay;

    return DateTime(year, month, day);
  }

  /// Next payment date
  DateTime get nextPaymentDate {
    final now = DateTime.now();
    var year = now.year;
    var month = now.month;

    if (now.day > paymentDay) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = paymentDay > daysInMonth ? daysInMonth : paymentDay;

    return DateTime(year, month, day);
  }

  /// Days until payment
  int get daysUntilPayment {
    return nextPaymentDate.difference(DateTime.now()).inDays;
  }

  // =============================================
  // SERIALIZATION
  // =============================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'bank_name': bankName,
      'card_type': cardType.name.toUpperCase(),
      'last_four_digits': lastFourDigits,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'currency': currency,
      'cut_off_day': cutOffDay,
      'payment_day': paymentDay,
      'color': color,
      'is_active': isActive ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      bankName: map['bank_name'] as String,
      cardType: CardType.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['card_type'] as String? ?? 'VISA'),
        orElse: () => CardType.visa,
      ),
      lastFourDigits: map['last_four_digits'] as String?,
      creditLimit: (map['credit_limit'] as num).toDouble(),
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'GTQ',
      cutOffDay: map['cut_off_day'] as int,
      paymentDay: map['payment_day'] as int,
      color: map['color'] as String? ?? '#667eea',
      isActive: (map['is_active'] as int?) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  CreditCard copyWith({
    String? id,
    String? userId,
    String? name,
    String? bankName,
    CardType? cardType,
    String? lastFourDigits,
    double? creditLimit,
    double? currentBalance,
    String? currency,
    int? cutOffDay,
    int? paymentDay,
    String? color,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      cardType: cardType ?? this.cardType,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      cutOffDay: cutOffDay ?? this.cutOffDay,
      paymentDay: paymentDay ?? this.paymentDay,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() =>
      'CreditCard{id: $id, name: $name, bank: $bankName, limit: $formattedCreditLimit}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCard && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
