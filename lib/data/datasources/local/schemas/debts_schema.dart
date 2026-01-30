// Debts Database Schema
// Database file: lytix_debts.db
// Includes: Debtors, Receivables, Creditors, Payables

class DebtsSchema {
  DebtsSchema._();

  // =============================================
  // CUENTAS POR COBRAR (Accounts Receivable)
  // =============================================

  static const String createTableDebtors = '''
    CREATE TABLE IF NOT EXISTS debtors (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      address TEXT,
      notes TEXT,
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  static const String createTableReceivableCategories = '''
    CREATE TABLE IF NOT EXISTS receivable_categories (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL UNIQUE,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String createTableReceivables = '''
    CREATE TABLE IF NOT EXISTS receivables (
      id TEXT PRIMARY KEY,
      debtor_id TEXT NOT NULL,
      description TEXT NOT NULL,
      initial_amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      date_created TEXT NOT NULL,
      due_date TEXT,
      status TEXT NOT NULL DEFAULT 'PENDING',
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      purchase_id TEXT,
      category_id TEXT,
      debtor_name TEXT,
      balance_type TEXT,
      FOREIGN KEY (debtor_id) REFERENCES debtors(id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES receivable_categories(id) ON DELETE SET NULL
    )
  ''';

  static const String createTableReceivablePayments = '''
    CREATE TABLE IF NOT EXISTS receivable_payments (
      id TEXT PRIMARY KEY,
      receivable_id TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      payment_date TEXT NOT NULL,
      payment_method TEXT,
      notes TEXT,
      receipt_number TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (receivable_id) REFERENCES receivables(id) ON DELETE CASCADE
    )
  ''';

  // =============================================
  // CUENTAS POR PAGAR (Accounts Payable)
  // =============================================

  static const String createTableCreditors = '''
    CREATE TABLE IF NOT EXISTS creditors (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      address TEXT,
      notes TEXT,
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  static const String createTablePayables = '''
    CREATE TABLE IF NOT EXISTS payables (
      id TEXT PRIMARY KEY,
      creditor_id TEXT NOT NULL,
      description TEXT NOT NULL,
      initial_amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      interest_rate REAL DEFAULT 0,
      date_created TEXT NOT NULL,
      due_date TEXT,
      reminder_enabled INTEGER DEFAULT 1,
      reminder_days_before INTEGER DEFAULT 3,
      status TEXT NOT NULL DEFAULT 'PENDING',
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (creditor_id) REFERENCES creditors(id) ON DELETE CASCADE
    )
  ''';

  static const String createTablePayablePayments = '''
    CREATE TABLE IF NOT EXISTS payable_payments (
      id TEXT PRIMARY KEY,
      payable_id TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      payment_date TEXT NOT NULL,
      payment_method TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (payable_id) REFERENCES payables(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_debtors_user ON debtors(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_receivables_debtor ON receivables(debtor_id)',
    'CREATE INDEX IF NOT EXISTS idx_receivables_status ON receivables(status)',
    'CREATE INDEX IF NOT EXISTS idx_receivables_category ON receivables(category_id)',
    'CREATE INDEX IF NOT EXISTS idx_receivable_payments_receivable ON receivable_payments(receivable_id)',
    'CREATE INDEX IF NOT EXISTS idx_creditors_user ON creditors(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_payables_creditor ON payables(creditor_id)',
    'CREATE INDEX IF NOT EXISTS idx_payables_status ON payables(status)',
    'CREATE INDEX IF NOT EXISTS idx_payables_due_date ON payables(due_date)',
    'CREATE INDEX IF NOT EXISTS idx_payable_payments_payable ON payable_payments(payable_id)',
  ];

  static List<String> get allStatements => [
    createTableDebtors,
    createTableReceivableCategories,
    createTableReceivables,
    createTableReceivablePayments,
    createTableCreditors,
    createTablePayables,
    createTablePayablePayments,
    ...createIndexes,
  ];
}
