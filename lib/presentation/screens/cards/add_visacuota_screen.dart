import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/models/visacuota.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddVisacuotaScreen extends StatefulWidget {
  final CreditCard? card; // Pre-selected card
  final Visacuota? visacuota; // For editing

  const AddVisacuotaScreen({super.key, this.card, this.visacuota});

  @override
  State<AddVisacuotaScreen> createState() => _AddVisacuotaScreenState();
}

class _AddVisacuotaScreenState extends State<AddVisacuotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _storeController = TextEditingController();
  final _totalController = TextEditingController();
  final _notesController = TextEditingController();

  int _installments = 12;
  int _chargeDay = 15;
  DateTime _purchaseDate = DateTime.now();
  DateTime _firstChargeDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedCardId;
  String _selectedCategory = 'Otros';

  bool _isLoading = false;
  bool _hasChanges = false;

  bool get isEditing => widget.visacuota != null;

  // Simulated cards list
  final List<CreditCard> _cards = [
    CreditCard(
      id: 'card1',
      userId: 'user1',
      name: 'Visa Oro',
      bankName: 'Banco Industrial',
      creditLimit: 50000,
      cutOffDay: 15,
      paymentDay: 25,
    ),
    CreditCard(
      id: 'card2',
      userId: 'user1',
      name: 'Mastercard Platinum',
      bankName: 'BAC',
      creditLimit: 75000,
      cutOffDay: 20,
      paymentDay: 5,
    ),
  ];

  final List<String> _categories = [
    'Tecnología',
    'Hogar',
    'Electrodomésticos',
    'Vestuario',
    'Salud',
    'Educación',
    'Vehículos',
    'Otros',
  ];

  final List<int> _installmentOptions = [3, 6, 12, 18, 24, 36, 48];

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _selectedCardId = widget.card!.id;
      _chargeDay = widget.card!.cutOffDay;
    }
    if (widget.visacuota != null) {
      _descriptionController.text = widget.visacuota!.description;
      _storeController.text = widget.visacuota!.storeName ?? '';
      _totalController.text = widget.visacuota!.totalAmount.toString();
      _installments = widget.visacuota!.totalInstallments;
      _chargeDay = widget.visacuota!.chargeDay;
      _purchaseDate = widget.visacuota!.purchaseDate;
      _firstChargeDate = widget.visacuota!.firstChargeDate;
      _selectedCardId = widget.visacuota!.cardId;
      _selectedCategory = widget.visacuota!.category ?? 'Otros';
      _notesController.text = widget.visacuota!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _storeController.dispose();
    _totalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _monthlyAmount {
    final total = double.tryParse(_totalController.text) ?? 0;
    if (_installments == 0) return 0;
    return total / _installments;
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
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una tarjeta'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final visacuota = Visacuota(
        id: widget.visacuota?.id,
        cardId: _selectedCardId!,
        description: _descriptionController.text.trim(),
        storeName: _storeController.text.trim().isEmpty
            ? null
            : _storeController.text.trim(),
        totalAmount: double.parse(_totalController.text.trim()),
        totalInstallments: _installments,
        monthlyAmount: _monthlyAmount,
        chargeDay: _chargeDay,
        purchaseDate: _purchaseDate,
        firstChargeDate: _firstChargeDate,
        category: _selectedCategory,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Visacuota actualizada' : 'Visacuota creada',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, visacuota);
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
                          _buildPreviewCard(),
                          const SizedBox(height: 20),
                          _buildCardSelector(),
                          const SizedBox(height: 16),
                          _buildBasicInfo(),
                          const SizedBox(height: 16),
                          _buildInstallmentsConfig(),
                          const SizedBox(height: 16),
                          _buildDatesConfig(),
                          const SizedBox(height: 16),
                          _buildCategoryNotes(),
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
            isEditing ? 'Editar Visacuota' : 'Nueva Visacuota',
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

  Widget _buildPreviewCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: AppColors.accentGradient,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cuota Mensual',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                _selectedCardId != null
                    ? _cards.firstWhere((c) => c.id == _selectedCardId).name
                    : 'Sin tarjeta',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Q ${_monthlyAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_installments cuotas',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'Día $_chargeDay',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildCardSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarjeta de Crédito',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._cards.map((card) {
            final isSelected = _selectedCardId == card.id;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCardId = card.id;
                _chargeDay = card.cutOffDay;
                _hasChanges = true;
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: isSelected ? AppColors.accent : Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.accent
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            card.bankName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.accent),
                  ],
                ),
              ),
            );
          }),
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
            'Información de Compra',
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
            icon: Icons.shopping_bag_outlined,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _storeController,
            label: 'Tienda (opcional)',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _totalController,
            label: 'Monto Total (Q)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInstallmentsConfig() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuotas',
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
            children: _installmentOptions.map((count) {
              final isSelected = _installments == count;
              return GestureDetector(
                onTap: () => setState(() {
                  _installments = count;
                  _hasChanges = true;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$num',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildDatesConfig() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fechas',
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
                child: _DateField(
                  label: 'Fecha de Compra',
                  date: _purchaseDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Primer Cargo',
                  date: _firstChargeDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                'Día de cargo:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _chargeDay,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: List.generate(31, (i) => i + 1).map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(
                            '$day',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() {
                        _chargeDay = v!;
                        _hasChanges = true;
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildCategoryNotes() {
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
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = cat;
                  _hasChanges = true;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _notesController,
            label: 'Notas (opcional)',
            icon: Icons.notes_outlined,
            maxLines: 2,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
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
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GradientButton(
      text: isEditing ? 'Actualizar' : 'Crear Visacuota',
      onPressed: _isLoading ? null : _save,
      isLoading: _isLoading,
      icon: Icons.save_outlined,
      gradient: AppColors.accentGradient,
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Future<void> _selectDate(bool isPurchase) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isPurchase ? _purchaseDate : _firstChargeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = date;
        } else {
          _firstChargeDate = date;
        }
        _hasChanges = true;
      });
    }
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
