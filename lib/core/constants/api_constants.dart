// API Constants for Supabase and External Services

class ApiConstants {
  ApiConstants._();

  // Supabase Configuration
  // Todo: Replace with actual Supabase credentials
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // Exchange Rate API (Banguat or alternative)
  static const String exchangeRateApiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  // Endpoints
  static const String usersEndpoint = '/rest/v1/users';
  static const String debtorsEndpoint = '/rest/v1/debtors';
  static const String creditorsEndpoint = '/rest/v1/creditors';
  static const String cardsEndpoint = '/rest/v1/credit_cards';
  static const String visacuotasEndpoint = '/rest/v1/visacuotas';
  static const String assetsEndpoint = '/rest/v1/assets';
}
