import 'package:uuid/uuid.dart';

/// Shared Purchase Model
/// Represents a purchase that is split between the user and one or more debtors
class SharedPurchase {
  final String id;
  final String userId;
  final String? cardId; // Optional: card used for the purchase
  final String description;
  final double totalAmount;
  final String currency;
  final double exchangeRate;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  SharedPurchase({
    String? id,
    required this.userId,
    this.cardId,
    required this.description,
    required this.totalAmount,
    this.currency = 'GTQ',
    this.exchangeRate = 1.0,
    required this.purchaseDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'card_id': cardId,
      'description': description,
      'total_amount': totalAmount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'purchase_date': purchaseDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory SharedPurchase.fromMap(Map<String, dynamic> map) {
    return SharedPurchase(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      cardId: map['card_id'] as String?,
      description: map['description'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }
}

/// Purchase Split Model
/// Represents a part of a shared purchase assigned to a debtor or the user
class PurchaseSplit {
  final String id;
  final String purchaseId;
  final String? debtorId; // NULL if it's the user's portion
  final double amount;
  final bool isUserShare;
  final String? receivableId; // Link to the created receivable record
  final DateTime createdAt;

  PurchaseSplit({
    String? id,
    required this.purchaseId,
    this.debtorId,
    required this.amount,
    this.isUserShare = false,
    this.receivableId,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'debtor_id': debtorId,
      'amount': amount,
      'is_user_share': isUserShare ? 1 : 0,
      'receivable_id': receivableId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PurchaseSplit.fromMap(Map<String, dynamic> map) {
    return PurchaseSplit(
      id: map['id'] as String,
      purchaseId: map['purchase_id'] as String,
      debtorId: map['debtor_id'] as String?,
      amount: (map['amount'] as num).toDouble(),
      isUserShare: (map['is_user_share'] as int?) == 1,
      receivableId: map['receivable_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
