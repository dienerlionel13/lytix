// Sync Database Schema
// Database file: lytix_sync.db
// Includes: Sync Log and Exchange Rates

class SyncSchema {
  SyncSchema._();

  // =============================================
  // SYNC LOG (Track pending syncs)
  // =============================================

  static const String createTableSyncLog = '''
    CREATE TABLE IF NOT EXISTS sync_log (
      id TEXT PRIMARY KEY,
      database_name TEXT NOT NULL,
      table_name TEXT NOT NULL,
      record_id TEXT NOT NULL,
      action TEXT NOT NULL,
      data TEXT,
      synced INTEGER DEFAULT 0,
      retry_count INTEGER DEFAULT 0,
      last_error TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  // =============================================
  // EXCHANGE RATES
  // =============================================

  static const String createTableExchangeRates = '''
    CREATE TABLE IF NOT EXISTS exchange_rates (
      id TEXT PRIMARY KEY,
      from_currency TEXT NOT NULL,
      to_currency TEXT NOT NULL,
      rate REAL NOT NULL,
      date TEXT NOT NULL,
      source TEXT,
      created_at TEXT NOT NULL,
      UNIQUE(from_currency, to_currency, date)
    )
  ''';

  // =============================================
  // APP METADATA
  // =============================================

  static const String createTableAppMetadata = '''
    CREATE TABLE IF NOT EXISTS app_metadata (
      key TEXT PRIMARY KEY,
      value TEXT,
      updated_at TEXT NOT NULL
    )
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_sync_log_pending ON sync_log(synced, database_name)',
    'CREATE INDEX IF NOT EXISTS idx_sync_log_table ON sync_log(table_name, record_id)',
    'CREATE INDEX IF NOT EXISTS idx_exchange_rates_currencies ON exchange_rates(from_currency, to_currency)',
    'CREATE INDEX IF NOT EXISTS idx_exchange_rates_date ON exchange_rates(date)',
  ];

  static List<String> get allStatements => [
    createTableSyncLog,
    createTableExchangeRates,
    createTableAppMetadata,
    ...createIndexes,
  ];
}
