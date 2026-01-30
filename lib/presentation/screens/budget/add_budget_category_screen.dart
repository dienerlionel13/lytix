import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/budget.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddBudgetCategoryScreen extends StatefulWidget {
  final BudgetCategory? category;

  const AddBudgetCategoryScreen({super.key, this.category});

  @override
  State<AddBudgetCategoryScreen> createState() =>
      _AddBudgetCategoryScreenState();
}

class _AddBudgetCategoryScreenState extends State<AddBudgetCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedIcon = 'category';
  String _selectedColor = '#667eea';
  BudgetType _selectedType = BudgetType.expense;
  bool _isLoading = false;
  bool _hasChanges = false;

  bool get isEditing => widget.category != null;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'home', 'icon': Icons.home_outlined, 'label': 'Vivienda'},
    {
      'name': 'restaurant',
      'icon': Icons.restaurant_outlined,
      'label': 'Comida',
    },
    {
      'name': 'directions_car',
      'icon': Icons.directions_car_outlined,
      'label': 'Transporte',
    },
    {'name': 'movie', 'icon': Icons.movie_outlined, 'label': 'Entretenimiento'},
    {'name': 'bolt', 'icon': Icons.bolt_outlined, 'label': 'Servicios'},
    {
      'name': 'medical_services',
      'icon': Icons.medical_services_outlined,
      'label': 'Salud',
    },
    {
      'name': 'shopping',
      'icon': Icons.shopping_bag_outlined,
      'label': 'Compras',
    },
    {'name': 'school', 'icon': Icons.school_outlined, 'label': 'Educación'},
    {'name': 'fitness', 'icon': Icons.fitness_center_outlined, 'label': 'Gym'},
    {'name': 'pets', 'icon': Icons.pets_outlined, 'label': 'Mascotas'},
    {'name': 'child', 'icon': Icons.child_care_outlined, 'label': 'Hijos'},
    {'name': 'savings', 'icon': Icons.savings_outlined, 'label': 'Ahorros'},
  ];

  final List<String> _colors = [
    '#667eea',
    '#00D4AA',
    '#FFBE0B',
    '#FF6B6B',
    '#74B9FF',
    '#E17055',
    '#00CEC9',
    '#FD79A8',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _amountController.text = widget.category!.budgetedAmount.toString();
      _selectedIcon = widget.category!.icon ?? 'category';
      _selectedColor = widget.category!.color ?? '#667eea';
      _selectedType = widget.category!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          '¿Descartar cambios?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Deseas descartarlos?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Descartar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = BudgetCategory(
        id: widget.category?.id,
        userId: 'current_user',
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        budgetedAmount: double.parse(_amountController.text.trim()),
        type: _selectedType,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Categoría actualizada' : 'Categoría creada',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, category);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      onChanged: () => setState(() => _hasChanges = true),
                      child: Column(
                        children: [
                          _buildPreview(),
                          const SizedBox(height: 24),
                          _buildTypeSelector(),
                          const SizedBox(height: 16),
                          _buildBasicInfo(),
                          const SizedBox(height: 16),
                          _buildIconSelector(),
                          const SizedBox(height: 16),
                          _buildColorSelector(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            isEditing ? 'Editar Categoría' : 'Nueva Categoría',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPreview() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _parseColor(_selectedColor).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getSelectedIcon(),
              color: _parseColor(_selectedColor),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'Nombre'
                      : _nameController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedType == BudgetType.expense ? 'Gasto' : 'Ingreso',
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
                'Q ${_amountController.text.isEmpty ? '0' : _amountController.text}',
                style: TextStyle(
                  color: _parseColor(_selectedColor),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '/mes',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildTypeSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _TypeOption(
              label: 'Gasto',
              icon: Icons.arrow_upward,
              isSelected: _selectedType == BudgetType.expense,
              color: AppColors.error,
              onTap: () => setState(() {
                _selectedType = BudgetType.expense;
                _hasChanges = true;
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeOption(
              label: 'Ingreso',
              icon: Icons.arrow_downward,
              isSelected: _selectedType == BudgetType.income,
              color: AppColors.success,
              onTap: () => setState(() {
                _selectedType = BudgetType.income;
                _hasChanges = true;
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildBasicInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameController,
            label: 'Nombre de categoría',
            icon: Icons.label_outlined,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _amountController,
            label: 'Monto presupuestado (Q)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildIconSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ícono',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _icons.map((iconData) {
              final isSelected = _selectedIcon == iconData['name'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedIcon = iconData['name'];
                  _hasChanges = true;
                }),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _parseColor(_selectedColor).withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? _parseColor(_selectedColor)
                          : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData['icon'] as IconData,
                    color: isSelected
                        ? _parseColor(_selectedColor)
                        : Colors.white70,
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildColorSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _colors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedColor = color;
                  _hasChanges = true;
                }),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: _parseColor(color), blurRadius: 10)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GradientButton(
      text: isEditing ? 'Actualizar' : 'Crear Categoría',
      onPressed: _isLoading ? null : _save,
      isLoading: _isLoading,
      icon: Icons.save_outlined,
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getSelectedIcon() {
    final iconData = _icons.firstWhere(
      (i) => i['name'] == _selectedIcon,
      orElse: () => {'icon': Icons.category_outlined},
    );
    return iconData['icon'] as IconData;
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
