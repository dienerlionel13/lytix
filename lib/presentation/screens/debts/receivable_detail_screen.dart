import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/receivable_service.dart';
import '../../../data/models/debtor.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class ReceivableDetailScreen extends StatefulWidget {
  final Debtor debtor;
  final Receivable receivable;

  const ReceivableDetailScreen({
    super.key,
    required this.debtor,
    required this.receivable,
  });

  @override
  State<ReceivableDetailScreen> createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends State<ReceivableDetailScreen> {
  List<ReceivablePayment> _payments = [];
  bool _isLoadingPayments = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    if (!mounted) return;
    setState(() => _isLoadingPayments = true);
    try {
      final service = Provider.of<ReceivableService>(context, listen: false);
      final payments = await service.getPayments(widget.receivable.id);
      if (mounted) {
        setState(() {
          _payments = payments;
          _isLoadingPayments = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPayments = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildMainCard(currencyFormat),
                      const SizedBox(height: 20),
                      _buildFinancialDetails(currencyFormat),
                      const SizedBox(height: 20),
                      _buildInfoSection(dateFormat),
                      const SizedBox(height: 20),
                      _buildPaymentsSection(currencyFormat, dateFormat),
                      const SizedBox(height: 32),
                      _buildActions(context),
                      const SizedBox(height: 40),
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

  Widget _buildHeader(BuildContext context) {
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
              'Detalle de Deuda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMainCard(NumberFormat currencyFormat) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receivable.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.debtor.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            currencyFormat.format(widget.receivable.pendingAmount.abs()),
            style: TextStyle(
              color: widget.receivable.pendingAmount >= 0
                  ? AppColors.success
                  : AppColors.error,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.receivable.pendingAmount >= 0
                ? 'Saldo Pendiente'
                : 'Saldo a Pagar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (widget.receivable.status) {
      case ReceivableStatus.paid:
        color = AppColors.success;
        text = 'PAGADO';
        break;
      case ReceivableStatus.partial:
        color = AppColors.warning;
        text = 'PARCIAL';
        break;
      case ReceivableStatus.overdue:
        color = AppColors.error;
        text = 'VENCIDO';
        break;
      case ReceivableStatus.pending:
        color = AppColors.info;
        text = 'PENDIENTE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFinancialDetails(NumberFormat currencyFormat) {
    return Row(
      children: [
        Expanded(
          child: _FinancialItem(
            label: 'Monto Total',
            value: currencyFormat.format(widget.receivable.initialAmount.abs()),
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FinancialItem(
            label: 'Pagado',
            value: currencyFormat.format(widget.receivable.paidAmount),
            color: AppColors.success,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildInfoSection(DateFormat dateFormat) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            'Fecha de Registro',
            dateFormat.format(widget.receivable.createdAt),
          ),
          const Divider(height: 24, color: Colors.white10),
          _buildInfoRow(
            Icons.event,
            'Fecha de Vencimiento',
            widget.receivable.dueDate != null
                ? dateFormat.format(widget.receivable.dueDate!)
                : 'No establecida',
          ),
          if (widget.receivable.transactionDate != null) ...[
            const Divider(height: 24, color: Colors.white10),
            _buildInfoRow(
              Icons.history,
              'Fecha del Gasto',
              dateFormat.format(widget.receivable.transactionDate!),
            ),
          ],
          if (widget.receivable.notes != null &&
              widget.receivable.notes!.isNotEmpty) ...[
            const Divider(height: 24, color: Colors.white10),
            _buildInfoRow(
              Icons.notes,
              'Notas',
              widget.receivable.notes!,
              isMultiLine: true,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsSection(
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Historial de Pagos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_isLoadingPayments)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_payments.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay pagos registrados aún',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._payments.map(
            (payment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormat.format(payment.amount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dateFormat.format(payment.paymentDate),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (payment.paymentMethod != null)
                      Text(
                        payment.paymentMethod!,
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 250.ms);
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        GradientButton(
          text: 'Editar Deuda',
          onPressed: () => _editReceivable(context),
          icon: Icons.edit_outlined,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          label: const Text(
            'Eliminar Deuda',
            style: TextStyle(color: AppColors.error),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  void _editReceivable(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/debtor/receivable/add',
      arguments: {'debtor': widget.debtor, 'receivable': widget.receivable},
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          '¿Eliminar deuda?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final service = Provider.of<ReceivableService>(
                context,
                listen: false,
              );
              try {
                await service.deleteReceivable(widget.receivable.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back to list
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinancialItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
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
