import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/purchase_service.dart';
import '../../../data/models/shared_purchase.dart';
import '../../../data/models/debtor.dart';
import '../../../data/models/credit_card.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddSharedPurchaseScreen extends StatefulWidget {
  const AddSharedPurchaseScreen({super.key});

  @override
  State<AddSharedPurchaseScreen> createState() =>
      _AddSharedPurchaseScreenState();
}

class _AddSharedPurchaseScreenState extends State<AddSharedPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  List<CreditCard> _cards = [];
  CreditCard? _selectedCard;

  List<Debtor> _allDebtors = [];
  final List<Debtor> _selectedDebtors = [];
  final Map<String, double> _manualSplits = {};

  bool _isLoading = false;
  final bool _isEqualSplit = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final cardsData = await databaseHelper.query(
        databaseHelper.cardsDb,
        DbConstants.tableCreditCards,
      );
      final debtorsData = await databaseHelper.query(
        databaseHelper.debtsDb,
        DbConstants.tableDebtors,
      );

      setState(() {
        _cards = cardsData.map((m) => CreditCard.fromMap(m)).toList();
        _allDebtors = debtorsData.map((m) => Debtor.fromMap(m)).toList();
      });
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateSplits() {
    if (_isEqualSplit) {
      double total = double.tryParse(_amountController.text) ?? 0;
      int parts = _selectedDebtors.length + 1; // +1 for the user
      if (parts > 0) {
        double each = total / parts;
        _manualSplits.clear();
        for (var d in _selectedDebtors) {
          _manualSplits[d.id] = each;
        }
      }
    }
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      double totalAmount = double.parse(_amountController.text);
      final purchase = SharedPurchase(
        userId: 'current_user',
        description: _descriptionController.text.trim(),
        totalAmount: totalAmount,
        cardId: _selectedCard?.id,
        purchaseDate: DateTime.now(),
      );

      List<PurchaseSplit> splits = [];

      // User's share
      double userShare;
      if (_isEqualSplit) {
        userShare = totalAmount / (_selectedDebtors.length + 1);
      } else {
        double debtorsTotal = _manualSplits.values.fold(
          0,
          (sum, val) => sum + val,
        );
        userShare = totalAmount - debtorsTotal;
      }

      splits.add(
        PurchaseSplit(
          purchaseId: purchase.id,
          amount: userShare,
          isUserShare: true,
        ),
      );

      // Debtors' shares
      for (var debtor in _selectedDebtors) {
        splits.add(
          PurchaseSplit(
            purchaseId: purchase.id,
            debtorId: debtor.id,
            amount: _isEqualSplit
                ? (totalAmount / (_selectedDebtors.length + 1))
                : (_manualSplits[debtor.id] ?? 0),
          ),
        );
      }

      await purchaseService.saveSharedPurchase(
        purchase: purchase,
        splits: splits,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra guardada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildBasicInfo(),
                        const SizedBox(height: 20),
                        _buildCardSelector(),
                        const SizedBox(height: 20),
                        _buildDebtorsSelector(),
                        const SizedBox(height: 32),
                        GradientButton(
                          text: 'Guardar Compra',
                          onPressed: _isLoading ? null : _savePurchase,
                          isLoading: _isLoading,
                          icon: Icons.check_circle_outline,
                        ),
                      ],
                    ),
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
          const Text(
            'Nueva Compra Compartida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildBasicInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles de la Compra',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Descripción (ej. Súper, Cena)',
            icon: Icons.description_outlined,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _amountController,
            label: 'Monto Total',
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _calculateSplits()),
            validator: (v) =>
                (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Monto inválido' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCardSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarjeta de Crédito (Opcional)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CreditCard>(
            value: _selectedCard,
            dropdownColor: AppColors.surfaceDark,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              'Seleccionar Tarjeta',
              Icons.credit_card,
            ),
            items: _cards
                .map(
                  (c) => DropdownMenuItem(value: c, child: Text(c.displayName)),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedCard = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtorsSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dividir con:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_add_alt_1,
                  color: AppColors.primary,
                ),
                onPressed: _showDebtorsDialog,
              ),
            ],
          ),
          if (_selectedDebtors.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No has seleccionado deudores',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ..._selectedDebtors.map(
            (d) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(d.initials, style: const TextStyle(fontSize: 12)),
              ),
              title: Text(d.name, style: const TextStyle(color: Colors.white)),
              trailing: Text(
                'Q ${_isEqualSplit ? ((double.tryParse(_amountController.text) ?? 0) / (_selectedDebtors.length + 1)).toStringAsFixed(2) : (_manualSplits[d.id] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.success),
              ),
              onLongPress: () => setState(() {
                _selectedDebtors.remove(d);
                _calculateSplits();
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showDebtorsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'Seleccionar Deudores',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allDebtors.length,
              itemBuilder: (context, i) {
                final d = _allDebtors[i];
                final isSelected = _selectedDebtors.contains(d);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(
                    d.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onChanged: (v) {
                    setDialogState(() {
                      if (v!) {
                        _selectedDebtors.add(d);
                      } else {
                        _selectedDebtors.remove(d);
                      }
                    });
                    setState(() => _calculateSplits());
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
      filled: true,
      fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
