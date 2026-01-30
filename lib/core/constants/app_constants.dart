// Lytix App Constants
// Version format: Major.Minor.Patch.Build

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Lytix';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1; // Increment on each debug build
  static String get fullVersion => '$appVersion.$buildNumber';

  // Currency
  static const String defaultCurrency = 'GTQ';
  static const String currencySymbolGTQ = 'Q';
  static const String currencySymbolUSD = '\$';

  // Installment limits
  static const int minInstallments = 2;
  static const int maxInstallments = 36;

  // Connectivity
  static const String supabaseHost = 'supabase.com';
  static const Duration connectivityCheckInterval = Duration(seconds: 1);
  static const Duration connectionTimeout = Duration(seconds: 5);

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // About Info
  static const String developerName = 'Lytix Team';
  static const String supportEmail = 'support@lytix.app';
  static const String privacyPolicyUrl = 'https://lytix.app/privacy';
  static const String termsOfServiceUrl = 'https://lytix.app/terms';
}
