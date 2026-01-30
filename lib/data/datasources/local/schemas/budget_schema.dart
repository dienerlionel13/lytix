// Budget Database Schema
// Database file: lytix_budget.db
// Includes: Budget Categories and Budget Items

class BudgetSchema {
  BudgetSchema._();

  // =============================================
  // BUDGET CATEGORIES
  // =============================================

  static const String createTableBudgetCategories = '''
    CREATE TABLE IF NOT EXISTS budget_categories (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      parent_id TEXT,
      sort_order INTEGER DEFAULT 0,
      is_system INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (parent_id) REFERENCES budget_categories(id) ON DELETE SET NULL
    )
  ''';

  // =============================================
  // BUDGET ITEMS
  // =============================================

  static const String createTableBudgetItems = '''
    CREATE TABLE IF NOT EXISTS budget_items (
      id TEXT PRIMARY KEY,
      category_id TEXT NOT NULL,
      description TEXT NOT NULL,
      projected_amount REAL NOT NULL,
      actual_amount REAL DEFAULT 0,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      period_month INTEGER NOT NULL,
      period_year INTEGER NOT NULL,
      is_recurring INTEGER DEFAULT 0,
      recurrence_type TEXT,
      due_day INTEGER,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (category_id) REFERENCES budget_categories(id) ON DELETE CASCADE
    )
  ''';

  // =============================================
  // BUDGET TRANSACTIONS
  // =============================================

  static const String createTableBudgetTransactions = '''
    CREATE TABLE IF NOT EXISTS budget_transactions (
      id TEXT PRIMARY KEY,
      budget_item_id TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      exchange_rate REAL DEFAULT 1.0,
      transaction_date TEXT NOT NULL,
      description TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (budget_item_id) REFERENCES budget_items(id) ON DELETE CASCADE
    )
  ''';

  // Pre-populate default categories
  static const String insertDefaultCategories = '''
    INSERT OR IGNORE INTO budget_categories (id, user_id, name, icon, color, is_system, created_at, updated_at)
    VALUES 
      ('CAT_HOUSING', 'system', 'Vivienda', 'home', '#00D4AA', 1, datetime('now'), datetime('now')),
      ('CAT_TRANSPORT', 'system', 'Transporte', 'car', '#6C5CE7', 1, datetime('now'), datetime('now')),
      ('CAT_FOOD', 'system', 'Alimentación', 'restaurant', '#FF6B6B', 1, datetime('now'), datetime('now')),
      ('CAT_UTILITIES', 'system', 'Servicios', 'bolt', '#FFBE0B', 1, datetime('now'), datetime('now')),
      ('CAT_HEALTH', 'system', 'Salud', 'medical_services', '#74B9FF', 1, datetime('now'), datetime('now')),
      ('CAT_ENTERTAINMENT', 'system', 'Entretenimiento', 'movie', '#E17055', 1, datetime('now'), datetime('now')),
      ('CAT_EDUCATION', 'system', 'Educación', 'school', '#00CEC9', 1, datetime('now'), datetime('now')),
      ('CAT_PERSONAL', 'system', 'Personal', 'person', '#FD79A8', 1, datetime('now'), datetime('now')),
      ('CAT_SAVINGS', 'system', 'Ahorro', 'savings', '#55EFC4', 1, datetime('now'), datetime('now')),
      ('CAT_OTHER', 'system', 'Otros', 'more_horiz', '#636E72', 1, datetime('now'), datetime('now'))
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_budget_categories_user ON budget_categories(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_budget_categories_parent ON budget_categories(parent_id)',
    'CREATE INDEX IF NOT EXISTS idx_budget_items_category ON budget_items(category_id)',
    'CREATE INDEX IF NOT EXISTS idx_budget_items_period ON budget_items(period_year, period_month)',
    'CREATE INDEX IF NOT EXISTS idx_budget_transactions_item ON budget_transactions(budget_item_id)',
    'CREATE INDEX IF NOT EXISTS idx_budget_transactions_date ON budget_transactions(transaction_date)',
  ];

  static List<String> get allStatements => [
    createTableBudgetCategories,
    createTableBudgetItems,
    createTableBudgetTransactions,
    ...createIndexes,
  ];

  static List<String> get seedStatements => [insertDefaultCategories];
}
