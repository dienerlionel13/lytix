import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/debtor.dart';
import '../../data/datasources/local/database_helper.dart';
import '../constants/db_constants.dart';
import 'package:flutter/foundation.dart';

class ReceivableService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _dbHelper = DatabaseHelper();

  /// Guarda una deuda (receivable) en Supabase y SQLite
  Future<void> saveReceivable(Receivable receivable) async {
    try {
      // 1. Guardar en Supabase (Esquema lytix)
      await _supabase.schema('lytix').from('receivables').upsert({
        'id': receivable.id,
        'debtor_id': receivable.debtorId,
        'description': receivable.description,
        'initial_amount': receivable.initialAmount,
        'currency': receivable.currency,
        'exchange_rate': receivable.exchangeRate,
        'due_date': receivable.dueDate?.toIso8601String(),
        'status': receivable.status.name.toUpperCase(),
        'notes': receivable.notes,
        'purchase_id': receivable.purchaseId,
        'category_id': receivable.categoryId,
        'debtor_name': receivable.debtorName,
        'balance_type': receivable.balanceType,
        'transaction_date': receivable.transactionDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Guardar en SQLite local
      await _dbHelper.debtsDb.insert(
        DbConstants.tableReceivables,
        receivable.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error al guardar deuda: $e');
      rethrow;
    }
  }

  /// Obtiene todas las deudas de un deudor específico
  Future<List<Receivable>> getReceivables(String debtorId) async {
    try {
      // Optimizamos cargando las deudas y sus pagos en una sola consulta
      final List<dynamic> response = await _supabase
          .schema('lytix')
          .from('receivables')
          .select('*, receivable_payments(amount)')
          .eq('debtor_id', debtorId)
          .order('created_at', ascending: false);

      final List<Receivable> receivables = [];

      for (var m in response) {
        final receivable = Receivable.fromMap(m);
        // Sumar todos los pagos para calcular el total pagado
        final payments = m['receivable_payments'] as List<dynamic>? ?? [];
        double totalPaid = 0;
        for (var p in payments) {
          totalPaid += (p['amount'] as num).toDouble();
        }
        receivable.paidAmount = totalPaid;
        receivables.add(receivable);

        // Actualizamos caché local
        await _dbHelper.debtsDb.insert(
          DbConstants.tableReceivables,
          receivable.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return receivables;
    } catch (e) {
      debugPrint('Error obteniendo deudas de Supabase, usando local: $e');
      final List<Map<String, dynamic>> maps = await _dbHelper.debtsDb.query(
        DbConstants.tableReceivables,
        where: 'debtor_id = ?',
        whereArgs: [debtorId],
        orderBy: 'created_at DESC',
      );
      return maps.map((m) => Receivable.fromMap(m)).toList();
    }
  }

  /// Obtiene todas las deudas de todos los deudores de un usuario
  Future<List<Receivable>> getAllUserReceivables(String userId) async {
    try {
      // Optimizamos cargando deudas y pagos en una sola consulta con join
      final List<dynamic> response = await _supabase
          .schema('lytix')
          .from('receivables')
          .select('*, debtors!inner(user_id), receivable_payments(amount)')
          .eq('debtors.user_id', userId);

      final List<Receivable> receivables = [];

      for (var m in response) {
        final receivable = Receivable.fromMap(m);
        final payments = m['receivable_payments'] as List<dynamic>? ?? [];
        double totalPaid = 0;
        for (var p in payments) {
          totalPaid += (p['amount'] as num).toDouble();
        }
        receivable.paidAmount = totalPaid;
        receivables.add(receivable);
      }

      return receivables;
    } catch (e) {
      debugPrint('Error obteniendo todas las deudas, usando local: $e');
      final List<Map<String, dynamic>> maps = await _dbHelper.debtsDb.rawQuery(
        '''
        SELECT r.* FROM receivables r
        JOIN debtors d ON r.debtor_id = d.id
        WHERE d.user_id = ?
      ''',
        [userId],
      );
      return maps.map((m) => Receivable.fromMap(m)).toList();
    }
  }

  /// Obtiene los pagos de una deuda específica
  Future<List<ReceivablePayment>> getPayments(String receivableId) async {
    try {
      final List<dynamic> response = await _supabase
          .schema('lytix')
          .from('receivable_payments')
          .select()
          .eq('receivable_id', receivableId)
          .order('payment_date', ascending: false);

      final payments = response
          .map((m) => ReceivablePayment.fromMap(m))
          .toList();

      for (var payment in payments) {
        await _dbHelper.debtsDb.insert(
          'receivable_payments',
          payment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return payments;
    } catch (e) {
      debugPrint('Error obteniendo pagos, usando local: $e');
      final List<Map<String, dynamic>> maps = await _dbHelper.debtsDb.query(
        'receivable_payments',
        where: 'receivable_id = ?',
        whereArgs: [receivableId],
        orderBy: 'payment_date DESC',
      );
      return maps.map((m) => ReceivablePayment.fromMap(m)).toList();
    }
  }

  /// Registra un pago para una deuda
  Future<void> savePayment(ReceivablePayment payment) async {
    try {
      // 1. Guardar el pago en Supabase
      await _supabase.schema('lytix').from('receivable_payments').insert({
        'id': payment.id,
        'receivable_id': payment.receivableId,
        'amount': payment.amount,
        'currency': payment.currency,
        'exchange_rate': payment.exchangeRate,
        'payment_date': payment.paymentDate.toIso8601String(),
        'payment_method': payment.paymentMethod,
        'notes': payment.notes,
        'receipt_number': payment.receiptNumber,
      });

      // 2. Guardar el pago en SQLite local
      await _dbHelper.debtsDb.insert(
        DbConstants.tableReceivablePayments,
        payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 3. Actualizar el paid_amount de la deuda en local
      // Obtenemos todos los pagos para esta deuda
      final List<Map<String, dynamic>> maps = await _dbHelper.debtsDb.query(
        DbConstants.tableReceivablePayments,
        where: 'receivable_id = ?',
        whereArgs: [payment.receivableId],
      );

      double totalPaid = 0;
      for (var m in maps) {
        totalPaid += (m['amount'] as num).toDouble();
      }

      // Actualizar la tabla de deudas
      await _dbHelper.debtsDb.update(
        DbConstants.tableReceivables,
        {
          'paid_amount': totalPaid,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [payment.receivableId],
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error al guardar pago: $e');
      rethrow;
    }
  }

  /// Guarda una categoría de deuda
  Future<void> saveCategory(ReceivableCategory category) async {
    try {
      await _supabase
          .schema('lytix')
          .from('receivable_categories')
          .upsert(category.toMap());
      await _dbHelper.debtsDb.insert(
        DbConstants.tableReceivableCategories,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error al guardar categoría: $e');
      rethrow;
    }
  }

  /// Obtiene las categorías de deuda del usuario
  Future<List<ReceivableCategory>> getCategories(String userId) async {
    try {
      final List<dynamic> response = await _supabase
          .schema('lytix')
          .from('receivable_categories')
          .select()
          .eq('user_id', userId)
          .order('name');

      final categories = response
          .map((m) => ReceivableCategory.fromMap(m))
          .toList();

      return categories;
    } catch (e) {
      debugPrint('Error obteniendo categorías, usando local: $e');
      final List<Map<String, dynamic>> maps = await _dbHelper.debtsDb.query(
        DbConstants.tableReceivableCategories,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'name',
      );
      return maps.map((m) => ReceivableCategory.fromMap(m)).toList();
    }
  }

  /// Elimina una categoría
  Future<void> deleteCategory(String id) async {
    try {
      await _supabase
          .schema('lytix')
          .from('receivable_categories')
          .delete()
          .eq('id', id);
      await _dbHelper.debtsDb.delete(
        DbConstants.tableReceivableCategories,
        where: 'id = ?',
        whereArgs: [id],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar categoría: $e');
      rethrow;
    }
  }

  /// Elimina una deuda (receivable)
  Future<void> deleteReceivable(String id) async {
    try {
      await _supabase.schema('lytix').from('receivables').delete().eq('id', id);
      await _dbHelper.debtsDb.delete(
        DbConstants.tableReceivables,
        where: 'id = ?',
        whereArgs: [id],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar deuda: $e');
      rethrow;
    }
  }
}

final receivableService = ReceivableService();
