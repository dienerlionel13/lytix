import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/asset.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AssetDetailScreen extends StatefulWidget {
  final Asset asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late Asset _asset;
  List<AssetValuation> _valuations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    _loadValuations();
  }

  Future<void> _loadValuations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _valuations = [
        AssetValuation(
          assetId: _asset.id,
          value: _asset.currentValue,
          valuationDate: DateTime.now(),
          valuationSource: 'Actualización manual',
        ),
        AssetValuation(
          assetId: _asset.id,
          value: _asset.currentValue * 0.95,
          valuationDate: DateTime.now().subtract(const Duration(days: 90)),
          valuationSource: 'Estimación',
        ),
        AssetValuation(
          assetId: _asset.id,
          value: _asset.acquisitionValue,
          valuationDate: _asset.acquisitionDate,
          valuationSource: 'Valor de compra',
        ),
      ];
      _isLoading = false;
    });
  }

  Color get _categoryColor {
    final category = AssetCategory.defaultCategories.firstWhere(
      (c) => c.id == _asset.categoryId,
      orElse: () => AssetCategory.equipment,
    );
    try {
      return Color(
        int.parse(category.color?.replaceFirst('#', '0xFF') ?? '0xFF667eea'),
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
                      _buildAssetCard(),
                      const SizedBox(height: 20),
                      _buildValueStats(),
                      const SizedBox(height: 20),
                      _buildDetailsSection(),
                      const SizedBox(height: 20),
                      _buildValuationHistory(),
                      const SizedBox(height: 20),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
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
          const Expanded(
            child: Text(
              'Detalle del Activo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/asset/add',
                arguments: _asset,
              );
              if (result != null && result is Asset) {
                setState(() => _asset = result);
              }
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildAssetCard() {
    final isPositive = _asset.hasAppreciated;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_categoryColor, _categoryColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _categoryColor.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(_asset.categoryId),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _asset.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_asset.description != null)
                      Text(
                        _asset.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Valor Actual',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _asset.formattedCurrentValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_asset.formattedValueChangePercentage} desde adquisición',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildValueStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Adquisición',
            value: _asset.formattedAcquisitionValue,
            icon: Icons.shopping_cart_outlined,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Cambio',
            value: _asset.formattedValueChange,
            icon: _asset.hasAppreciated
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: _asset.hasAppreciated ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildDetailsSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Fecha de adquisición',
            value:
                '${_asset.acquisitionDate.day}/${_asset.acquisitionDate.month}/${_asset.acquisitionDate.year}',
          ),

          if (_asset.location != null)
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              value: _asset.location!,
            ),

          if (_asset.brand != null || _asset.model != null)
            _DetailRow(
              icon: Icons.devices_outlined,
              label: 'Marca / Modelo',
              value: [
                _asset.brand,
                _asset.model,
              ].where((e) => e != null).join(' '),
            ),

          if (_asset.serialNumber != null)
            _DetailRow(
              icon: Icons.tag_outlined,
              label: 'Número de serie',
              value: _asset.serialNumber!,
            ),

          _DetailRow(
            icon: _asset.isInsured
                ? Icons.verified_user
                : Icons.shield_outlined,
            label: 'Seguro',
            value: _asset.isInsured ? 'Asegurado' : 'No asegurado',
            valueColor: _asset.isInsured ? AppColors.success : Colors.white70,
          ),

          if (_asset.notes != null) ...[
            const Divider(color: Colors.white12, height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes_outlined,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _asset.notes!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildValuationHistory() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial de Valoraciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Add new valuation
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            ...List.generate(_valuations.length, (index) {
              final valuation = _valuations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == 0 ? AppColors.accent : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            valuation.formattedValue,
                            style: TextStyle(
                              color: index == 0 ? Colors.white : Colors.white70,
                              fontWeight: index == 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${valuation.valuationDate.day}/${valuation.valuationDate.month}/${valuation.valuationDate.year}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      valuation.valuationSource ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildActions() {
    return Column(
      children: [
        GradientButton(
          text: 'Actualizar Valoración',
          onPressed: () {
            // Show valuation dialog
          },
          icon: Icons.update,
          gradient: AppColors.accentGradient,
        ),
        const SizedBox(height: 12),
        GlassCard(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surfaceDark,
                title: const Text(
                  '¿Eliminar activo?',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Esta acción eliminará "${_asset.name}" permanentemente.',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && mounted) {
              // Delete asset
              Navigator.pop(context);
            }
          },
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                color: AppColors.error.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Eliminar Activo',
                style: TextStyle(color: AppColors.error.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
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
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
