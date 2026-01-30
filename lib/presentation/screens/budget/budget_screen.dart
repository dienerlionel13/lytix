import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/budget.dart';
import '../../widgets/common/glass_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<BudgetCategory> _categories = [];
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _categories = [
        BudgetCategory(
          userId: 'user1',
          name: 'Vivienda',
          icon: 'home',
          color: '#667eea',
          budgetedAmount: 5000,
          spentAmount: 4800,
          type: BudgetType.expense,
        ),
        BudgetCategory(
          userId: 'user1',
          name: 'Alimentación',
          icon: 'restaurant',
          color: '#00D4AA',
          budgetedAmount: 3500,
          spentAmount: 2800,
          type: BudgetType.expense,
        ),
        BudgetCategory(
          userId: 'user1',
          name: 'Transporte',
          icon: 'directions_car',
          color: '#FFBE0B',
          budgetedAmount: 2000,
          spentAmount: 2350,
          type: BudgetType.expense,
        ),
        BudgetCategory(
          userId: 'user1',
          name: 'Entretenimiento',
          icon: 'movie',
          color: '#FF6B6B',
          budgetedAmount: 1500,
          spentAmount: 800,
          type: BudgetType.expense,
        ),
        BudgetCategory(
          userId: 'user1',
          name: 'Servicios',
          icon: 'bolt',
          color: '#74B9FF',
          budgetedAmount: 1200,
          spentAmount: 1180,
          type: BudgetType.expense,
        ),
        BudgetCategory(
          userId: 'user1',
          name: 'Salud',
          icon: 'medical_services',
          color: '#E17055',
          budgetedAmount: 800,
          spentAmount: 450,
          type: BudgetType.expense,
        ),
      ];
      _isLoading = false;
    });
  }

  double get _totalBudgeted =>
      _categories.fold(0.0, (sum, c) => sum + c.budgetedAmount);
  double get _totalSpent =>
      _categories.fold(0.0, (sum, c) => sum + c.spentAmount);
  double get _remaining => _totalBudgeted - _totalSpent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildMonthSelector(),
              _buildSummaryCard(),
              Expanded(child: _buildCategoriesList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/budget/add'),
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
          const Expanded(
            child: Text(
              'Presupuesto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Todo: Show settings/analytics
            },
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildMonthSelector() {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          GestureDetector(
            onTap: () async {
              // Show month picker
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildSummaryCard() {
    final percentage = _totalBudgeted > 0
        ? (_totalSpent / _totalBudgeted)
        : 0.0;
    final isOverBudget = _totalSpent > _totalBudgeted;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress ring
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(
                        isOverBudget ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: isOverBudget
                                ? AppColors.error
                                : Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOverBudget ? 'Excedido' : 'Usado',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Presupuestado',
                    value: 'Q ${_totalBudgeted.toStringAsFixed(0)}',
                    color: AppColors.info,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Gastado',
                    value: 'Q ${_totalSpent.toStringAsFixed(0)}',
                    color: isOverBudget ? AppColors.error : AppColors.warning,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Restante',
                    value: 'Q ${_remaining.abs().toStringAsFixed(0)}',
                    color: _remaining >= 0
                        ? AppColors.success
                        : AppColors.error,
                    prefix: _remaining < 0 ? '-' : '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildCategoriesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _CategoryCard(
              category: category,
              onTap: () {
                // Show category detail/transactions
              },
            )
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1);
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String prefix;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$prefix$value',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final BudgetCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percentage = category.budgetedAmount > 0
        ? (category.spentAmount / category.budgetedAmount)
        : 0.0;
    final isOverBudget = category.spentAmount > category.budgetedAmount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _parseColor(category.color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(category.icon),
                    color: _parseColor(category.color),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Q ${category.spentAmount.toStringAsFixed(0)} de Q ${category.budgetedAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isOverBudget ? AppColors.error : AppColors.primary)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isOverBudget ? AppColors.error : AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget ? AppColors.error : _parseColor(category.color),
                ),
                minHeight: 6,
              ),
            ),
          ],
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

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'bolt':
        return Icons.bolt_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'school':
        return Icons.school_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
