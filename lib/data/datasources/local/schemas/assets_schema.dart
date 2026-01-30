// Assets Database Schema
// Database file: lytix_assets.db
// Includes: Asset Categories and Assets (Wealth Tracking)

class AssetsSchema {
  AssetsSchema._();

  // =============================================
  // ASSET CATEGORIES
  // =============================================

  static const String createTableAssetCategories = '''
    CREATE TABLE IF NOT EXISTS asset_categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      description TEXT,
      sort_order INTEGER DEFAULT 0,
      is_system INTEGER DEFAULT 0
    )
  ''';

  // Pre-populate default asset categories
  static const String insertDefaultAssetCategories = '''
    INSERT OR IGNORE INTO asset_categories (id, name, icon, color, is_system, sort_order)
    VALUES 
      ('CAT_REAL_ESTATE', 'Inmuebles', 'home', '#00D4AA', 1, 1),
      ('CAT_VEHICLES', 'Vehículos', 'directions_car', '#6C5CE7', 1, 2),
      ('CAT_EQUIPMENT', 'Equipo', 'camera_alt', '#FF6B6B', 1, 3),
      ('CAT_INVESTMENTS', 'Inversiones', 'trending_up', '#FFBE0B', 1, 4),
      ('CAT_JEWELRY', 'Joyería', 'diamond', '#74B9FF', 1, 5),
      ('CAT_ELECTRONICS', 'Electrónicos', 'devices', '#E17055', 1, 6),
      ('CAT_OTHER_ASSETS', 'Otros Activos', 'inventory', '#636E72', 1, 7)
  ''';

  // =============================================
  // ASSETS
  // =============================================

  static const String createTableAssets = '''
    CREATE TABLE IF NOT EXISTS assets (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      brand TEXT,
      model TEXT,
      serial_number TEXT,
      acquisition_value REAL NOT NULL,
      current_value REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      acquisition_date TEXT NOT NULL,
      last_valuation_date TEXT,
      location TEXT,
      image_path TEXT,
      documents_path TEXT,
      notes TEXT,
      is_insured INTEGER DEFAULT 0,
      insurance_details TEXT,
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (category_id) REFERENCES asset_categories(id)
    )
  ''';

  // =============================================
  // ASSET VALUATIONS (History of value changes)
  // =============================================

  static const String createTableAssetValuations = '''
    CREATE TABLE IF NOT EXISTS asset_valuations (
      id TEXT PRIMARY KEY,
      asset_id TEXT NOT NULL,
      value REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GTQ',
      valuation_date TEXT NOT NULL,
      valuation_source TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_assets_user ON assets(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category_id)',
    'CREATE INDEX IF NOT EXISTS idx_assets_active ON assets(is_active)',
    'CREATE INDEX IF NOT EXISTS idx_asset_valuations_asset ON asset_valuations(asset_id)',
    'CREATE INDEX IF NOT EXISTS idx_asset_valuations_date ON asset_valuations(valuation_date)',
  ];

  static List<String> get allStatements => [
    createTableAssetCategories,
    createTableAssets,
    createTableAssetValuations,
    ...createIndexes,
  ];

  static List<String> get seedStatements => [insertDefaultAssetCategories];
}
