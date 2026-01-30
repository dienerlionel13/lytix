import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/asset.dart';
import '../../widgets/common/glass_card.dart';

class AssetsListScreen extends StatefulWidget {
  const AssetsListScreen({super.key});

  @override
  State<AssetsListScreen> createState() => _AssetsListScreenState();
}

class _AssetsListScreenState extends State<AssetsListScreen> {
  List<Asset> _assets = [];
  bool _isLoading = true;
  String _selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _assets = [
        Asset(
          userId: 'user1',
          categoryId: 'CAT_REAL_ESTATE',
          name: 'Casa Residencial',
          description: 'Zona 10, Ciudad de Guatemala',
          acquisitionValue: 1500000,
          currentValue: 1850000,
          acquisitionDate: DateTime(2020, 3, 15),
          location: 'Zona 10, Guatemala',
          isInsured: true,
        ),
        Asset(
          userId: 'user1',
          categoryId: 'CAT_VEHICLES',
          name: 'Toyota Corolla 2022',
          brand: 'Toyota',
          model: 'Corolla',
          acquisitionValue: 185000,
          currentValue: 165000,
          acquisitionDate: DateTime(2022, 6, 1),
          isInsured: true,
        ),
        Asset(
          userId: 'user1',
          categoryId: 'CAT_EQUIPMENT',
          name: 'MacBook Pro 16"',
          brand: 'Apple',
          model: 'MacBook Pro M3 Max',
          acquisitionValue: 45000,
          currentValue: 38000,
          acquisitionDate: DateTime(2023, 11, 20),
        ),
        Asset(
          userId: 'user1',
          categoryId: 'CAT_INVESTMENTS',
          name: 'Fondo BAM Dólares',
          description: 'Inversión en fondo diversificado',
          acquisitionValue: 100000,
          currentValue: 112500,
          currency: 'USD',
          acquisitionDate: DateTime(2023, 1, 10),
        ),
        Asset(
          userId: 'user1',
          categoryId: 'CAT_EQUIPMENT',
          name: 'Cámara Sony A7III',
          brand: 'Sony',
          model: 'A7III',
          acquisitionValue: 18000,
          currentValue: 14000,
          acquisitionDate: DateTime(2021, 8, 5),
        ),
      ];
      _isLoading = false;
    });
  }

  List<Asset> get _filteredAssets {
    if (_selectedCategoryId == 'all') return _assets;
    return _assets.where((a) => a.categoryId == _selectedCategoryId).toList();
  }

  double get _totalValue => _assets.fold(0.0, (sum, a) => sum + a.currentValue);
  double get _totalAcquisition =>
      _assets.fold(0.0, (sum, a) => sum + a.acquisitionValue);
  double get _totalChange => _totalValue - _totalAcquisition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSummaryCard(),
              _buildCategoryFilter(),
              Expanded(child: _buildAssetsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/asset/add'),
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
              'Mis Activos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Todo: Show analytics
            },
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildSummaryCard() {
    final changePercentage = _totalAcquisition > 0
        ? ((_totalValue - _totalAcquisition) / _totalAcquisition) * 100
        : 0.0;
    final isPositive = _totalChange >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.3),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Patrimonio Total',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Q ${_totalValue.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? AppColors.success : AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(Q ${_totalChange.abs().toStringAsFixed(0)})',
                    style: TextStyle(
                      color: (isPositive ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Activos',
                  value: '${_assets.length}',
                  icon: Icons.inventory_2_outlined,
                ),
                _SummaryItem(
                  label: 'Asegurados',
                  value: '${_assets.where((a) => a.isInsured).length}',
                  icon: Icons.verified_user_outlined,
                ),
                _SummaryItem(
                  label: 'Categorías',
                  value: '${_assets.map((a) => a.categoryId).toSet().length}',
                  icon: Icons.category_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {
        'id': 'all',
        'name': 'Todos',
        'icon': Icons.apps,
        'color': AppColors.primary,
      },
      {
        'id': 'CAT_REAL_ESTATE',
        'name': 'Inmuebles',
        'icon': Icons.home_outlined,
        'color': const Color(0xFF00D4AA),
      },
      {
        'id': 'CAT_VEHICLES',
        'name': 'Vehículos',
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF6C5CE7),
      },
      {
        'id': 'CAT_EQUIPMENT',
        'name': 'Equipo',
        'icon': Icons.camera_alt_outlined,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'id': 'CAT_INVESTMENTS',
        'name': 'Inversiones',
        'icon': Icons.trending_up,
        'color': const Color(0xFFFFBE0B),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategoryId == cat['id'];
          final color = cat['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _selectedCategoryId = cat['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? color : Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        color: isSelected ? color : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildAssetsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_filteredAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay activos en esta categoría',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredAssets.length,
      itemBuilder: (context, index) {
        final asset = _filteredAssets[index];
        return _AssetCard(
              asset: asset,
              onTap: () => Navigator.pushNamed(
                context,
                '/asset/detail',
                arguments: asset,
              ),
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
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const _AssetCard({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = asset.hasAppreciated;
    final category = AssetCategory.defaultCategories.firstWhere(
      (c) => c.id == asset.categoryId,
      orElse: () => AssetCategory.equipment,
    );
    final categoryColor = _parseColor(category.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          children: [
            // Category icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(asset.categoryId),
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.description ?? category.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Value
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  asset.formattedCurrentValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? AppColors.success : AppColors.error,
                      size: 12,
                    ),
                    Text(
                      asset.formattedValueChangePercentage,
                      style: TextStyle(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
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

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'CAT_REAL_ESTATE':
        return Icons.home_outlined;
      case 'CAT_VEHICLES':
        return Icons.directions_car_outlined;
      case 'CAT_EQUIPMENT':
        return Icons.camera_alt_outlined;
      case 'CAT_INVESTMENTS':
        return Icons.trending_up;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
