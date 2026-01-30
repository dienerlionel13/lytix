import 'package:uuid/uuid.dart';

/// Budget Type Enum
enum BudgetType { income, expense }

/// Budget Category Model
class BudgetCategory {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final String? color;
  final String? parentId;
  final int sortOrder;
  final bool isSystem;
  final bool isActive;
  final BudgetType type;
  final double budgetedAmount;
  final double spentAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  BudgetCategory({
    String? id,
    required this.userId,
    required this.name,
    this.icon,
    this.color,
    this.parentId,
    this.sortOrder = 0,
    this.isSystem = false,
    this.isActive = true,
    this.type = BudgetType.expense,
    this.budgetedAmount = 0,
    this.spentAmount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Remaining budget
  double get remainingBudget => budgetedAmount - spentAmount;

  /// Progress percentage (0.0 to 1.0+)
  double get progressPercentage {
    if (budgetedAmount == 0) return 0;
    return spentAmount / budgetedAmount;
  }

  /// Whether over budget
  bool get isOverBudget => spentAmount > budgetedAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_system': isSystem ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'type': type.name,
      'budgeted_amount': budgetedAmount,
      'spent_amount': spentAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      parentId: map['parent_id'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      isSystem: (map['is_system'] as int?) == 1,
      isActive: (map['is_active'] as int?) == 1,
      type: BudgetType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'expense'),
        orElse: () => BudgetType.expense,
      ),
      budgetedAmount: (map['budgeted_amount'] as num?)?.toDouble() ?? 0,
      spentAmount: (map['spent_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  BudgetCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? color,
    String? parentId,
    int? sortOrder,
    bool? isSystem,
    bool? isActive,
    BudgetType? type,
    double? budgetedAmount,
    double? spentAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      budgetedAmount: budgetedAmount ?? this.budgetedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() => 'BudgetCategory{id: $id, name: $name}';
}

/// Budget Transaction Model
class BudgetTransaction {
  final String id;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetTransaction({
    String? id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetTransaction.fromMap(Map<String, dynamic> map) {
    return BudgetTransaction(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() =>
      'BudgetTransaction{id: $id, amount: $amount, description: $description}';
}

/// Budget Item Model
class BudgetItem {
  final String id;
  final String categoryId;
  final String description;
  final double projectedAmount;
  final double actualAmount;
  final String currency;
  final int periodMonth;
  final int periodYear;
  final bool isRecurring;
  final String? recurrenceType;
  final int? dueDay;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  BudgetItem({
    String? id,
    required this.categoryId,
    required this.description,
    required this.projectedAmount,
    this.actualAmount = 0,
    this.currency = 'GTQ',
    required this.periodMonth,
    required this.periodYear,
    this.isRecurring = false,
    this.recurrenceType,
    this.dueDay,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  /// Difference between projected and actual
  double get variance => actualAmount - projectedAmount;

  /// Variance percentage
  double get variancePercentage {
    if (projectedAmount == 0) return 0;
    return (variance / projectedAmount) * 100;
  }

  /// Whether over budget
  bool get isOverBudget => actualAmount > projectedAmount;

  /// Progress percentage (0.0 to 1.0+)
  double get progressPercentage {
    if (projectedAmount == 0) return 0;
    return actualAmount / projectedAmount;
  }

  /// Remaining budget
  double get remaining => projectedAmount - actualAmount;

  String get formattedProjected =>
      '$currencySymbol ${projectedAmount.toStringAsFixed(2)}';

  String get formattedActual =>
      '$currencySymbol ${actualAmount.toStringAsFixed(2)}';

  String get formattedVariance {
    final prefix = variance >= 0 ? '+' : '';
    return '$prefix$currencySymbol ${variance.toStringAsFixed(2)}';
  }

  String get formattedRemaining =>
      '$currencySymbol ${remaining.toStringAsFixed(2)}';

  /// Period display string
  String get periodDisplay {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[periodMonth - 1]} $periodYear';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'description': description,
      'projected_amount': projectedAmount,
      'actual_amount': actualAmount,
      'currency': currency,
      'period_month': periodMonth,
      'period_year': periodYear,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_type': recurrenceType,
      'due_day': dueDay,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    return BudgetItem(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      description: map['description'] as String,
      projectedAmount: (map['projected_amount'] as num).toDouble(),
      actualAmount: (map['actual_amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'GTQ',
      periodMonth: map['period_month'] as int,
      periodYear: map['period_year'] as int,
      isRecurring: (map['is_recurring'] as int?) == 1,
      recurrenceType: map['recurrence_type'] as String?,
      dueDay: map['due_day'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  BudgetItem copyWith({
    String? id,
    String? categoryId,
    String? description,
    double? projectedAmount,
    double? actualAmount,
    String? currency,
    int? periodMonth,
    int? periodYear,
    bool? isRecurring,
    String? recurrenceType,
    int? dueDay,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      projectedAmount: projectedAmount ?? this.projectedAmount,
      actualAmount: actualAmount ?? this.actualAmount,
      currency: currency ?? this.currency,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      dueDay: dueDay ?? this.dueDay,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() =>
      'BudgetItem{id: $id, description: $description, projected: $formattedProjected, actual: $formattedActual}';
}
