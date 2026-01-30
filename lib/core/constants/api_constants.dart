// API Constants for Supabase and External Services

class ApiConstants {
  ApiConstants._();

  // Supabase Configuration - Obtener valores del archivo .env
  // Asegúrate de usar un paquete como flutter_dotenv para cargar estos valores
  static const String supabaseUrl =
      'URL_DESDE_ENV'; // Reemplazar con dotenv.get('SUPABASE_URL')
  static const String supabaseAnonKey =
      'KEY_DESDE_ENV'; // Reemplazar con dotenv.get('SUPABASE_ANON_KEY')

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
