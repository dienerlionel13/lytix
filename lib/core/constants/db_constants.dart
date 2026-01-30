// Database Constants
// Separate database files for each module

class DbConstants {
  DbConstants._();

  // Database Version
  static const int databaseVersion = 3;

  // Individual Database Files
  static const String mainDatabase = 'lytix_main.db';
  static const String usersDatabase = 'lytix_users.db';
  static const String debtsDatabase = 'lytix_debts.db';
  static const String cardsDatabase = 'lytix_cards.db';
  static const String budgetDatabase = 'lytix_budget.db';
  static const String assetsDatabase = 'lytix_assets.db';
  static const String purchasesDatabase = 'lytix_purchases.db';
  static const String syncDatabase = 'lytix_sync.db';

  // Table Names - Users
  static const String tableUsers = 'users';

  // Table Names - Debts (Receivables)
  static const String tableDebtors = 'debtors';
  static const String tableReceivables = 'receivables';
  static const String tableReceivableCategories = 'receivable_categories';
  static const String tableReceivablePayments = 'receivable_payments';

  // Table Names - Debts (Payables)
  static const String tableCreditors = 'creditors';
  static const String tablePayables = 'payables';
  static const String tablePayablePayments = 'payable_payments';

  // Table Names - Cards
  static const String tableCreditCards = 'credit_cards';
  static const String tableVisacuotas = 'visacuotas';

  // Table Names - Budget
  static const String tableBudgetCategories = 'budget_categories';
  static const String tableBudgetItems = 'budget_items';

  // Table Names - Assets
  static const String tableAssetCategories = 'asset_categories';
  static const String tableAssets = 'assets';

  // Table Names - Shared Purchases
  static const String tableSharedPurchases = 'shared_purchases';
  static const String tablePurchaseSplits = 'purchase_splits';

  // Table Names - Exchange Rates
  static const String tableExchangeRates = 'exchange_rates';

  // Table Names - Sync
  static const String tableSyncLog = 'sync_log';
}
