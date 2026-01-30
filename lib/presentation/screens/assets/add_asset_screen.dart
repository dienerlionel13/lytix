import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/asset.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddAssetScreen extends StatefulWidget {
  final Asset? asset;

  const AddAssetScreen({super.key, this.asset});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _acquisitionValueController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategoryId = 'CAT_EQUIPMENT';
  String _selectedCurrency = 'GTQ';
  DateTime _acquisitionDate = DateTime.now();
  bool _isInsured = false;
  bool _isLoading = false;
  bool _hasChanges = false;

  bool get isEditing => widget.asset != null;

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      final asset = widget.asset!;
      _nameController.text = asset.name;
      _descriptionController.text = asset.description ?? '';
      _brandController.text = asset.brand ?? '';
      _modelController.text = asset.model ?? '';
      _serialController.text = asset.serialNumber ?? '';
      _acquisitionValueController.text = asset.acquisitionValue.toString();
      _currentValueController.text = asset.currentValue.toString();
      _locationController.text = asset.location ?? '';
      _notesController.text = asset.notes ?? '';
      _selectedCategoryId = asset.categoryId;
      _selectedCurrency = asset.currency;
      _acquisitionDate = asset.acquisitionDate;
      _isInsured = asset.isInsured;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _acquisitionValueController.dispose();
    _currentValueController.dispose();
    _locationController.dispose();
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

    setState(() => _isLoading = true);

    try {
      final asset = Asset(
        id: widget.asset?.id,
        userId: 'current_user',
        categoryId: _selectedCategoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        serialNumber: _serialController.text.trim().isEmpty
            ? null
            : _serialController.text.trim(),
        acquisitionValue: double.parse(_acquisitionValueController.text.trim()),
        currentValue: double.parse(_currentValueController.text.trim()),
        currency: _selectedCurrency,
        acquisitionDate: _acquisitionDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isInsured: _isInsured,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Activo actualizado' : 'Activo registrado',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, asset);
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
                          _buildCategorySelector(),
                          const SizedBox(height: 16),
                          _buildBasicInfo(),
                          const SizedBox(height: 16),
                          _buildProductDetails(),
                          const SizedBox(height: 16),
                          _buildValuation(),
                          const SizedBox(height: 16),
                          _buildAdditionalInfo(),
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
            isEditing ? 'Editar Activo' : 'Nuevo Activo',
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
            children: AssetCategory.defaultCategories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              final color = _parseColor(category.color);

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategoryId = category.id;
                  _hasChanges = true;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                        _getCategoryIcon(category.id),
                        color: isSelected ? color : Colors.white70,
                        size: 20,
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
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildBasicInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Básica',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameController,
            label: 'Nombre del activo',
            icon: Icons.inventory_2_outlined,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _descriptionController,
            label: 'Descripción (opcional)',
            icon: Icons.description_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _locationController,
            label: 'Ubicación (opcional)',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildProductDetails() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles del Producto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _brandController,
                  label: 'Marca',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _modelController,
                  label: 'Modelo',
                  icon: Icons.devices_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _serialController,
            label: 'Número de serie (opcional)',
            icon: Icons.tag_outlined,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildValuation() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valoración',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Currency selector
          Row(
            children: [
              const Text('Moneda:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 16),
              _CurrencyOption(
                label: 'GTQ',
                isSelected: _selectedCurrency == 'GTQ',
                onTap: () => setState(() {
                  _selectedCurrency = 'GTQ';
                  _hasChanges = true;
                }),
              ),
              const SizedBox(width: 8),
              _CurrencyOption(
                label: 'USD',
                isSelected: _selectedCurrency == 'USD',
                onTap: () => setState(() {
                  _selectedCurrency = 'USD';
                  _hasChanges = true;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _acquisitionValueController,
                  label: 'Valor de adquisición',
                  icon: Icons.shopping_cart_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _currentValueController,
                  label: 'Valor actual',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Acquisition date
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de adquisición',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_acquisitionDate.day}/${_acquisitionDate.month}/${_acquisitionDate.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildAdditionalInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Adicional',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Insurance toggle
          GestureDetector(
            onTap: () => setState(() {
              _isInsured = !_isInsured;
              _hasChanges = true;
            }),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isInsured
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: _isInsured ? AppColors.success : Colors.white24,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isInsured ? Icons.verified_user : Icons.shield_outlined,
                    color: _isInsured ? AppColors.success : Colors.white54,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Activo asegurado',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Switch(
                    value: _isInsured,
                    onChanged: (v) => setState(() {
                      _isInsured = v;
                      _hasChanges = true;
                    }),
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ),
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
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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
      text: isEditing ? 'Actualizar' : 'Registrar Activo',
      onPressed: _isLoading ? null : _save,
      isLoading: _isLoading,
      icon: Icons.save_outlined,
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate,
      firstDate: DateTime(2000),
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
        _acquisitionDate = date;
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

class _CurrencyOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
