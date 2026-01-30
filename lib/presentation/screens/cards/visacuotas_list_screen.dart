import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/visacuota.dart';
import '../../widgets/common/glass_card.dart';

class VisacuotasListScreen extends StatefulWidget {
  const VisacuotasListScreen({super.key});

  @override
  State<VisacuotasListScreen> createState() => _VisacuotasListScreenState();
}

class _VisacuotasListScreenState extends State<VisacuotasListScreen> {
  List<Visacuota> _visacuotas = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // all, active, paid

  @override
  void initState() {
    super.initState();
    _loadVisacuotas();
  }

  Future<void> _loadVisacuotas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _visacuotas = [
        Visacuota(
          cardId: 'card1',
          description: 'iPhone 15 Pro Max',
          storeName: 'iShop Guatemala',
          totalAmount: 12000,
          totalInstallments: 24,
          monthlyAmount: 500,
          chargeDay: 15,
          purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 45)),
          category: 'Tecnología',
        ),
        Visacuota(
          cardId: 'card1',
          description: 'MacBook Pro M3',
          storeName: 'Apple Store',
          totalAmount: 24000,
          totalInstallments: 36,
          monthlyAmount: 666.67,
          chargeDay: 15,
          purchaseDate: DateTime.now().subtract(const Duration(days: 120)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 105)),
          category: 'Tecnología',
        ),
        Visacuota(
          cardId: 'card2',
          description: 'Sala de cuero italiano',
          storeName: 'Muebles Modernos',
          totalAmount: 18000,
          totalInstallments: 18,
          monthlyAmount: 1000,
          chargeDay: 20,
          purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 75)),
          category: 'Hogar',
        ),
        Visacuota(
          cardId: 'card2',
          description: 'Refrigeradora LG',
          storeName: 'Tiendas Max',
          totalAmount: 8500,
          totalInstallments: 12,
          monthlyAmount: 708.33,
          chargeDay: 20,
          purchaseDate: DateTime.now().subtract(const Duration(days: 150)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 135)),
          category: 'Electrodomésticos',
        ),
      ];
      _isLoading = false;
    });
  }

  List<Visacuota> get _filteredVisacuotas {
    switch (_filterStatus) {
      case 'active':
        return _visacuotas
            .where((v) => v.status == VisacuotaStatus.active)
            .toList();
      case 'paid':
        return _visacuotas
            .where((v) => v.status == VisacuotaStatus.completed)
            .toList();
      default:
        return _visacuotas;
    }
  }

  double get _totalMonthly => _visacuotas
      .where((v) => v.status == VisacuotaStatus.active)
      .fold(0.0, (sum, v) => sum + v.monthlyAmount);

  double get _totalPending => _visacuotas
      .where((v) => v.status == VisacuotaStatus.active)
      .fold(0.0, (sum, v) => sum + v.pendingBalance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSummary(),
              _buildFilters(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/visacuota/add'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 300.ms, duration: 300.ms),
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
                  'Visacuotas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_visacuotas.length} compras a cuotas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cargo Mensual',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Q ${_totalMonthly.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Pendiente',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Q ${_totalPending.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todas',
            isSelected: _filterStatus == 'all',
            onTap: () => setState(() => _filterStatus = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Activas',
            isSelected: _filterStatus == 'active',
            onTap: () => setState(() => _filterStatus = 'active'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pagadas',
            isSelected: _filterStatus == 'paid',
            onTap: () => setState(() => _filterStatus = 'paid'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_filteredVisacuotas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin visacuotas',
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredVisacuotas.length,
      itemBuilder: (context, index) {
        final visacuota = _filteredVisacuotas[index];
        return _VisacuotaListCard(
              visacuota: visacuota,
              onTap: () {
                // Show detail
              },
            )
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1);
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _VisacuotaListCard extends StatelessWidget {
  final Visacuota visacuota;
  final VoidCallback onTap;

  const _VisacuotaListCard({required this.visacuota, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final paidInstallments =
        visacuota.totalInstallments - visacuota.remainingInstallments;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visacuota.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        visacuota.storeName ?? 'Tienda',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      visacuota.formattedMonthlyAmount,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/mes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: visacuota.progressPercentage,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(visacuota.progressPercentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$paidInstallments de ${visacuota.totalInstallments} cuotas',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      visacuota.status,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(visacuota.status),
                    style: TextStyle(
                      color: _getStatusColor(visacuota.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(VisacuotaStatus status) {
    switch (status) {
      case VisacuotaStatus.active:
        return AppColors.success;
      case VisacuotaStatus.completed:
        return AppColors.info;
      case VisacuotaStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(VisacuotaStatus status) {
    switch (status) {
      case VisacuotaStatus.active:
        return 'Activa';
      case VisacuotaStatus.completed:
        return 'Pagada';
      case VisacuotaStatus.cancelled:
        return 'Cancelada';
    }
  }
}
