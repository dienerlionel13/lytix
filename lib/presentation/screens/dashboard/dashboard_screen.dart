import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/connectivity_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/connectivity_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Net Worth Card
                    _buildNetWorthCard()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Quick Stats Row
                    _buildQuickStats()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Debt Ratio Indicator
                    _buildDebtRatioCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 150.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Expense Distribution Pie Chart
                    _buildExpenseDistribution()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Assets vs Debts Bar Chart
                    _buildAssetsVsDebts()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 20),

                    // Monthly Expenses (Visacuotas)
                    _buildMonthlyExpenses()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 100), // Bottom padding for nav
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick add action
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms).fadeIn(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 70,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Lytix',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        // Connectivity Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChangeNotifierProvider.value(
            value: connectivityService,
            child: Consumer<ConnectivityService>(
              builder: (context, connectivity, child) {
                return AnimatedConnectivityIndicator(
                  isConnected: connectivity.isConnected,
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white70),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNetWorthCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patrimonio Neto',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: GoogleFonts.poppins(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Q 125,450.00',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$ 16,060.26 USD',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('Activos', 'Q 285,000', AppColors.success),
              const SizedBox(width: 24),
              _buildMiniStat('Deudas', 'Q 159,550', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Activos',
            value: 'Q 285,000',
            icon: Icons.account_balance_wallet,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Deudas',
            value: 'Q 159,550',
            icon: Icons.credit_card,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Ratio',
            value: '56%',
            icon: Icons.pie_chart,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtRatioCard() {
    const ratio = 0.56;
    final color = ratio > 0.5 ? AppColors.warning : AppColors.success;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratio de Endeudamiento',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '56%',
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deuda Total: Q 159,550',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                'Activos: Q 285,000',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDistribution() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Gastos',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 45,
                      sections: [
                        PieChartSectionData(
                          value: 35,
                          color: AppColors.chartColors[0],
                          title: '35%',
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: 25,
                          color: AppColors.chartColors[1],
                          title: '25%',
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: 20,
                          color: AppColors.chartColors[2],
                          title: '20%',
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: 12,
                          color: AppColors.chartColors[3],
                          title: '12%',
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: 8,
                          color: AppColors.chartColors[4],
                          title: '8%',
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(
                        color: AppColors.chartColors[0],
                        label: 'Vivienda',
                      ),
                      _LegendItem(
                        color: AppColors.chartColors[1],
                        label: 'Transporte',
                      ),
                      _LegendItem(
                        color: AppColors.chartColors[2],
                        label: 'Alimentación',
                      ),
                      _LegendItem(
                        color: AppColors.chartColors[3],
                        label: 'Servicios',
                      ),
                      _LegendItem(
                        color: AppColors.chartColors[4],
                        label: 'Otros',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsVsDebts() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activos vs Deudas',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 300000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final value = rod.toY;
                      return BarTooltipItem(
                        'Q ${value.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 285000,
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        width: 50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 159550,
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.error, Color(0xFFFF8A8A)],
                        ),
                        width: 50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = ['Activos', 'Deudas'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyExpenses() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos del Mes',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Diciembre 2024',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ExpenseRow(
            title: 'Visacuotas',
            amount: 'Q 4,250.00',
            icon: Icons.credit_card,
          ),
          const _ExpenseRow(
            title: 'Servicios',
            amount: 'Q 1,200.00',
            icon: Icons.receipt,
          ),
          const _ExpenseRow(
            title: 'Préstamos',
            amount: 'Q 3,500.00',
            icon: Icons.account_balance,
          ),
          const _ExpenseRow(
            title: 'Otros',
            amount: 'Q 850.00',
            icon: Icons.more_horiz,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total del Mes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Q 9,800.00',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.backgroundDark.withValues(alpha: 0.9),
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: _currentNavIndex == 0,
                  onTap: () => setState(() => _currentNavIndex = 0),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Deudas',
                  isActive: _currentNavIndex == 1,
                  onTap: () {
                    setState(() => _currentNavIndex = 1);
                    Navigator.pushNamed(context, '/debtors');
                  },
                ),
                _NavItem(
                  icon: Icons.credit_card,
                  label: 'Tarjetas',
                  isActive: _currentNavIndex == 2,
                  onTap: () {
                    setState(() => _currentNavIndex = 2);
                    Navigator.pushNamed(context, '/cards');
                  },
                ),
                _NavItem(
                  icon: Icons.pie_chart,
                  label: 'Activos',
                  isActive: _currentNavIndex == 3,
                  onTap: () {
                    setState(() => _currentNavIndex = 3);
                    Navigator.pushNamed(context, '/assets');
                  },
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Ajustes',
                  isActive: _currentNavIndex == 4,
                  onTap: () {
                    setState(() => _currentNavIndex = 4);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widgets

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;

  const _ExpenseRow({
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white54,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
