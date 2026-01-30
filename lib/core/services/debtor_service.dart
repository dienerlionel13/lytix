import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/debtor.dart';
import '../../data/datasources/local/database_helper.dart';
import '../constants/db_constants.dart';
import 'package:flutter/foundation.dart';

class DebtorService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _dbHelper = DatabaseHelper();

  /// Guarda un deudor en Supabase y SQLite localmente
  Future<void> saveDebtor(Debtor debtor) async {
    try {
      // 1. Guardar en Supabase (Esquema lytix)
      await _supabase.schema('lytix').from('debtors').upsert({
        'id': debtor.id,
        'user_id': debtor.userId,
        'name': debtor.name,
        'phone': debtor.phone,
        'email': debtor.email,
        'address': debtor.address,
        'notes': debtor.notes,
        'is_active': debtor.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Guardar en SQLite local
      await _dbHelper.debtsDb.insert(
        DbConstants.tableDebtors,
        debtor.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error al guardar deudor: $e');
      rethrow;
    }
  }

  /// Obtiene todos los deudores del usuario actual
  Future<List<Debtor>> getDebtors(String userId) async {
    try {
      // Intentar obtener de Supabase primero
      final List<dynamic> response = await _supabase
          .schema('lytix')
          .from('debtors')
          .select()
          .eq('user_id', userId)
          .order('name');

      final debtors = response
          .map((m) => Debtor.fromMap(_formatMapForModel(m)))
          .toList();

      // Actualizar SQLite local con los datos frescos
      for (var debtor in debtors) {
        await _dbHelper.debtsDb.insert(
          DbConstants.tableDebtors,
          debtor.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return debtors;
    } catch (e) {
      debugPrint('Error obteniendo deudores de Supabase, usando local: $e');
      // Si falla la red, usar SQLite
      final List<Map<String, dynamic>> maps = await _dbHelper.debtsDb.query(
        DbConstants.tableDebtors,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'name',
      );
      return maps.map((m) => Debtor.fromMap(m)).toList();
    }
  }

  // Helper para convertir booleanos de Supabase a enteros de SQLite si es necesario
  Map<String, dynamic> _formatMapForModel(Map<String, dynamic> map) {
    final newMap = Map<String, dynamic>.from(map);
    if (newMap['is_active'] is bool) {
      newMap['is_active'] = newMap['is_active'] == true ? 1 : 0;
    }
    return newMap;
  }
}

final debtorService = DebtorService();
