import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency and number formatters
class Formatters {
  Formatters._();

  /// Format currency amount
  static String currency(double amount, {String currency = 'GTQ'}) {
    final symbol = currency == 'USD'
        ? AppConstants.currencySymbolUSD
        : AppConstants.currencySymbolGTQ;
    // Forzamos en_US para asegurar punto decimal y coma de miles
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  /// Format currency with sign
  static String currencyWithSign(double amount, {String currency = 'GTQ'}) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${Formatters.currency(amount, currency: currency)}';
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format date
  static String date(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format, 'es_GT').format(date);
  }

  /// Format date with time
  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_GT').format(date);
  }

  /// Format relative date
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Ahora';
        }
        return 'Hace ${diff.inMinutes} min';
      }
      return 'Hace ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (diff.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }
  }

  /// Format future date
  static String futureDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.isNegative) {
      return 'Vencido';
    } else if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Mañana';
    } else if (diff.inDays < 7) {
      return 'En ${diff.inDays} días';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'En $weeks semana${weeks > 1 ? 's' : ''}';
    } else {
      final months = (diff.inDays / 30).floor();
      return 'En $months mes${months > 1 ? 'es' : ''}';
    }
  }

  /// Format month name
  static String monthName(int month) {
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
    return months[month - 1];
  }

  /// Format short month name
  static String monthNameShort(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }

  /// Format number with thousands separator
  static String number(num value, {int decimals = 0}) {
    // Forzamos en_US para asegurar punto decimal y coma de miles
    final formatter = NumberFormat.decimalPattern('en_US');
    if (decimals > 0) {
      formatter.minimumFractionDigits = decimals;
      formatter.maximumFractionDigits = decimals;
    }
    return formatter.format(value);
  }

  /// Format compact number (K, M, B)
  static String compactNumber(num value) {
    // Para compactNumber es_GT suele ser adecuado, pero si queremos consistencia en separadores:
    final formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(value);
  }
}
