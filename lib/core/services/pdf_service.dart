import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../data/models/debtor.dart';

class PdfService {
  static final _currencyFormat = NumberFormat.currency(
    symbol: 'Q',
    decimalDigits: 2,
    locale: 'en_US', // Forzamos punto decimal y coma de miles
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Genera y comparte un recibo de pago en PDF
  static Future<void> generateAndShareReceipt({
    required Debtor debtor,
    required Receivable receivable,
    required ReceivablePayment payment,
  }) async {
    try {
      debugPrint('PdfService: Cargando logo y creando documento...');

      // Cargar logo desde assets
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter, // Usar Carta que es más estándar
          build: (pw.Context context) {
            debugPrint('PdfService: Construyendo widget de página...');
            return pw.Container(
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Encabezado con Logo
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 50,
                            height: 50,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 15),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'RECIBO DE PAGO',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Lytix - Gestión de Cobranza',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Comprobante #',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            payment.id.substring(0, 8).toUpperCase(),
                            style: pw.TextStyle(color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 2, color: PdfColors.blue900),
                  pw.SizedBox(height: 30),

                  // Información del Deudor
                  pw.Text(
                    'Información del Deudor',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Nombre: ${debtor.name}'),
                  if (debtor.phone != null)
                    pw.Text('Teléfono: ${debtor.phone}'),
                  if (debtor.email != null) pw.Text('Email: ${debtor.email}'),
                  pw.SizedBox(height: 30),

                  // Detalles del Pago
                  pw.Text(
                    'Detalles del Abono',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(12),
                      ),
                      color: PdfColors.grey50,
                    ),
                    child: pw.Column(
                      children: [
                        _buildRow('Concepto:', receivable.description),
                        _buildRow(
                          'Fecha de Pago:',
                          _dateFormat.format(payment.paymentDate),
                        ),
                        _buildRow(
                          'Método de Pago:',
                          payment.paymentMethod ?? 'Efectivo',
                        ),
                        if (payment.notes != null && payment.notes!.isNotEmpty)
                          _buildRow('Observaciones:', payment.notes!),
                        pw.SizedBox(height: 12),
                        pw.Divider(color: PdfColors.grey400),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'MONTO RECIBIDO:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            pw.Text(
                              _currencyFormat.format(payment.amount),
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 40),

                  // Estado de Cuenta después de este pago
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Estado Actual de la Deuda',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            children: [
                              pw.Text(
                                'Saldo Pendiente Anterior: ',
                                style: const pw.TextStyle(fontSize: 11),
                              ),
                              pw.Text(
                                _currencyFormat.format(
                                  receivable.pendingAmount,
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.Text(
                                'SALDO NUEVO: ',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              pw.Text(
                                _currencyFormat.format(
                                  receivable.pendingAmount - payment.amount,
                                ),
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.Spacer(),
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Divider(color: PdfColors.grey300),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Este es un comprobante digital generado automáticamente.',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          '¡Gracias por su puntualidad!',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final safeName = debtor.name.replaceAll(' ', '_');
      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: '${timestamp}_${safeName}_Recibo_Pago.pdf',
      );
    } catch (e) {
      debugPrint('Error fatal generando/compartiendo PDF: $e');
    }
  }

  /// Genera y comparte el Estado de Cuenta completo de un deudor
  static Future<void> generateDebtorStatement({
    required Debtor debtor,
    required List<Receivable> receivables,
    required List<ReceivablePayment> allPayments,
  }) async {
    try {
      debugPrint('PdfService: Generando Estado de Cuenta...');

      pw.MemoryImage? logoImage;
      try {
        final ByteData logoData = await rootBundle.load(
          'assets/images/logo.png',
        );
        final Uint8List logoBytes = logoData.buffer.asUint8List();
        logoImage = pw.MemoryImage(logoBytes);
      } catch (e) {
        debugPrint(
          'PdfService: No se pudo cargar el logo, se generará sin él: $e',
        );
      }

      final pdf = pw.Document();

      // Preparar movimientos cronológicos
      final movements = <_StatementMovement>[];
      for (var r in receivables) {
        final isPayable = r.initialAmount < 0;
        movements.add(
          _StatementMovement(
            date: r.transactionDate ?? r.createdAt,
            description: r.description,
            notes: r.notes ?? '',
            amount: r.initialAmount,
            isPayment: false,
            type: isPayable ? 'Por Pagar' : 'Por Cobrar',
          ),
        );
      }
      for (var p in allPayments) {
        final r = receivables.firstWhere(
          (rec) => rec.id == p.receivableId,
          orElse: () => receivables.first,
        );
        movements.add(
          _StatementMovement(
            date: p.paymentDate,
            description: 'Abono: ${r.description}',
            notes: p.notes ?? '',
            amount: -p.amount, // Los abonos disminuyen el saldo
            isPayment: true,
            type: 'Abono',
          ),
        );
      }
      movements.sort((a, b) => a.date.compareTo(b.date));

      // Ordenar deudas para la tabla de detalle
      receivables.sort(
        (a, b) => (b.transactionDate ?? b.createdAt).compareTo(
          a.transactionDate ?? a.createdAt,
        ),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            // Cálculos con la nueva lógica contable
            final totalCobrar = receivables
                .where((r) => r.initialAmount > 0)
                .fold(0.0, (sum, r) => sum + r.initialAmount);
            final totalPagar = receivables
                .where((r) => r.initialAmount < 0)
                .fold(0.0, (sum, r) => sum + r.initialAmount.abs());
            final totalAbonos = allPayments.fold(
              0.0,
              (sum, p) => sum + p.amount,
            );
            final saldoNeto = receivables.fold(
              0.0,
              (sum, r) => sum + r.pendingAmount,
            );

            double runningBalance = 0;

            return [
              // Encabezado
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 40,
                          height: 40,
                          child: pw.Image(logoImage),
                        ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ESTADO DE CUENTA',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.Text(
                            'Lytix Finance',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'ID Deudor: ${debtor.id.substring(0, 8).toUpperCase()}',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Info Deudor
              pw.Text(
                'CLIENTE / DEUDOR',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                debtor.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (debtor.phone != null)
                pw.Text(
                  'Teléfono: ${debtor.phone}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              pw.SizedBox(height: 20),

              // Resumen Financiero Actualizado
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Por Cobrar',
                      _currencyFormat.format(totalCobrar),
                      PdfColors.red700,
                    ),
                    _buildSummaryItem(
                      'Por Pagar',
                      _currencyFormat.format(totalPagar),
                      PdfColors.green700,
                    ),
                    _buildSummaryItem(
                      'Total Abonos',
                      _currencyFormat.format(totalAbonos),
                      PdfColors.blue700,
                    ),
                    _buildSummaryItem(
                      'Saldo Neto',
                      _currencyFormat.format(saldoNeto),
                      saldoNeto > 0 ? PdfColors.red900 : PdfColors.green900,
                    ),
                  ],
                ),
              ),
              // TABLA 1: RESUMEN DE DEUDAS (Simplificada)
              pw.Text(
                'RESUMEN DE DEUDAS PENDIENTES',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey200,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60), // F. Reg
                  1: const pw.FixedColumnWidth(60), // F. Oper
                  2: const pw.FixedColumnWidth(70), // Tipo
                  3: const pw.FlexColumnWidth(3), // Descripción
                  4: const pw.FixedColumnWidth(80), // Saldo
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _buildCell('F. Reg.', isHeader: true),
                      _buildCell('F. Oper.', isHeader: true),
                      _buildCell('Tipo', isHeader: true),
                      _buildCell('Descripción', isHeader: true),
                      _buildCell(
                        'Saldo',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                  ...receivables.map(
                    (r) => pw.TableRow(
                      children: [
                        _buildCell(DateFormat('dd/MM/yy').format(r.createdAt)),
                        _buildCell(
                          r.transactionDate != null
                              ? DateFormat(
                                  'dd/MM/yy',
                                ).format(r.transactionDate!)
                              : '-',
                        ),
                        _buildCell(
                          r.initialAmount < 0 ? 'Por Pagar' : 'Por Cobrar',
                          color: r.initialAmount < 0
                              ? PdfColors.green700
                              : PdfColors.red700,
                        ),
                        _buildCell(r.description),
                        _buildCell(
                          _currencyFormat.format(r.pendingAmount),
                          align: pw.TextAlign.right,
                          color: r.initialAmount < 0
                              ? PdfColors.green700
                              : PdfColors.red700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // TABLA 2: MOVIMIENTOS DETALLADOS (Con Notas)
              pw.Text(
                'HISTORIAL DE MOVIMIENTOS Y ABONOS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey200,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60), // Fecha
                  1: const pw.FixedColumnWidth(70), // Tipo
                  2: const pw.FlexColumnWidth(1.5), // Descripción
                  3: const pw.FlexColumnWidth(2), // Notas
                  4: const pw.FixedColumnWidth(70), // Monto
                  5: const pw.FixedColumnWidth(70), // Saldo
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _buildCell('Fecha', isHeader: true),
                      _buildCell('Tipo', isHeader: true),
                      _buildCell('Descripción', isHeader: true),
                      _buildCell('Notas', isHeader: true),
                      _buildCell(
                        'Monto',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                      _buildCell(
                        'Saldo Acum.',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                  ...movements.map((move) {
                    runningBalance += move.amount;
                    return pw.TableRow(
                      children: [
                        _buildCell(DateFormat('dd/MM/yy').format(move.date)),
                        _buildCell(
                          move.type ?? '',
                          color: move.type == 'Por Pagar'
                              ? PdfColors.green700
                              : move.type == 'Abono'
                              ? PdfColors.blue700
                              : PdfColors.red700,
                        ),
                        _buildCell(move.description),
                        _buildCell(move.notes, align: pw.TextAlign.left),
                        _buildCell(
                          _currencyFormat.format(move.amount.abs()),
                          align: pw.TextAlign.right,
                          color: move.type == 'Por Pagar'
                              ? PdfColors.green700
                              : move.type == 'Abono'
                              ? PdfColors.blue700
                              : PdfColors.red700,
                        ),
                        _buildCell(
                          _currencyFormat.format(runningBalance),
                          align: pw.TextAlign.right,
                          color: runningBalance > 0
                              ? PdfColors.red700
                              : PdfColors.green700,
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 25),

              // Historial de Pagos
              if (allPayments.isNotEmpty) ...[
                pw.Text(
                  'HISTORIAL DE ABONOS RECIBIDOS',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey200,
                    width: 0.5,
                  ),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        _buildCell('Fecha', isHeader: true),
                        _buildCell('Concepto Deuda', isHeader: true),
                        _buildCell(
                          'Monto Abono',
                          isHeader: true,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    ),
                    ...allPayments.map((p) {
                      final r = receivables.firstWhere(
                        (rec) => rec.id == p.receivableId,
                        orElse: () => receivables.first,
                      );
                      return pw.TableRow(
                        children: [
                          _buildCell(
                            DateFormat('dd/MM/yyyy').format(p.paymentDate),
                          ),
                          _buildCell(r.description),
                          _buildCell(
                            _currencyFormat.format(p.amount),
                            align: pw.TextAlign.right,
                            color: PdfColors.green700,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],

              pw.SizedBox(height: 40),
              pw.Divider(color: PdfColors.grey400),
              pw.Center(
                child: pw.Text(
                  'Documento informativo de carácter personal generado por Lytix.',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final safeName = debtor.name.replaceAll(' ', '_');
      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: '${timestamp}_${safeName}_Estado_Cuenta.pdf',
      );
    } catch (e) {
      debugPrint('Error generando estado de cuenta: $e');
    }
  }

  static pw.Widget _buildSummaryItem(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatementMovement {
  final DateTime date;
  final String description;
  final String notes;
  final double amount;
  final bool isPayment;
  final String? type;

  _StatementMovement({
    required this.date,
    required this.description,
    required this.notes,
    required this.amount,
    required this.isPayment,
    this.type,
  });
}
