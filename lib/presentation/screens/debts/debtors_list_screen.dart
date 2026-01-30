import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/debtor.dart';
import '../../widgets/common/glass_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/debtor_service.dart';
import '../../../core/services/receivable_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DebtorsListScreen extends StatefulWidget {
  const DebtorsListScreen({super.key});

  @override
  State<DebtorsListScreen> createState() => _DebtorsListScreenState();
}

class _DebtorsListScreenState extends State<DebtorsListScreen> {
  final List<Debtor> _debtors = [];
  final List<Receivable> _allReceivables = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final _currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadDebtors();
  }

  Future<void> _loadDebtors() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final debtorService = Provider.of<DebtorService>(context, listen: false);
      final recService = Provider.of<ReceivableService>(context, listen: false);

      if (authService.currentUser != null) {
        final userId = authService.currentUser!.id;
        final debtors = await debtorService.getDebtors(userId);
        final receivables = await recService.getAllUserReceivables(userId);

        setState(() {
          _debtors.clear();
          _debtors.addAll(debtors);
          _allReceivables.clear();
          _allReceivables.addAll(receivables);
        });
      }
    } catch (e) {
      debugPrint('Error cargando datos de deudores: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _globalBalance {
    // Solo sumamos los saldos positivos (lo que me deben)
    return _allReceivables
        .where((r) => r.initialAmount > 0)
        .fold(0.0, (sum, r) => sum + r.pendingAmount);
  }

  double _getDebtorBalance(String debtorId) {
    return _allReceivables
        .where((r) => r.debtorId == debtorId)
        .fold(0.0, (sum, r) => sum + r.pendingAmount);
  }

  int _getDebtorDebtCount(String debtorId) {
    return _allReceivables.where((r) => r.debtorId == debtorId).length;
  }

  List<Debtor> get _filteredDebtors {
    if (_searchQuery.isEmpty) return _debtors;
    return _debtors
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (d.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(child: _buildDebtorsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deudores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_debtors.length} personas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/debtor/add');
              if (result != null) {
                _loadDebtors();
              }
            },
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
          ),
          const SizedBox(width: 8),
          _buildTotalReceivables(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildTotalReceivables() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Por Cobrar',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(_globalBalance),
            style: TextStyle(
              color: _globalBalance >= 0 ? AppColors.success : AppColors.error,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar deudor...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildDebtorsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_filteredDebtors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'Sin deudores' : 'Sin resultados',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredDebtors.length,
      itemBuilder: (context, index) {
        final debtor = _filteredDebtors[index];
        final balance = _getDebtorBalance(debtor.id);
        final count = _getDebtorDebtCount(debtor.id);
        return _DebtorCard(
              debtor: debtor,
              balance: balance,
              debtCount: count,
              currencyFormat: _currencyFormat,
              onTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/debtor/detail',
                  arguments: debtor,
                );
                if (result != null) {
                  _loadDebtors();
                }
              },
            )
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1);
      },
    );
  }
}

class _DebtorCard extends StatelessWidget {
  final Debtor debtor;
  final double balance;
  final int debtCount;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _DebtorCard({
    required this.debtor,
    required this.balance,
    required this.debtCount,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  debtor.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debtor.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (debtor.phone != null)
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          debtor.phone!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(balance.abs()),
                  style: TextStyle(
                    color: balance >= 0 ? AppColors.success : AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (balance >= 0 ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    balance >= 0 ? 'Me debe' : 'Le debo',
                    style: TextStyle(
                      color: balance >= 0 ? AppColors.success : AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$debtCount ${debtCount == 1 ? 'deuda' : 'deudas'}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
