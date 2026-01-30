import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/receivable_service.dart';
import '../../../data/models/debtor.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import 'package:intl/intl.dart';
import '../../navigation/app_router.dart';

class AddReceivableScreen extends StatefulWidget {
  final Debtor debtor;
  final Receivable? receivable;

  const AddReceivableScreen({super.key, required this.debtor, this.receivable});

  @override
  State<AddReceivableScreen> createState() => _AddReceivableScreenState();
}

class _AddReceivableScreenState extends State<AddReceivableScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  DateTime? _dueDate;
  DateTime? _transactionDate;
  String? _selectedCategoryId;
  List<ReceivableCategory> _categories = [];
  bool _isPositiveBalance = true; // true = Él me debe, false = Yo le debo
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  bool get isEditing => widget.receivable != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.receivable?.description,
    );
    _amountController = TextEditingController(
      text: widget.receivable != null
          ? widget.receivable!.initialAmount.toString()
          : '',
    );
    _notesController = TextEditingController(text: widget.receivable?.notes);
    _dueDate = widget.receivable?.dueDate;
    _transactionDate = widget.receivable?.transactionDate;
    _selectedCategoryId = widget.receivable?.categoryId;
    if (widget.receivable != null) {
      _isPositiveBalance = widget.receivable!.initialAmount >= 0;
      // If editing, use the absolute value for the controller
      _amountController.text = widget.receivable!.initialAmount
          .abs()
          .toString();
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final receivableService = Provider.of<ReceivableService>(
        context,
        listen: false,
      );
      final categories = await receivableService.getCategories(
        widget.debtor.userId,
      );
      if (mounted) {
        setState(() {
          _categories = categories;
          _isCategoriesLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
      if (mounted) {
        setState(() => _isCategoriesLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTransactionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _transactionDate) {
      setState(() {
        _transactionDate = picked;
      });
    }
  }

  Future<void> _saveReceivable() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final receivableService = Provider.of<ReceivableService>(
        context,
        listen: false,
      );

      final baseAmount = double.parse(_amountController.text.trim());
      final finalAmount = _isPositiveBalance ? baseAmount : -baseAmount;

      final receivable = Receivable(
        id: widget.receivable?.id,
        debtorId: widget.debtor.id,
        description: _descriptionController.text.trim(),
        initialAmount: finalAmount,
        dueDate: _dueDate,
        categoryId: _selectedCategoryId,
        debtorName: widget.debtor.name,
        balanceType: _isPositiveBalance ? 'Por Cobrar' : 'Por Pagar',
        transactionDate: _transactionDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        dateCreated: widget.receivable?.dateCreated ?? DateTime.now(),
        status: widget.receivable?.status ?? ReceivableStatus.pending,
        paidAmount: widget.receivable?.paidAmount ?? 0,
      );

      await receivableService.saveReceivable(receivable);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Deuda actualizada' : 'Deuda registrada'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  padding: const EdgeInsets.all(24),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
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
            child: Text(
              isEditing ? 'Editar Deuda' : 'Nueva Deuda',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deudor',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              widget.debtor.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Balance Type Selector (MOVIDO ARRIBA)
                    const Text(
                      '¿Quién debe a quién?',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _BalanceTypeCard(
                            title: 'Por Cobrar',
                            isSelected: _isPositiveBalance,
                            color: AppColors.success,
                            icon: Icons.add_circle_outline,
                            onTap: () =>
                                setState(() => _isPositiveBalance = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BalanceTypeCard(
                            title: 'Por Pagar',
                            isSelected: !_isPositiveBalance,
                            color: AppColors.error,
                            icon: Icons.remove_circle_outline,
                            onTap: () =>
                                setState(() => _isPositiveBalance = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Concepto / Descripción',
                        hintText: 'Ej. Préstamo para alquiler',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingresa una descripción'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _isCategoriesLoading
                              ? const LinearProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  value: _selectedCategoryId,
                                  dropdownColor: AppColors.surfaceDark,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Categoría',
                                    prefixIcon: Icon(Icons.category_outlined),
                                  ),
                                  items: _categories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedCategoryId = value);
                                  },
                                  validator: (value) => value == null
                                      ? 'Selecciona una categoría'
                                      : null,
                                ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_suggest_outlined,
                            color: AppColors.primary,
                          ),
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRouter.receivableCategories,
                              arguments: widget.debtor.userId,
                            );
                            _loadCategories(); // Reload when coming back
                          },
                          tooltip: 'Gestionar categorías',
                        ),
                        if (!_isCategoriesLoading && _categories.isEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                            ),
                            onPressed: _loadCategories,
                            tooltip: 'Reintentar cargar categorías',
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Monto (GTQ)',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.money_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el monto';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Transaction Date (Fecha de Pertenencia)
                    InkWell(
                      onTap: () => _selectTransactionDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha de pertenencia (Opcional)',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _transactionDate != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_transactionDate!)
                                      : 'Elegir fecha...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (_transactionDate != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _transactionDate = null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Due Date
                    InkWell(
                      onTap: () => _selectDueDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha de vencimiento (Opcional)',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _dueDate != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_dueDate!)
                                      : 'No establecida',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (_dueDate != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _dueDate = null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notas adicionales',
                        hintText: 'Más detalles sobre la deuda...',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: GradientButton(
          text: isEditing ? 'Actualizar Deuda' : 'Registrar Deuda',
          onPressed: _isLoading ? null : _saveReceivable,
          isLoading: _isLoading,
          icon: Icons.save_outlined,
        ),
      ),
    );
  }
}

class _BalanceTypeCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _BalanceTypeCard({
    required this.title,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
