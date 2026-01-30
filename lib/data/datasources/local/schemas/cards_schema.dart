// Cards Database Schema
// Database file: lytix_cards.db
// Includes: Credit Cards and Visacuotas

class CardsSchema {
  CardsSchema._();

  // =============================================
  // CREDIT CARDS
  // =============================================

  static const String createTableCreditCards = '''
    CREATE TABLE IF NOT EXISTS credit_cards (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      bank_name TEXT NOT NULL,
      card_type TEXT DEFAULT 'VISA',
      last_four_digits TEXT,
      credit_limit REAL NOT NULL,
      current_balance REAL DEFAULT 0,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      cut_off_day INTEGER NOT NULL,
      payment_day INTEGER NOT NULL,
      color TEXT DEFAULT '#667eea',
      is_active INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  // =============================================
  // VISACUOTAS (Installment Purchases)
  // =============================================

  static const String createTableVisacuotas = '''
    CREATE TABLE IF NOT EXISTS visacuotas (
      id TEXT PRIMARY KEY,
      card_id TEXT NOT NULL,
      description TEXT NOT NULL,
      store_name TEXT,
      total_amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      total_installments INTEGER NOT NULL,
      current_installment INTEGER NOT NULL DEFAULT 1,
      monthly_amount REAL NOT NULL,
      charge_day INTEGER NOT NULL,
      purchase_date TEXT NOT NULL,
      first_charge_date TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'ACTIVE',
      category TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (card_id) REFERENCES credit_cards(id) ON DELETE CASCADE
    )
  ''';

  static const String createTableVisacuotaPayments = '''
    CREATE TABLE IF NOT EXISTS visacuota_payments (
      id TEXT PRIMARY KEY,
      visacuota_id TEXT NOT NULL,
      installment_number INTEGER NOT NULL,
      amount REAL NOT NULL,
      payment_date TEXT NOT NULL,
      is_paid INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (visacuota_id) REFERENCES visacuotas(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_credit_cards_user ON credit_cards(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_credit_cards_active ON credit_cards(is_active)',
    'CREATE INDEX IF NOT EXISTS idx_visacuotas_card ON visacuotas(card_id)',
    'CREATE INDEX IF NOT EXISTS idx_visacuotas_status ON visacuotas(status)',
    'CREATE INDEX IF NOT EXISTS idx_visacuotas_charge_day ON visacuotas(charge_day)',
    'CREATE INDEX IF NOT EXISTS idx_visacuota_payments_visacuota ON visacuota_payments(visacuota_id)',
  ];

  static List<String> get allStatements => [
    createTableCreditCards,
    createTableVisacuotas,
    createTableVisacuotaPayments,
    ...createIndexes,
  ];
}
