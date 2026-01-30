import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/budget.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddTransactionScreen extends StatefulWidget {
  final BudgetTransaction? transaction;
  final BudgetCategory? category;

  const AddTransactionScreen({super.key, this.transaction, this.category});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _hasChanges = false;

  bool get isEditing => widget.transaction != null;

  // Simulated categories
  final List<BudgetCategory> _categories = [
    BudgetCategory(
      id: 'cat1',
      userId: 'user1',
      name: 'Vivienda',
      icon: 'home',
      color: '#667eea',
      budgetedAmount: 5000,
      type: BudgetType.expense,
    ),
    BudgetCategory(
      id: 'cat2',
      userId: 'user1',
      name: 'Alimentación',
      icon: 'restaurant',
      color: '#00D4AA',
      budgetedAmount: 3500,
      type: BudgetType.expense,
    ),
    BudgetCategory(
      id: 'cat3',
      userId: 'user1',
      name: 'Transporte',
      icon: 'directions_car',
      color: '#FFBE0B',
      budgetedAmount: 2000,
      type: BudgetType.expense,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedCategoryId = widget.category!.id;
    }
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _notesController.text = widget.transaction!.notes ?? '';
      _selectedDate = widget.transaction!.date;
      _selectedCategoryId = widget.transaction!.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
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
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = BudgetTransaction(
        id: widget.transaction?.id,
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text.trim()),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Transacción actualizada' : 'Transacción registrada',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, transaction);
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
                          _buildAmountInput(),
                          const SizedBox(height: 20),
                          _buildCategorySelector(),
                          const SizedBox(height: 16),
                          _buildDetails(),
                          const SizedBox(height: 16),
                          _buildDateSelector(),
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
            isEditing ? 'Editar Gasto' : 'Nuevo Gasto',
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

  Widget _buildAmountInput() {
    return GlassCard(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            'Monto',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Q ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
              IntrinsicWidth(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white30),
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '';
                    if (double.tryParse(v) == null) return '';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildCategorySelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categoría',
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
            children: _categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              final color = _parseColor(category.color);

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategoryId = category.id;
                  _hasChanges = true;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIcon(category.icon),
                        color: isSelected ? color : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
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
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildDetails() {
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

          _buildTextField(
            controller: _descriptionController,
            label: 'Descripción',
            icon: Icons.description_outlined,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _notesController,
            label: 'Notas (opcional)',
            icon: Icons.notes_outlined,
            maxLines: 2,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildDateSelector() {
    return GlassCard(
      onTap: _selectDate,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
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
      text: isEditing ? 'Actualizar' : 'Guardar Gasto',
      onPressed: _isLoading ? null : _save,
      isLoading: _isLoading,
      icon: Icons.save_outlined,
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _hasChanges = true;
      });
    }
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
      default:
        return Icons.category_outlined;
    }
  }
}
