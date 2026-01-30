/// Form Validators
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número válido';
    }
    if (value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '').length < 8) {
      return 'El número es muy corto';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(
    String? value, {
    String fieldName = 'El valor',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null || number <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    return null;
  }

  /// Validate non-negative number
  static String? nonNegativeNumber(
    String? value, {
    String fieldName = 'El valor',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null || number < 0) {
      return '$fieldName no puede ser negativo';
    }
    return null;
  }

  /// Validate integer in range
  static String? integerInRange(
    String? value, {
    required int min,
    required int max,
    String fieldName = 'El valor',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número entero';
    }
    if (number < min || number > max) {
      return '$fieldName debe estar entre $min y $max';
    }
    return null;
  }

  /// Validate date is in the future
  static String? futureDate(DateTime? date, {String fieldName = 'La fecha'}) {
    if (date == null) {
      return '$fieldName es requerida';
    }
    if (date.isBefore(DateTime.now())) {
      return '$fieldName debe ser en el futuro';
    }
    return null;
  }

  /// Validate date is in the past
  static String? pastDate(DateTime? date, {String fieldName = 'La fecha'}) {
    if (date == null) {
      return '$fieldName es requerida';
    }
    if (date.isAfter(DateTime.now())) {
      return '$fieldName debe ser en el pasado';
    }
    return null;
  }

  /// Validate installments (2-36)
  static String? installments(String? value) {
    return integerInRange(value, min: 2, max: 36, fieldName: 'Las cuotas');
  }

  /// Validate day of month (1-31)
  static String? dayOfMonth(String? value) {
    return integerInRange(value, min: 1, max: 31, fieldName: 'El día');
  }

  /// Validate credit card last 4 digits
  static String? lastFourDigits(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.length != 4 || int.tryParse(value) == null) {
      return 'Ingresa los últimos 4 dígitos';
    }
    return null;
  }
}
