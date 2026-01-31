import 'package:sqflite/sqflite.dart';
import '../constants/db_constants.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/models/shared_purchase.dart';
import '../../data/models/debtor.dart';

class PurchaseService {
  /// Saves a shared purchase and its splits
  /// Creates Receivables for each debtor share
  /// Updates Credit Card balance if a card was used
  Future<void> saveSharedPurchase({
    required SharedPurchase purchase,
    required List<PurchaseSplit> splits,
  }) async {
    final purchasesDb = databaseHelper.purchasesDb;
    final debtsDb = databaseHelper.debtsDb;

    await purchasesDb.transaction((txn) async {
      // 1. Save Purchase Header
      await txn.insert(
        DbConstants.tableSharedPurchases,
        purchase.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Process each split
      for (var split in splits) {
        String? receivableId;

        // 3. If it's a debtor share, create a Receivable
        if (!split.isUserShare && split.debtorId != null) {
          final receivable = Receivable(
            debtorId: split.debtorId!,
            description: 'Compartido: ${purchase.description}',
            initialAmount: split.amount,
            currency: purchase.currency,
            exchangeRate: purchase.exchangeRate,
            transactionDate: purchase.purchaseDate,
            purchaseId: purchase.id,
          );

          await debtsDb.insert(
            DbConstants.tableReceivables,
            receivable.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          receivableId = receivable.id;
        }

        // 4. Save Split record with link to receivable
        final updatedSplit = PurchaseSplit(
          id: split.id,
          purchaseId: purchase.id,
          debtorId: split.debtorId,
          amount: split.amount,
          isUserShare: split.isUserShare,
          receivableId: receivableId,
          createdAt: split.createdAt,
        );

        await txn.insert(
          DbConstants.tablePurchaseSplits,
          updatedSplit.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    // 5. Update Credit Card balance if applicable
    if (purchase.cardId != null) {
      await _updateCardBalance(purchase.cardId!, purchase.totalAmount);
    }

    // 6. Log for Sync (when Supabase integration is ready)
    await databaseHelper.logSync(
      databaseName: DbConstants.purchasesDatabase,
      tableName: DbConstants.tableSharedPurchases,
      recordId: purchase.id,
      action: 'INSERT',
    );
  }

  Future<void> _updateCardBalance(String cardId, double amount) async {
    final cardsDb = databaseHelper.cardsDb;

    // Fetch current balance
    final List<Map<String, dynamic>> maps = await cardsDb.query(
      DbConstants.tableCreditCards,
      columns: ['current_balance'],
      where: 'id = ?',
      whereArgs: [cardId],
    );

    if (maps.isNotEmpty) {
      double currentBalance = (maps.first['current_balance'] as num).toDouble();
      double newBalance = currentBalance + amount;

      await cardsDb.update(
        DbConstants.tableCreditCards,
        {
          'current_balance': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [cardId],
      );

      // Log card update for sync
      await databaseHelper.logSync(
        databaseName: DbConstants.cardsDatabase,
        tableName: DbConstants.tableCreditCards,
        recordId: cardId,
        action: 'UPDATE',
      );
    }
  }

  /// Fetches all shared purchases with their splits
  Future<List<Map<String, dynamic>>> getSharedPurchases() async {
    final db = databaseHelper.purchasesDb;
    return await db.query(
      DbConstants.tableSharedPurchases,
      orderBy: 'purchase_date DESC',
    );
  }
}

final purchaseService = PurchaseService();
