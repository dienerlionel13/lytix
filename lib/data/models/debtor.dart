import 'package:uuid/uuid.dart';

/// Debtor Model - Person who owes you money
class Debtor {
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

  Debtor({
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

  factory Debtor.fromMap(Map<String, dynamic> map) {
    return Debtor(
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

  Debtor copyWith({
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
    return Debtor(
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
  String toString() => 'Debtor{id: $id, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Debtor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Receivable Status
enum ReceivableStatus { pending, partial, paid, overdue }

/// Receivable Model - Money owed to you
class Receivable {
  final String id;
  final String debtorId;
  final String description;
  final double initialAmount;
  final String currency;
  final double exchangeRate;
  final DateTime? dueDate;
  final ReceivableStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final String? purchaseId;
  final String? categoryId;
  final String? debtorName;
  final String? balanceType;
  final DateTime? transactionDate;

  // Calculated from payments

  Receivable({
    String? id,
    required this.debtorId,
    required this.description,
    required this.initialAmount,
    this.currency = 'GTQ',
    this.exchangeRate = 1.0,
    this.dueDate,
    this.status = ReceivableStatus.pending,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
    this.purchaseId,
    this.categoryId,
    this.debtorName,
    this.balanceType,
    this.transactionDate,
    this.paidAmount = 0,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  /// Amount that has been paid - can be modified externally
  double paidAmount;

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

  String get formattedInitialAmount =>
      '$currencySymbol ${initialAmount.toStringAsFixed(2)}';

  String get formattedPendingAmount =>
      '$currencySymbol ${pendingAmount.toStringAsFixed(2)}';

  String get formattedPaidAmount =>
      '$currencySymbol ${paidAmount.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtor_id': debtorId,
      'description': description,
      'initial_amount': initialAmount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'due_date': dueDate?.toIso8601String(),
      'status': status.name.toUpperCase(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'purchase_id': purchaseId,
      'category_id': categoryId,
      'debtor_name': debtorName,
      'balance_type': balanceType,
      'transaction_date': transactionDate?.toIso8601String(),
    };
  }

  factory Receivable.fromMap(Map<String, dynamic> map) {
    return Receivable(
      id: map['id'] as String,
      debtorId: map['debtor_id'] as String,
      description: map['description'] as String,
      initialAmount: (map['initial_amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      status: ReceivableStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['status'] as String),
        orElse: () => ReceivableStatus.pending,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
      purchaseId: map['purchase_id'] as String?,
      categoryId: map['category_id'] as String?,
      debtorName: map['debtor_name'] as String?,
      balanceType: map['balance_type'] as String?,
      transactionDate: map['transaction_date'] != null
          ? DateTime.parse(map['transaction_date'] as String)
          : null,
    );
  }

  Receivable copyWith({
    String? id,
    String? debtorId,
    String? description,
    double? initialAmount,
    String? currency,
    double? exchangeRate,
    DateTime? dueDate,
    ReceivableStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    String? purchaseId,
    String? categoryId,
    String? debtorName,
    String? balanceType,
    DateTime? transactionDate,
    double? paidAmount,
  }) {
    return Receivable(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      description: description ?? this.description,
      initialAmount: initialAmount ?? this.initialAmount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
      purchaseId: purchaseId ?? this.purchaseId,
      categoryId: categoryId ?? this.categoryId,
      debtorName: debtorName ?? this.debtorName,
      balanceType: balanceType ?? this.balanceType,
      transactionDate: transactionDate ?? this.transactionDate,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  @override
  String toString() =>
      'Receivable{id: $id, description: $description, pending: $formattedPendingAmount}';
}

/// Receivable Payment Model
class ReceivablePayment {
  final String id;
  final String receivableId;
  final double amount;
  final String currency;
  final double exchangeRate;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final String? receiptNumber;

  ReceivablePayment({
    String? id,
    required this.receivableId,
    required this.amount,
    this.currency = 'GTQ',
    this.exchangeRate = 1.0,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
    this.receiptNumber,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receivable_id': receivableId,
      'amount': amount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'receipt_number': receiptNumber,
    };
  }

  factory ReceivablePayment.fromMap(Map<String, dynamic> map) {
    return ReceivablePayment(
      id: map['id'] as String,
      receivableId: map['receivable_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      paymentMethod: map['payment_method'] as String?,
      notes: map['notes'] as String?,
      receiptNumber: map['receipt_number'] as String?,
    );
  }
}

/// Receivable Category Model
class ReceivableCategory {
  final String id;
  final String userId;
  final String name;

  ReceivableCategory({String? id, required this.userId, required this.name})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {'id': id, 'user_id': userId, 'name': name};
  }

  factory ReceivableCategory.fromMap(Map<String, dynamic> map) {
    return ReceivableCategory(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
    );
  }
}
