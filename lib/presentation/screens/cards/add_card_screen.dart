import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/credit_card.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddCardScreen extends StatefulWidget {
  final CreditCard? card;

  const AddCardScreen({super.key, this.card});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _limitController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();

  CardType _selectedCardType = CardType.visa;
  int _cutOffDay = 15;
  int _paymentDay = 25;
  String _selectedColor = '#667eea';
  bool _isLoading = false;
  bool _hasChanges = false;

  bool get isEditing => widget.card != null;

  final List<String> _cardColors = [
    '#667eea',
    '#764ba2',
    '#00D4AA',
    '#FF6B6B',
    '#FFBE0B',
    '#00CEC9',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _nameController.text = widget.card!.name;
      _bankController.text = widget.card!.bankName;
      _lastFourController.text = widget.card!.lastFourDigits ?? '';
      _limitController.text = widget.card!.creditLimit.toString();
      _balanceController.text = widget.card!.currentBalance.toString();
      _notesController.text = widget.card!.notes ?? '';
      _selectedCardType = widget.card!.cardType;
      _cutOffDay = widget.card!.cutOffDay;
      _paymentDay = widget.card!.paymentDay;
      _selectedColor = widget.card!.color ?? '#667eea';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _lastFourController.dispose();
    _limitController.dispose();
    _balanceController.dispose();
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

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final card = CreditCard(
        id: widget.card?.id,
        userId: 'current_user',
        name: _nameController.text.trim(),
        bankName: _bankController.text.trim(),
        cardType: _selectedCardType,
        lastFourDigits: _lastFourController.text.trim(),
        creditLimit: double.parse(_limitController.text.trim()),
        currentBalance: double.tryParse(_balanceController.text.trim()) ?? 0,
        cutOffDay: _cutOffDay,
        paymentDay: _paymentDay,
        color: _selectedColor,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Tarjeta actualizada' : 'Tarjeta creada'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, card);
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
                          _buildCardPreview(),
                          const SizedBox(height: 24),
                          _buildBasicInfo(),
                          const SizedBox(height: 16),
                          _buildFinancialInfo(),
                          const SizedBox(height: 16),
                          _buildDateInfo(),
                          const SizedBox(height: 16),
                          _buildColorPicker(),
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
            isEditing ? 'Editar Tarjeta' : 'Nueva Tarjeta',
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

  Widget _buildCardPreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _parseColor(_selectedColor),
            _parseColor(_selectedColor).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _parseColor(_selectedColor).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _bankController.text.isEmpty ? 'Banco' : _bankController.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  _selectedCardType.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '•••• •••• •••• ${_lastFourController.text.isEmpty ? '****' : _lastFourController.text}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _nameController.text.isEmpty
                  ? 'Nombre de Tarjeta'
                  : _nameController.text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
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
            label: 'Nombre de tarjeta',
            icon: Icons.credit_card,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _bankController,
            label: 'Banco',
            icon: Icons.account_balance,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _lastFourController,
            label: 'Últimos 4 dígitos',
            icon: Icons.pin,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          const SizedBox(height: 12),

          // Card Type Selection
          Row(
            children: CardType.values.map((type) {
              final isSelected = _selectedCardType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedCardType = type;
                      _hasChanges = true;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white24,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildFinancialInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Financiera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _limitController,
            label: 'Límite de crédito (Q)',
            icon: Icons.money,
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _balanceController,
            label: 'Saldo actual (Q)',
            icon: Icons.account_balance_wallet,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildDateInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fechas de Ciclo',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Día de Corte',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _buildDayPicker(
                      value: _cutOffDay,
                      onChanged: (v) => setState(() {
                        _cutOffDay = v;
                        _hasChanges = true;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Día de Pago',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _buildDayPicker(
                      value: _paymentDay,
                      onChanged: (v) => setState(() {
                        _paymentDay = v;
                        _hasChanges = true;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildDayPicker({
    required int value,
    required Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceDark,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: List.generate(31, (i) => i + 1).map((day) {
            return DropdownMenuItem(
              value: day,
              child: Text('$day', style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color de Tarjeta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _cardColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedColor = color;
                  _hasChanges = true;
                }),
                child: Container(
                  width: 44,
                  height: 44,
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
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        counterText: '',
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
      text: isEditing ? 'Actualizar' : 'Guardar Tarjeta',
      onPressed: _isLoading ? null : _saveCard,
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
}
