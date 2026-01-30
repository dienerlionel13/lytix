import 'package:uuid/uuid.dart';

/// Creditor Model - Person/Entity you owe money to
class Creditor {
  final String id;
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  Creditor({
    String? id,
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.isActive = true,
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
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Creditor.fromMap(Map<String, dynamic> map) {
    return Creditor(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  Creditor copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return Creditor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'Creditor{id: $id, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Creditor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Payable Status
enum PayableStatus { pending, partial, paid, overdue }

/// Payable Model - Money you owe
class Payable {
  final String id;
  final String creditorId;
  final String description;
  final double initialAmount;
  final String currency;
  final double exchangeRate;
  final double interestRate;
  final DateTime dateCreated;
  final DateTime? dueDate;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final PayableStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  /// Amount that has been paid - can be modified externally
  double paidAmount;

  Payable({
    String? id,
    required this.creditorId,
    required this.description,
    required this.initialAmount,
    this.currency = 'GTQ',
    this.exchangeRate = 1.0,
    this.interestRate = 0,
    required this.dateCreated,
    this.dueDate,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 3,
    this.status = PayableStatus.pending,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
    this.paidAmount = 0,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  double get pendingAmount => initialAmount - paidAmount;

  double get progressPercentage {
    if (initialAmount == 0) return 0.0;
    return (paidAmount / initialAmount).clamp(0.0, 1.0);
  }

  bool get isPaid => pendingAmount <= 0;
  bool get isPartial => paidAmount > 0 && !isPaid;

  bool get isOverdue {
    if (dueDate == null || isPaid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  bool get shouldRemind {
    if (!reminderEnabled || dueDate == null || isPaid) return false;
    final daysLeft = daysUntilDue;
    return daysLeft != null && daysLeft <= reminderDaysBefore && daysLeft >= 0;
  }

  String get formattedInitialAmount =>
      '$currencySymbol ${initialAmount.toStringAsFixed(2)}';

  String get formattedPendingAmount =>
      '$currencySymbol ${pendingAmount.toStringAsFixed(2)}';

  String get formattedPaidAmount =>
      '$currencySymbol ${paidAmount.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditor_id': creditorId,
      'description': description,
      'initial_amount': initialAmount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'interest_rate': interestRate,
      'date_created': dateCreated.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_days_before': reminderDaysBefore,
      'status': status.name.toUpperCase(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Payable.fromMap(Map<String, dynamic> map) {
    return Payable(
      id: map['id'] as String,
      creditorId: map['creditor_id'] as String,
      description: map['description'] as String,
      initialAmount: (map['initial_amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      interestRate: (map['interest_rate'] as num?)?.toDouble() ?? 0,
      dateCreated: DateTime.parse(map['date_created'] as String),
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      reminderEnabled: (map['reminder_enabled'] as int?) == 1,
      reminderDaysBefore: map['reminder_days_before'] as int? ?? 3,
      status: PayableStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['status'] as String),
        orElse: () => PayableStatus.pending,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  Payable copyWith({
    String? id,
    String? creditorId,
    String? description,
    double? initialAmount,
    String? currency,
    double? exchangeRate,
    double? interestRate,
    DateTime? dateCreated,
    DateTime? dueDate,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    PayableStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    double? paidAmount,
  }) {
    return Payable(
      id: id ?? this.id,
      creditorId: creditorId ?? this.creditorId,
      description: description ?? this.description,
      initialAmount: initialAmount ?? this.initialAmount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      interestRate: interestRate ?? this.interestRate,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  @override
  String toString() =>
      'Payable{id: $id, description: $description, pending: $formattedPendingAmount}';
}

/// PayablePayment Model
class PayablePayment {
  final String id;
  final String payableId;
  final double amount;
  final String currency;
  final double exchangeRate;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? syncedAt;

  PayablePayment({
    String? id,
    required this.payableId,
    required this.amount,
    this.currency = 'GTQ',
    this.exchangeRate = 1.0,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
    DateTime? createdAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  String get formattedAmount => '$currencySymbol ${amount.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payable_id': payableId,
      'amount': amount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory PayablePayment.fromMap(Map<String, dynamic> map) {
    return PayablePayment(
      id: map['id'] as String,
      payableId: map['payable_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      paymentMethod: map['payment_method'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }
}
