import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Currency symbols
const String kCurrencySymbolGTQ = 'Q';
const String kCurrencySymbolUSD = '\$';

/// Visacuota Status
enum VisacuotaStatus { active, completed, cancelled }

/// Visacuota Model
/// Represents an installment purchase on a credit card
class Visacuota {
  final String id;
  final String cardId;
  final String description;
  final String? storeName;
  final double totalAmount;
  final String currency;
  final double exchangeRate;
  final int totalInstallments;
  final int currentInstallment;
  final double monthlyAmount;
  final int chargeDay;
  final DateTime purchaseDate;
  final DateTime firstChargeDate;
  final VisacuotaStatus status;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  Visacuota({
    String? id,
    required this.cardId,
    required this.description,
    this.storeName,
    required this.totalAmount,
    this.currency = 'GTQ',
    this.exchangeRate = 1.0,
    required this.totalInstallments,
    this.currentInstallment = 1,
    double? monthlyAmount,
    required this.chargeDay,
    required this.purchaseDate,
    required this.firstChargeDate,
    this.status = VisacuotaStatus.active,
    this.category,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       monthlyAmount = monthlyAmount ?? (totalAmount / totalInstallments),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now() {
    // Validate installments
    assert(
      totalInstallments >= AppConstants.minInstallments &&
          totalInstallments <= AppConstants.maxInstallments,
      'Installments must be between ${AppConstants.minInstallments} and ${AppConstants.maxInstallments}',
    );
  }

  // =============================================
  // COMPUTED PROPERTIES
  // =============================================

  /// Currency symbol based on currency code
  String get currencySymbol =>
      currency == 'USD' ? kCurrencySymbolUSD : kCurrencySymbolGTQ;

  /// Calculates remaining installments based on current date
  int get remainingInstallments {
    if (status != VisacuotaStatus.active) return 0;

    final now = DateTime.now();
    int monthsPassed = _monthsDifference(firstChargeDate, now);

    // If we haven't reached the charge day this month, don't count it
    if (now.day < chargeDay) {
      monthsPassed = monthsPassed > 0 ? monthsPassed - 1 : 0;
    }

    // Add 1 because first charge counts as installment 1
    final paid = monthsPassed + 1;
    final remaining = totalInstallments - paid;
    return remaining.clamp(0, totalInstallments);
  }

  /// Calculates which installment number we're currently on
  int get calculatedCurrentInstallment {
    return totalInstallments - remainingInstallments;
  }

  /// Pending balance (remaining amount to pay)
  double get pendingBalance {
    return monthlyAmount * remainingInstallments;
  }

  /// Amount already paid
  double get paidAmount {
    return totalAmount - pendingBalance;
  }

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalInstallments == 0) return 0.0;
    return (totalInstallments - remainingInstallments) / totalInstallments;
  }

  /// Next charge date
  DateTime get nextChargeDate {
    if (remainingInstallments == 0) return finalPaymentDate;

    final now = DateTime.now();
    var year = now.year;
    var month = now.month;

    // If charge day has passed this month, move to next month
    if (now.day >= chargeDay) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    // Handle months with fewer days
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = chargeDay > daysInMonth ? daysInMonth : chargeDay;

    return DateTime(year, month, day);
  }

  /// Final payment date (estimated)
  DateTime get finalPaymentDate {
    var year = firstChargeDate.year;
    var month = firstChargeDate.month + totalInstallments - 1;

    while (month > 12) {
      month -= 12;
      year++;
    }

    // Handle months with fewer days
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = chargeDay > daysInMonth ? daysInMonth : chargeDay;

    return DateTime(year, month, day);
  }

  /// Check if this visacuota will be charged this month
  bool get isChargedThisMonth {
    if (status != VisacuotaStatus.active) return false;
    final now = DateTime.now();
    return now.day <= chargeDay && remainingInstallments > 0;
  }

  /// Check if visacuota is complete
  bool get isCompleted => remainingInstallments == 0;

  /// Days until next charge
  int get daysUntilNextCharge {
    if (remainingInstallments == 0) return 0;
    return nextChargeDate.difference(DateTime.now()).inDays;
  }

  // =============================================
  // HELPER METHODS
  // =============================================

  /// Calculate months difference between two dates
  int _monthsDifference(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  /// Get formatted remaining text
  String get remainingText {
    final current = calculatedCurrentInstallment;
    return '$current/$totalInstallments';
  }

  /// Get formatted pending balance
  String get formattedPendingBalance {
    return '$currencySymbol ${pendingBalance.toStringAsFixed(2)}';
  }

  /// Get formatted monthly amount
  String get formattedMonthlyAmount {
    return '$currencySymbol ${monthlyAmount.toStringAsFixed(2)}';
  }

  /// Get formatted total amount
  String get formattedTotalAmount {
    return '$currencySymbol ${totalAmount.toStringAsFixed(2)}';
  }

  // =============================================
  // SERIALIZATION
  // =============================================

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'description': description,
      'store_name': storeName,
      'total_amount': totalAmount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'total_installments': totalInstallments,
      'current_installment': currentInstallment,
      'monthly_amount': monthlyAmount,
      'charge_day': chargeDay,
      'purchase_date': purchaseDate.toIso8601String(),
      'first_charge_date': firstChargeDate.toIso8601String(),
      'status': status.name.toUpperCase(),
      'category': category,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  /// Create from database Map
  factory Visacuota.fromMap(Map<String, dynamic> map) {
    return Visacuota(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      description: map['description'] as String,
      storeName: map['store_name'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      totalInstallments: map['total_installments'] as int,
      currentInstallment: map['current_installment'] as int? ?? 1,
      monthlyAmount: (map['monthly_amount'] as num).toDouble(),
      chargeDay: map['charge_day'] as int,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      firstChargeDate: DateTime.parse(map['first_charge_date'] as String),
      status: VisacuotaStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['status'] as String),
        orElse: () => VisacuotaStatus.active,
      ),
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Visacuota copyWith({
    String? id,
    String? cardId,
    String? description,
    String? storeName,
    double? totalAmount,
    String? currency,
    double? exchangeRate,
    int? totalInstallments,
    int? currentInstallment,
    double? monthlyAmount,
    int? chargeDay,
    DateTime? purchaseDate,
    DateTime? firstChargeDate,
    VisacuotaStatus? status,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return Visacuota(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      description: description ?? this.description,
      storeName: storeName ?? this.storeName,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      chargeDay: chargeDay ?? this.chargeDay,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      firstChargeDate: firstChargeDate ?? this.firstChargeDate,
      status: status ?? this.status,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() {
    return 'Visacuota{id: $id, description: $description, '
        'remaining: $remainingInstallments/$totalInstallments, '
        'pending: $formattedPendingBalance}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Visacuota && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
