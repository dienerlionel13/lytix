import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/models/visacuota.dart';
import '../../widgets/common/glass_card.dart';

class CardDetailScreen extends StatefulWidget {
  final CreditCard card;

  const CardDetailScreen({super.key, required this.card});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  List<Visacuota> _visacuotas = [];
  bool _isLoading = true;

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
          cardId: widget.card.id,
          description: 'iPhone 15 Pro Max',
          storeName: 'iShop',
          totalAmount: 12000,
          totalInstallments: 24,
          monthlyAmount: 500,
          chargeDay: 15,
          purchaseDate: DateTime.now().subtract(const Duration(days: 60)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 45)),
        ),
        Visacuota(
          cardId: widget.card.id,
          description: 'MacBook Pro M3',
          storeName: 'Apple Store',
          totalAmount: 24000,
          totalInstallments: 36,
          monthlyAmount: 666.67,
          chargeDay: 15,
          purchaseDate: DateTime.now().subtract(const Duration(days: 120)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 105)),
        ),
        Visacuota(
          cardId: widget.card.id,
          description: 'Sala de cuero',
          storeName: 'Muebles Modernos',
          totalAmount: 8000,
          totalInstallments: 12,
          monthlyAmount: 666.67,
          chargeDay: 15,
          purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
          firstChargeDate: DateTime.now().subtract(const Duration(days: 75)),
        ),
      ];
      _isLoading = false;
    });
  }

  double get _totalMonthlyCharge =>
      _visacuotas.fold(0.0, (sum, v) => sum + v.monthlyAmount);
  double get _totalPending =>
      _visacuotas.fold(0.0, (sum, v) => sum + v.pendingBalance);

  Color get _cardColor {
    try {
      return Color(
        int.parse(widget.card.color?.replaceFirst('#', '0xFF') ?? '0xFF667eea'),
      );
    } catch (e) {
      return AppColors.primary;
    }
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCardWidget(),
                      const SizedBox(height: 20),
                      _buildStatsRow(),
                      const SizedBox(height: 20),
                      _buildVisacuotasSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/visacuota/add',
          arguments: widget.card,
        ),
        backgroundColor: _cardColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Visacuota',
          style: TextStyle(color: Colors.white),
        ),
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
            child: Text(
              widget.card.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              '/card/add',
              arguments: widget.card,
            ),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildCardWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardColor, _cardColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pattern
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.card.bankName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.card.cardType.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  '•••• •••• •••• ${widget.card.lastFourDigits ?? '****'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Corte: ${widget.card.cutOffDay} | Pago: ${widget.card.paymentDay}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Disponible',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          widget.card.formattedAvailable,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Límite',
            value: widget.card.formattedLimit,
            icon: Icons.credit_card,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Utilizado',
            value: widget.card.formattedBalance,
            icon: Icons.trending_up,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Cuotas/Mes',
            value: 'Q ${_totalMonthlyCharge.toStringAsFixed(0)}',
            icon: Icons.calendar_today,
            color: AppColors.accent,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildVisacuotasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Visacuotas Activas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_visacuotas.length} compras',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Total pendiente: Q ${_totalPending.toStringAsFixed(2)}',
          style: TextStyle(color: AppColors.warning, fontSize: 14),
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (_visacuotas.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(_visacuotas.length, (index) {
            final visacuota = _visacuotas[index];
            return _VisacuotaCard(visacuota: visacuota)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1);
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin visacuotas activas',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VisacuotaCard extends StatelessWidget {
  final Visacuota visacuota;

  const _VisacuotaCard({required this.visacuota});

  @override
  Widget build(BuildContext context) {
    final paidInstallments =
        visacuota.totalInstallments - visacuota.remainingInstallments;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visacuota.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visacuota.storeName ?? 'Tienda',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
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
                        color: AppColors.primary,
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

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: visacuota.progressPercentage,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 12),

            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$paidInstallments / ${visacuota.totalInstallments} cuotas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Faltan ${visacuota.remainingInstallments} (${visacuota.formattedPendingBalance})',
                  style: TextStyle(
                    color: AppColors.warning.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Próximo cargo: Día ${visacuota.chargeDay}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
