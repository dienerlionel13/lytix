import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/db_constants.dart';
import 'schemas/users_schema.dart';
import 'schemas/debts_schema.dart';
import 'schemas/cards_schema.dart';
import 'schemas/budget_schema.dart';
import 'schemas/assets_schema.dart';
import 'schemas/sync_schema.dart';

/// Database Helper - Manages multiple SQLite databases
/// Each module has its own database file for better organization
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instances
  Database? _usersDb;
  Database? _debtsDb;
  Database? _cardsDb;
  Database? _budgetDb;
  Database? _assetsDb;
  Database? _syncDb;

  bool _isInitialized = false;

  /// Whether all databases are initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all databases
  Future<void> initialize() async {
    if (_isInitialized) return;

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = directory.path;

    // Initialize each database
    _usersDb = await _openDatabase(
      join(dbPath, DbConstants.usersDatabase),
      UsersSchema.allStatements,
    );

    _debtsDb = await _openDatabase(
      join(dbPath, DbConstants.debtsDatabase),
      DebtsSchema.allStatements,
    );

    _cardsDb = await _openDatabase(
      join(dbPath, DbConstants.cardsDatabase),
      CardsSchema.allStatements,
    );

    _budgetDb = await _openDatabase(
      join(dbPath, DbConstants.budgetDatabase),
      BudgetSchema.allStatements,
      seedStatements: BudgetSchema.seedStatements,
    );

    _assetsDb = await _openDatabase(
      join(dbPath, DbConstants.assetsDatabase),
      AssetsSchema.allStatements,
      seedStatements: AssetsSchema.seedStatements,
    );

    _syncDb = await _openDatabase(
      join(dbPath, DbConstants.syncDatabase),
      SyncSchema.allStatements,
    );

    _isInitialized = true;
  }

  Future<Database> _openDatabase(
    String path,
    List<String> createStatements, {
    List<String>? seedStatements,
  }) async {
    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: (db, version) async {
        for (final statement in createStatements) {
          await db.execute(statement);
        }
        if (seedStatements != null) {
          for (final statement in seedStatements) {
            await db.execute(statement);
          }
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations here
      },
    );
  }

  // =============================================
  // DATABASE GETTERS
  // =============================================

  Database get usersDb {
    if (_usersDb == null) throw Exception('Users database not initialized');
    return _usersDb!;
  }

  Database get debtsDb {
    if (_debtsDb == null) throw Exception('Debts database not initialized');
    return _debtsDb!;
  }

  Database get cardsDb {
    if (_cardsDb == null) throw Exception('Cards database not initialized');
    return _cardsDb!;
  }

  Database get budgetDb {
    if (_budgetDb == null) throw Exception('Budget database not initialized');
    return _budgetDb!;
  }

  Database get assetsDb {
    if (_assetsDb == null) throw Exception('Assets database not initialized');
    return _assetsDb!;
  }

  Database get syncDb {
    if (_syncDb == null) throw Exception('Sync database not initialized');
    return _syncDb!;
  }

  // =============================================
  // GENERIC CRUD OPERATIONS
  // =============================================

  /// Insert a record into a table
  Future<int> insert(
    Database db,
    String table,
    Map<String, dynamic> data,
  ) async {
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a record in a table
  Future<int> update(
    Database db,
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Delete a record from a table
  Future<int> delete(
    Database db,
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Query records from a table
  Future<List<Map<String, dynamic>>> query(
    Database db,
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    Database db,
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return await db.rawQuery(sql, arguments);
  }

  // =============================================
  // SYNC OPERATIONS
  // =============================================

  /// Log a change for sync
  Future<void> logSync({
    required String databaseName,
    required String tableName,
    required String recordId,
    required String action,
    String? data,
  }) async {
    final now = DateTime.now().toIso8601String();
    await syncDb.insert('sync_log', {
      'id': '${tableName}_${recordId}_$now',
      'database_name': databaseName,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data,
      'synced': 0,
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    return await syncDb.query(
      'sync_log',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  /// Mark sync as completed
  Future<void> markSynced(String id) async {
    await syncDb.update(
      'sync_log',
      {'synced': 1, 'synced_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =============================================
  // CLEANUP
  // =============================================

  /// Close all databases
  Future<void> close() async {
    await _usersDb?.close();
    await _debtsDb?.close();
    await _cardsDb?.close();
    await _budgetDb?.close();
    await _assetsDb?.close();
    await _syncDb?.close();
    _isInitialized = false;
  }

  /// Delete all databases (for testing/reset)
  Future<void> deleteAllDatabases() async {
    await close();

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = directory.path;

    final databases = [
      DbConstants.usersDatabase,
      DbConstants.debtsDatabase,
      DbConstants.cardsDatabase,
      DbConstants.budgetDatabase,
      DbConstants.assetsDatabase,
      DbConstants.syncDatabase,
    ];

    for (final dbName in databases) {
      await deleteDatabase(join(dbPath, dbName));
    }
  }
}

/// Global instance
final databaseHelper = DatabaseHelper();
