import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/debtor.dart';
import '../../widgets/common/glass_card.dart';
import '../../../core/services/receivable_service.dart';
import 'package:provider/provider.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/formatters.dart';

class DebtorDetailScreen extends StatefulWidget {
  final Debtor debtor;

  const DebtorDetailScreen({super.key, required this.debtor});

  @override
  State<DebtorDetailScreen> createState() => _DebtorDetailScreenState();
}

class _DebtorDetailScreenState extends State<DebtorDetailScreen> {
  // Simulated receivables for this debtor
  final List<Receivable> _receivables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceivables();
  }

  Future<void> _loadReceivables() async {
    setState(() => _isLoading = true);
    try {
      final receivableService = Provider.of<ReceivableService>(
        context,
        listen: false,
      );
      final receivables = await receivableService.getReceivables(
        widget.debtor.id,
      );

      if (mounted) {
        setState(() {
          _receivables.clear();
          _receivables.addAll(receivables);
        });
      }
    } catch (e) {
      debugPrint('Error cargando deudas de deudor: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Calcula lo que me deben (Por cobrar) - Pendiente
  double get _totalReceivable => _receivables
      .where((r) => r.initialAmount > 0)
      .fold(0.0, (sum, r) => sum + r.pendingAmount);

  // Calcula lo que yo debo (Por pagar) - Pendiente
  double get _totalPayable => _receivables
      .where((r) => r.initialAmount < 0)
      .fold(0.0, (sum, r) => sum + r.pendingAmount.abs());

  // Balance General: (Suma de montos iniciales netos) - (Suma de abonos totales)
  // Esto asegura que si tú pagas o te pagan, el balance disminuye (menos saldo pendiente).
  double get _netBalance {
    final double initialNet = _receivables.fold(
      0.0,
      (sum, r) => sum + r.initialAmount,
    );
    final double totalPayments = _receivables.fold(
      0.0,
      (sum, r) => sum + r.paidAmount,
    );
    return initialNet - totalPayments;
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    children: [
                      _buildDebtorInfo(),
                      const SizedBox(height: 20),
                      _buildSummaryCards(),
                      const SizedBox(height: 20),
                      _buildReceivablesList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReceivable,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Deuda', style: TextStyle(color: Colors.white)),
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
          Expanded(
            child: Text(
              widget.debtor.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _editDebtor,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: _showMoreOptions,
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDebtorInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.debtor.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.debtor.phone != null)
                  _buildContactRow(Icons.phone, widget.debtor.phone!),
                if (widget.debtor.email != null)
                  _buildContactRow(Icons.email, widget.debtor.email!),
                if (widget.debtor.address != null)
                  _buildContactRow(Icons.location_on, widget.debtor.address!),
                if (widget.debtor.notes != null)
                  _buildContactRow(Icons.notes, widget.debtor.notes!),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        // Balance Card (Full Width)
        _SummaryCard(
          title: 'Balance General',
          amount: Formatters.currency(_netBalance),
          color: _netBalance >= 0 ? AppColors.success : AppColors.error,
          icon: Icons.account_balance,
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Por cobrar',
                amount: Formatters.currency(_totalReceivable),
                color: AppColors.success,
                icon: Icons.call_received,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Por pagar',
                amount: Formatters.currency(_totalPayable),
                color: AppColors.error,
                icon: Icons.call_made,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _buildReceivablesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Deudas Activas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_receivables.length} deudas',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (_receivables.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(_receivables.length, (index) {
            final receivable = _receivables[index];
            return _ReceivableCard(
                  receivable: receivable,
                  onTap: () => _showReceivableDetail(receivable),
                  onAddPayment: () => _addPayment(receivable),
                )
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1);
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin deudas registradas',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  void _editDebtor() {
    Navigator.pushNamed(context, '/debtor/add', arguments: widget.debtor);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white70),
                title: const Text(
                  'Historial de pagos',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white70,
                ),
                title: const Text(
                  'Generar recibo PDF',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _generateFullReport();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addReceivable() async {
    final result = await Navigator.pushNamed(
      context,
      '/debtor/receivable/add',
      arguments: {'debtor': widget.debtor},
    );

    if (result == true) {
      _loadReceivables();
    }
  }

  void _showReceivableDetail(Receivable receivable) async {
    final result = await Navigator.pushNamed(
      context,
      '/debtor/receivable/detail',
      arguments: {'debtor': widget.debtor, 'receivable': receivable},
    );

    if (result == true) {
      _loadReceivables();
    }
  }

  Future<void> _generateFullReport() async {
    setState(() => _isLoading = true);
    try {
      final recService = Provider.of<ReceivableService>(context, listen: false);

      // Obtener todos los pagos de todas las deudas del deudor
      final List<ReceivablePayment> allPayments = [];
      for (var receivable in _receivables) {
        final payments = await recService.getPayments(receivable.id);
        allPayments.addAll(payments);
      }

      await PdfService.generateDebtorStatement(
        debtor: widget.debtor,
        receivables: _receivables,
        allPayments: allPayments,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addPayment(Receivable receivable) {
    final amountController = TextEditingController(
      text: receivable.pendingAmount.abs() > 0
          ? receivable.pendingAmount.abs().toStringAsFixed(2)
          : '',
    );
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Registrar Abono',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deuda: ${receivable.description}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Monto del abono (Q)',
                prefixIcon: Icon(Icons.money, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notas (Opcional)',
                prefixIcon: Icon(Icons.note_outlined, color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final amountStr = amountController.text.trim();
              if (amountStr.isEmpty) return;

              final amount = double.tryParse(amountStr);
              if (amount == null || amount <= 0) return;

              Navigator.pop(context); // Cerrar diólogo

              _saveAbono(receivable, amount, notesController.text.trim());
            },
            child: const Text(
              'Guardar Abono',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAbono(
    Receivable receivable,
    double amount,
    String notes,
  ) async {
    setState(() => _isLoading = true);
    try {
      final recService = Provider.of<ReceivableService>(context, listen: false);

      final payment = ReceivablePayment(
        receivableId: receivable.id,
        amount: amount,
        paymentDate: DateTime.now(),
        notes: notes,
        paymentMethod: 'Efectivo',
      );

      await recService.savePayment(payment);

      // Recargar datos
      await _loadReceivables();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abono registrado con éxito'),
            backgroundColor: AppColors.success,
          ),
        );

        // Preguntar si quiere compartir el recibo
        _showShareDialog(payment, receivable);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar abono: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showShareDialog(ReceivablePayment payment, Receivable receivable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          '¿Compartir Recibo?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Deseas generar y enviar un comprobante de pago en PDF al deudor?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ahora no'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PdfService.generateAndShareReceipt(
                debtor: widget.debtor,
                receivable: receivable,
                payment: payment,
              );
            },
            child: const Text(
              'Sí, compartir',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;
  final bool isFullWidth;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isFullWidth ? 24 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isFullWidth ? 15 : 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: isFullWidth ? 26 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivableCard extends StatelessWidget {
  final Receivable receivable;
  final VoidCallback onTap;
  final VoidCallback onAddPayment;

  const _ReceivableCard({
    required this.receivable,
    required this.onTap,
    required this.onAddPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    receivable.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  Formatters.currency(receivable.pendingAmount),
                  style: TextStyle(
                    color: receivable.pendingAmount >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: receivable.progressPercentage,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${Formatters.currency(receivable.initialAmount)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Pagado: ${Formatters.currency(receivable.paidAmount)}',
                  style: TextStyle(
                    color: AppColors.success.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onAddPayment,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar pago'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
