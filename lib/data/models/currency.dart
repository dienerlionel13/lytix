import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Exchange Rate Model
class ExchangeRate {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime date;
  final String? source;
  final DateTime createdAt;

  ExchangeRate({
    String? id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.date,
    this.source,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Convert amount from one currency to another
  double convert(double amount) => amount * rate;

  /// Inverse rate
  double get inverseRate => 1 / rate;

  /// Format rate for display
  String get formattedRate => rate.toStringAsFixed(4);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'rate': rate,
      'date': date.toIso8601String(),
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExchangeRate.fromMap(Map<String, dynamic> map) {
    return ExchangeRate(
      id: map['id'] as String,
      fromCurrency: map['from_currency'] as String,
      toCurrency: map['to_currency'] as String,
      rate: (map['rate'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      source: map['source'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ExchangeRate.fromJson(String json) =>
      ExchangeRate.fromMap(jsonDecode(json) as Map<String, dynamic>);

  @override
  String toString() =>
      'ExchangeRate{$fromCurrency -> $toCurrency: $formattedRate}';
}

/// Currency Info Model
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final int decimals;
  final String? flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimals = 2,
    this.flag,
  });

  /// Format amount with currency symbol
  String format(double amount) {
    return '$symbol ${amount.toStringAsFixed(decimals)}';
  }

  /// Parse amount from string
  double? parse(String text) {
    final clean = text.replaceAll(symbol, '').replaceAll(',', '').trim();
    return double.tryParse(clean);
  }

  static const gtq = CurrencyInfo(
    code: 'GTQ',
    name: 'Quetzal Guatemalteco',
    symbol: 'Q',
    flag: '🇬🇹',
  );

  static const usd = CurrencyInfo(
    code: 'USD',
    name: 'Dólar Estadounidense',
    symbol: '\$',
    flag: '🇺🇸',
  );

  static const eur = CurrencyInfo(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flag: '🇪🇺',
  );

  static const mxn = CurrencyInfo(
    code: 'MXN',
    name: 'Peso Mexicano',
    symbol: '\$',
    flag: '🇲🇽',
  );

  static const List<CurrencyInfo> supportedCurrencies = [gtq, usd, eur, mxn];

  static CurrencyInfo? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}

/// User Currency Settings
class CurrencySettings {
  final String primaryCurrency;
  final String secondaryCurrency;
  final bool showBothCurrencies;
  final bool autoUpdateRates;
  final DateTime? lastRateUpdate;

  const CurrencySettings({
    this.primaryCurrency = 'GTQ',
    this.secondaryCurrency = 'USD',
    this.showBothCurrencies = true,
    this.autoUpdateRates = true,
    this.lastRateUpdate,
  });

  CurrencyInfo get primaryCurrencyInfo =>
      CurrencyInfo.fromCode(primaryCurrency) ?? CurrencyInfo.gtq;

  CurrencyInfo get secondaryCurrencyInfo =>
      CurrencyInfo.fromCode(secondaryCurrency) ?? CurrencyInfo.usd;

  CurrencySettings copyWith({
    String? primaryCurrency,
    String? secondaryCurrency,
    bool? showBothCurrencies,
    bool? autoUpdateRates,
    DateTime? lastRateUpdate,
  }) {
    return CurrencySettings(
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      secondaryCurrency: secondaryCurrency ?? this.secondaryCurrency,
      showBothCurrencies: showBothCurrencies ?? this.showBothCurrencies,
      autoUpdateRates: autoUpdateRates ?? this.autoUpdateRates,
      lastRateUpdate: lastRateUpdate ?? this.lastRateUpdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primary_currency': primaryCurrency,
      'secondary_currency': secondaryCurrency,
      'show_both_currencies': showBothCurrencies,
      'auto_update_rates': autoUpdateRates,
      'last_rate_update': lastRateUpdate?.toIso8601String(),
    };
  }

  factory CurrencySettings.fromMap(Map<String, dynamic> map) {
    return CurrencySettings(
      primaryCurrency: map['primary_currency'] as String? ?? 'GTQ',
      secondaryCurrency: map['secondary_currency'] as String? ?? 'USD',
      showBothCurrencies: map['show_both_currencies'] as bool? ?? true,
      autoUpdateRates: map['auto_update_rates'] as bool? ?? true,
      lastRateUpdate: map['last_rate_update'] != null
          ? DateTime.parse(map['last_rate_update'] as String)
          : null,
    );
  }
}
