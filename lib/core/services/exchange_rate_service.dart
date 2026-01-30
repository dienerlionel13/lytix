import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Exchange Rate Service
/// Fetches current USD/GTQ exchange rate
class ExchangeRateService {
  static final ExchangeRateService _instance = ExchangeRateService._internal();
  factory ExchangeRateService() => _instance;
  ExchangeRateService._internal();

  double _usdToGtq = 7.80; // Default fallback rate
  DateTime? _lastFetched;

  /// Current USD to GTQ rate
  double get usdToGtq => _usdToGtq;

  /// Current GTQ to USD rate
  double get gtqToUsd => 1 / _usdToGtq;

  /// When rate was last fetched
  DateTime? get lastFetched => _lastFetched;

  /// Fetch latest exchange rate from API
  Future<bool> fetchLatestRate() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.exchangeRateApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>?;

        if (rates != null && rates.containsKey('GTQ')) {
          _usdToGtq = (rates['GTQ'] as num).toDouble();
          _lastFetched = DateTime.now();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Convert USD to GTQ
  double convertUsdToGtq(double usd) {
    return usd * _usdToGtq;
  }

  /// Convert GTQ to USD
  double convertGtqToUsd(double gtq) {
    return gtq / _usdToGtq;
  }

  /// Convert amount between currencies
  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    if (from == to) return amount;

    if (from == 'USD' && to == 'GTQ') {
      return convertUsdToGtq(amount);
    } else if (from == 'GTQ' && to == 'USD') {
      return convertGtqToUsd(amount);
    }

    return amount;
  }

  /// Format amount with currency symbol
  String formatCurrency(double amount, String currency) {
    final symbol = currency == 'USD' ? '\$' : 'Q';
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}

/// Global instance
final exchangeRateService = ExchangeRateService();
