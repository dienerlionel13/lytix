import 'package:uuid/uuid.dart';

/// Asset Category Model
class AssetCategory {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? description;
  final int sortOrder;
  final bool isSystem;

  const AssetCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.description,
    this.sortOrder = 0,
    this.isSystem = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
      'sort_order': sortOrder,
      'is_system': isSystem ? 1 : 0,
    };
  }

  factory AssetCategory.fromMap(Map<String, dynamic> map) {
    return AssetCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      description: map['description'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      isSystem: (map['is_system'] as int?) == 1,
    );
  }

  // Predefined categories
  static const realEstate = AssetCategory(
    id: 'CAT_REAL_ESTATE',
    name: 'Inmuebles',
    icon: 'home',
    color: '#00D4AA',
    isSystem: true,
    sortOrder: 1,
  );

  static const vehicles = AssetCategory(
    id: 'CAT_VEHICLES',
    name: 'Vehículos',
    icon: 'directions_car',
    color: '#6C5CE7',
    isSystem: true,
    sortOrder: 2,
  );

  static const equipment = AssetCategory(
    id: 'CAT_EQUIPMENT',
    name: 'Equipo',
    icon: 'camera_alt',
    color: '#FF6B6B',
    isSystem: true,
    sortOrder: 3,
  );

  static const investments = AssetCategory(
    id: 'CAT_INVESTMENTS',
    name: 'Inversiones',
    icon: 'trending_up',
    color: '#FFBE0B',
    isSystem: true,
    sortOrder: 4,
  );

  static const List<AssetCategory> defaultCategories = [
    realEstate,
    vehicles,
    equipment,
    investments,
  ];
}

/// Asset Model - Wealth Tracking
class Asset {
  final String id;
  final String userId;
  final String categoryId;
  final String name;
  final String? description;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final double acquisitionValue;
  final double currentValue;
  final String currency;
  final DateTime acquisitionDate;
  final DateTime? lastValuationDate;
  final String? location;
  final String? imagePath;
  final String? documentsPath;
  final String? notes;
  final bool isInsured;
  final String? insuranceDetails;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  Asset({
    String? id,
    required this.userId,
    required this.categoryId,
    required this.name,
    this.description,
    this.brand,
    this.model,
    this.serialNumber,
    required this.acquisitionValue,
    required this.currentValue,
    this.currency = 'GTQ',
    required this.acquisitionDate,
    this.lastValuationDate,
    this.location,
    this.imagePath,
    this.documentsPath,
    this.notes,
    this.isInsured = false,
    this.insuranceDetails,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  /// Value change since acquisition
  double get valueChange => currentValue - acquisitionValue;

  /// Value change percentage
  double get valueChangePercentage {
    if (acquisitionValue == 0) return 0;
    return ((currentValue - acquisitionValue) / acquisitionValue) * 100;
  }

  /// Whether value has appreciated
  bool get hasAppreciated => currentValue > acquisitionValue;

  /// Whether value has depreciated
  bool get hasDepreciated => currentValue < acquisitionValue;

  String get formattedAcquisitionValue =>
      '$currencySymbol ${acquisitionValue.toStringAsFixed(2)}';

  String get formattedCurrentValue =>
      '$currencySymbol ${currentValue.toStringAsFixed(2)}';

  String get formattedValueChange {
    final prefix = valueChange >= 0 ? '+' : '';
    return '$prefix$currencySymbol ${valueChange.toStringAsFixed(2)}';
  }

  String get formattedValueChangePercentage {
    final prefix = valueChangePercentage >= 0 ? '+' : '';
    return '$prefix${valueChangePercentage.toStringAsFixed(1)}%';
  }

  /// Full name with brand/model if available
  String get displayName {
    if (brand != null && model != null) {
      return '$brand $model - $name';
    } else if (brand != null) {
      return '$brand - $name';
    }
    return name;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'acquisition_value': acquisitionValue,
      'current_value': currentValue,
      'currency': currency,
      'acquisition_date': acquisitionDate.toIso8601String(),
      'last_valuation_date': lastValuationDate?.toIso8601String(),
      'location': location,
      'image_path': imagePath,
      'documents_path': documentsPath,
      'notes': notes,
      'is_insured': isInsured ? 1 : 0,
      'insurance_details': insuranceDetails,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      serialNumber: map['serial_number'] as String?,
      acquisitionValue: (map['acquisition_value'] as num).toDouble(),
      currentValue: (map['current_value'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      acquisitionDate: DateTime.parse(map['acquisition_date'] as String),
      lastValuationDate: map['last_valuation_date'] != null
          ? DateTime.parse(map['last_valuation_date'] as String)
          : null,
      location: map['location'] as String?,
      imagePath: map['image_path'] as String?,
      documentsPath: map['documents_path'] as String?,
      notes: map['notes'] as String?,
      isInsured: (map['is_insured'] as int?) == 1,
      insuranceDetails: map['insurance_details'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }

  Asset copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? name,
    String? description,
    String? brand,
    String? model,
    String? serialNumber,
    double? acquisitionValue,
    double? currentValue,
    String? currency,
    DateTime? acquisitionDate,
    DateTime? lastValuationDate,
    String? location,
    String? imagePath,
    String? documentsPath,
    String? notes,
    bool? isInsured,
    String? insuranceDetails,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      acquisitionValue: acquisitionValue ?? this.acquisitionValue,
      currentValue: currentValue ?? this.currentValue,
      currency: currency ?? this.currency,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      lastValuationDate: lastValuationDate ?? this.lastValuationDate,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      documentsPath: documentsPath ?? this.documentsPath,
      notes: notes ?? this.notes,
      isInsured: isInsured ?? this.isInsured,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() =>
      'Asset{id: $id, name: $name, value: $formattedCurrentValue}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Asset && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Asset Valuation History
class AssetValuation {
  final String id;
  final String assetId;
  final double value;
  final String currency;
  final DateTime valuationDate;
  final String? valuationSource;
  final String? notes;
  final DateTime createdAt;
  final DateTime? syncedAt;

  AssetValuation({
    String? id,
    required this.assetId,
    required this.value,
    this.currency = 'GTQ',
    required this.valuationDate,
    this.valuationSource,
    this.notes,
    DateTime? createdAt,
    this.syncedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  String get currencySymbol => currency == 'USD' ? '\$' : 'Q';

  String get formattedValue => '$currencySymbol ${value.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'asset_id': assetId,
      'value': value,
      'currency': currency,
      'valuation_date': valuationDate.toIso8601String(),
      'valuation_source': valuationSource,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory AssetValuation.fromMap(Map<String, dynamic> map) {
    return AssetValuation(
      id: map['id'] as String,
      assetId: map['asset_id'] as String,
      value: (map['value'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GTQ',
      valuationDate: DateTime.parse(map['valuation_date'] as String),
      valuationSource: map['valuation_source'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
    );
  }
}
