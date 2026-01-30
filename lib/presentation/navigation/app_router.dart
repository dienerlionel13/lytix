import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/debts/debtors_list_screen.dart';
import '../screens/debts/add_debtor_screen.dart';
import '../screens/debts/debtor_detail_screen.dart';
import '../screens/debts/add_receivable_screen.dart';
import '../screens/debts/receivable_categories_screen.dart';
import '../screens/debts/creditors_list_screen.dart';
import '../screens/debts/add_creditor_screen.dart';
import '../screens/cards/cards_list_screen.dart';
import '../screens/cards/add_card_screen.dart';
import '../screens/cards/card_detail_screen.dart';
import '../screens/cards/visacuotas_list_screen.dart';
import '../screens/cards/add_visacuota_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/budget/add_budget_category_screen.dart';
import '../screens/budget/add_transaction_screen.dart';
import '../screens/assets/assets_list_screen.dart';
import '../screens/assets/add_asset_screen.dart';
import '../screens/assets/asset_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/currency_settings_screen.dart';
import '../screens/purchases/add_shared_purchase_screen.dart';
import '../../data/models/debtor.dart';
import '../../data/models/creditor.dart';
import '../../data/models/credit_card.dart';
import '../../data/models/budget.dart';
import '../../data/models/asset.dart';

/// App Router - Handles all navigation routes
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String about = '/about';

  // Debts
  static const String debtors = '/debtors';
  static const String addDebtor = '/debtor/add';
  static const String debtorDetail = '/debtor/detail';
  static const String addReceivable = '/debtor/receivable/add';
  static const String receivableCategories = '/debtor/categories';
  static const String creditors = '/creditors';
  static const String addCreditor = '/creditor/add';
  static const String creditorDetail = '/creditor/detail';

  // Cards
  static const String cards = '/cards';
  static const String addCard = '/card/add';
  static const String cardDetail = '/card/detail';
  static const String visacuotas = '/visacuotas';
  static const String addVisacuota = '/visacuota/add';

  // Budget
  static const String budget = '/budget';
  static const String addBudgetCategory = '/budget/category/add';
  static const String addTransaction = '/budget/transaction/add';

  // Assets
  static const String assets = '/assets';
  static const String addAsset = '/asset/add';
  static const String assetDetail = '/asset/detail';

  // Purchases
  static const String addSharedPurchase = '/purchase/shared/add';

  // Settings
  static const String settingsRoute = '/settings';
  static const String currencySettings = '/settings/currency';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildPageRoute(const SplashScreen(), settings);

      case login:
        return _buildPageRoute(const LoginScreen(), settings);

      case dashboard:
        return _buildPageRoute(const DashboardScreen(), settings);

      case profile:
        return _buildPageRoute(const ProfileScreen(), settings);

      case about:
        return _buildPageRoute(const AboutScreen(), settings);

      // Debtors (Cuentas por Cobrar)
      case debtors:
        return _buildPageRoute(const DebtorsListScreen(), settings);

      case addDebtor:
        final debtor = settings.arguments as Debtor?;
        return _buildPageRoute(AddDebtorScreen(debtor: debtor), settings);

      case debtorDetail:
        final debtor = settings.arguments as Debtor;
        return _buildPageRoute(DebtorDetailScreen(debtor: debtor), settings);

      case addReceivable:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildPageRoute(
          AddReceivableScreen(
            debtor: args['debtor'] as Debtor,
            receivable: args['receivable'] as Receivable?,
          ),
          settings,
        );

      case receivableCategories:
        final userId = settings.arguments as String;
        return _buildPageRoute(
          ReceivableCategoriesScreen(userId: userId),
          settings,
        );

      // Creditors (Cuentas por Pagar)
      case creditors:
        return _buildPageRoute(const CreditorsListScreen(), settings);

      case addCreditor:
        final creditor = settings.arguments as Creditor?;
        return _buildPageRoute(AddCreditorScreen(creditor: creditor), settings);

      // Cards (Tarjetas)
      case cards:
        return _buildPageRoute(const CardsListScreen(), settings);

      case addCard:
        final card = settings.arguments as CreditCard?;
        return _buildPageRoute(AddCardScreen(card: card), settings);

      case cardDetail:
        final card = settings.arguments as CreditCard;
        return _buildPageRoute(CardDetailScreen(card: card), settings);

      // Visacuotas
      case visacuotas:
        return _buildPageRoute(const VisacuotasListScreen(), settings);

      case addVisacuota:
        final card = settings.arguments as CreditCard?;
        return _buildPageRoute(AddVisacuotaScreen(card: card), settings);

      // Budget
      case budget:
        return _buildPageRoute(const BudgetScreen(), settings);

      case addBudgetCategory:
        final category = settings.arguments as BudgetCategory?;
        return _buildPageRoute(
          AddBudgetCategoryScreen(category: category),
          settings,
        );

      case addTransaction:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          AddTransactionScreen(
            transaction: args?['transaction'] as BudgetTransaction?,
            category: args?['category'] as BudgetCategory?,
          ),
          settings,
        );

      // Assets
      case assets:
        return _buildPageRoute(const AssetsListScreen(), settings);

      case addAsset:
        final asset = settings.arguments as Asset?;
        return _buildPageRoute(AddAssetScreen(asset: asset), settings);

      case assetDetail:
        final asset = settings.arguments as Asset;
        return _buildPageRoute(AssetDetailScreen(asset: asset), settings);

      // Purchases
      case addSharedPurchase:
        return _buildPageRoute(const AddSharedPurchaseScreen(), settings);

      // Settings
      case settingsRoute:
        return _buildPageRoute(const SettingsScreen(), settings);

      case currencySettings:
        return _buildPageRoute(const CurrencySettingsScreen(), settings);

      default:
        return _buildPageRoute(
          Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
