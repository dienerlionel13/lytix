import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/credit_card.dart';
import '../../widgets/common/glass_card.dart';

class CardsListScreen extends StatefulWidget {
  const CardsListScreen({super.key});

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  final List<CreditCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _cards.addAll([
        CreditCard(
          userId: 'user1',
          name: 'Visa Oro',
          bankName: 'Banco Industrial',
          cardType: CardType.visa,
          lastFourDigits: '4521',
          creditLimit: 50000,
          currentBalance: 15000,
          cutOffDay: 15,
          paymentDay: 25,
          color: '#667eea',
        ),
        CreditCard(
          userId: 'user1',
          name: 'Mastercard Platinum',
          bankName: 'BAC Credomatic',
          cardType: CardType.mastercard,
          lastFourDigits: '8932',
          creditLimit: 75000,
          currentBalance: 32500,
          cutOffDay: 20,
          paymentDay: 5,
          color: '#764ba2',
        ),
        CreditCard(
          userId: 'user1',
          name: 'American Express',
          bankName: 'Banrural',
          cardType: CardType.amex,
          lastFourDigits: '1234',
          creditLimit: 100000,
          currentBalance: 8500,
          cutOffDay: 10,
          paymentDay: 20,
          color: '#00D4AA',
        ),
      ]);
      _isLoading = false;
    });
  }

  double get _totalLimit => _cards.fold(0.0, (sum, c) => sum + c.creditLimit);
  double get _totalBalance =>
      _cards.fold(0.0, (sum, c) => sum + c.currentBalance);
  double get _totalAvailable => _totalLimit - _totalBalance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSummaryCards(),
              Expanded(child: _buildCardsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/card/add'),
        backgroundColor: AppColors.primary,
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
                  'Tarjetas de Crédito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_cards.length} tarjetas',
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

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'Límite Total',
              amount: 'Q ${_formatNumber(_totalLimit)}',
              color: AppColors.info,
              icon: Icons.credit_card,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              title: 'Utilizado',
              amount: 'Q ${_formatNumber(_totalBalance)}',
              color: AppColors.warning,
              icon: Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              title: 'Disponible',
              amount: 'Q ${_formatNumber(_totalAvailable)}',
              color: AppColors.success,
              icon: Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildCardsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin tarjetas registradas',
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
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return _CreditCardWidget(
              card: card,
              onTap: () =>
                  Navigator.pushNamed(context, '/card/detail', arguments: card),
            )
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  final CreditCard card;
  final VoidCallback onTap;

  const _CreditCardWidget({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _parseColor(card.color),
                _parseColor(card.color).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _parseColor(card.color).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(painter: _CardPatternPainter()),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card.bankName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _buildCardTypeIcon(card.cardType),
                      ],
                    ),

                    const Spacer(),

                    // Card number
                    Text(
                      '•••• •••• •••• ${card.lastFourDigits ?? '****'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Corte: ${card.cutOffDay} | Pago: ${card.paymentDay}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              card.formattedBalance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${card.usagePercentage.toStringAsFixed(0)}% usado',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
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
        ),
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return AppColors.primary;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Widget _buildCardTypeIcon(CardType type) {
    String text;
    switch (type) {
      case CardType.visa:
        text = 'VISA';
        break;
      case CardType.mastercard:
        text = 'MC';
        break;
      case CardType.amex:
        text = 'AMEX';
        break;
      case CardType.other:
        text = 'CARD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      size.width * 0.3,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      size.width * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
