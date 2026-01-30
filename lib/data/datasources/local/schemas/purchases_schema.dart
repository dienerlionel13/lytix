// Purchases Database Schema
// Database file: lytix_purchases.db

class PurchasesSchema {
  PurchasesSchema._();

  static const String createTableSharedPurchases = '''
    CREATE TABLE IF NOT EXISTS shared_purchases (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      card_id TEXT,
      description TEXT NOT NULL,
      total_amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      purchase_date TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  static const String createTablePurchaseSplits = '''
    CREATE TABLE IF NOT EXISTS purchase_splits (
      id TEXT PRIMARY KEY,
      purchase_id TEXT NOT NULL,
      debtor_id TEXT,
      amount REAL NOT NULL,
      is_user_share INTEGER DEFAULT 0,
      receivable_id TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (purchase_id) REFERENCES shared_purchases(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_shared_purchases_user ON shared_purchases(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_shared_purchases_card ON shared_purchases(card_id)',
    'CREATE INDEX IF NOT EXISTS idx_purchase_splits_purchase ON purchase_splits(purchase_id)',
    'CREATE INDEX IF NOT EXISTS idx_purchase_splits_debtor ON purchase_splits(debtor_id)',
  ];

  static List<String> get allStatements => [
    createTableSharedPurchases,
    createTablePurchaseSplits,
    ...createIndexes,
  ];
}
