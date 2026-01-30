import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/currency.dart';

/// Currency Exchange Service
/// Fetches exchange rates from external APIs
class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  /// Current cached rates
  final Map<String, ExchangeRate> _cachedRates = {};
  DateTime? _lastFetch;

  /// Singleton instance
  static final CurrencyService _instance = CurrencyService._();
  factory CurrencyService() => _instance;
  CurrencyService._();

  /// Get exchange rate between two currencies
  Future<ExchangeRate?> getRate(String from, String to) async {
    final key = '${from}_$to';

    // Check cache (valid for 1 hour)
    if (_cachedRates.containsKey(key) && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age.inHours < 1) {
        return _cachedRates[key];
      }
    }

    // Fetch from API
    try {
      final rates = await fetchRates(from);
      if (rates.containsKey(to)) {
        final rate = ExchangeRate(
          fromCurrency: from,
          toCurrency: to,
          rate: rates[to]!,
          date: DateTime.now(),
          source: 'exchangerate-api.com',
        );
        _cachedRates[key] = rate;
        return rate;
      }
    } catch (e) {
      // Return cached rate if available, even if expired
      return _cachedRates[key];
    }

    return null;
  }

  /// Fetch all rates for a base currency
  Future<Map<String, double>> fetchRates(String baseCurrency) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        _lastFetch = DateTime.now();

        return rates.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
      }
    } catch (e) {
      // Fallback to hardcoded rates
    }

    return _getFallbackRates(baseCurrency);
  }

  /// Fallback rates when API is unavailable
  Map<String, double> _getFallbackRates(String baseCurrency) {
    // Approximate rates as of late 2024
    const gtqToUsd = 7.80;
    const eurToUsd = 1.08;
    const mxnToUsd = 17.20;

    switch (baseCurrency) {
      case 'GTQ':
        return {
          'USD': 1 / gtqToUsd,
          'EUR': (1 / gtqToUsd) / eurToUsd,
          'MXN': (1 / gtqToUsd) * mxnToUsd,
        };
      case 'USD':
        return {'GTQ': gtqToUsd, 'EUR': 1 / eurToUsd, 'MXN': mxnToUsd};
      case 'EUR':
        return {
          'USD': eurToUsd,
          'GTQ': eurToUsd * gtqToUsd,
          'MXN': eurToUsd * mxnToUsd,
        };
      case 'MXN':
        return {
          'USD': 1 / mxnToUsd,
          'GTQ': (1 / mxnToUsd) * gtqToUsd,
          'EUR': (1 / mxnToUsd) / eurToUsd,
        };
      default:
        return {'USD': 1.0};
    }
  }

  /// Convert amount between currencies
  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) return amount;

    final rate = await getRate(from, to);
    if (rate != null) {
      return rate.convert(amount);
    }

    // Fallback conversion
    final fallbackRates = _getFallbackRates(from);
    return amount * (fallbackRates[to] ?? 1.0);
  }

  /// Get all rates for a base currency
  Future<List<ExchangeRate>> getAllRates(String baseCurrency) async {
    final rates = await fetchRates(baseCurrency);
    _lastFetch = DateTime.now();

    return rates.entries.where((e) => e.key != baseCurrency).map((entry) {
      return ExchangeRate(
        fromCurrency: baseCurrency,
        toCurrency: entry.key,
        rate: entry.value,
        date: DateTime.now(),
        source: 'exchangerate-api.com',
      );
    }).toList();
  }

  /// Clear cache
  void clearCache() {
    _cachedRates.clear();
    _lastFetch = null;
  }

  /// Get last fetch time
  DateTime? get lastFetchTime => _lastFetch;
}
