// Users Database Schema
// Database file: lytix_users.db

class UsersSchema {
  UsersSchema._();

  static const String createTableUsers = '''
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      avatar_url TEXT,
      phone TEXT,
      preferred_currency TEXT DEFAULT 'GTQ',
      biometric_enabled INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT
    )
  ''';

  static const String createTableUserSettings = '''
    CREATE TABLE IF NOT EXISTS user_settings (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      setting_key TEXT NOT NULL,
      setting_value TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id),
      UNIQUE(user_id, setting_key)
    )
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
    'CREATE INDEX IF NOT EXISTS idx_user_settings_user ON user_settings(user_id)',
  ];

  static List<String> get allStatements => [
    createTableUsers,
    createTableUserSettings,
    ...createIndexes,
  ];
}
