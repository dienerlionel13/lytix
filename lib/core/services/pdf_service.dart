import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../data/models/debtor.dart';

class PdfService {
  static final _currencyFormat = NumberFormat.currency(
    symbol: 'Q',
    decimalDigits: 2,
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

      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'recibo_${payment.id.substring(0, 8)}.pdf',
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

      // Agrupar pagos por fecha
      allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            final totalInitial = receivables.fold<double>(
              0,
              (sum, r) => sum + r.initialAmount,
            );
            final totalPaid = receivables.fold<double>(
              0,
              (sum, r) => sum + r.paidAmount,
            );
            final totalPending = totalInitial - totalPaid;

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
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
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

              // Resumen Financiero
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
                      'Total Deuda',
                      _currencyFormat.format(totalInitial),
                      PdfColors.black,
                    ),
                    _buildSummaryItem(
                      'Total Pagado',
                      _currencyFormat.format(totalPaid),
                      PdfColors.green700,
                    ),
                    _buildSummaryItem(
                      'Saldo Pendiente',
                      _currencyFormat.format(totalPending),
                      PdfColors.red700,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // Tabla de Deudas Activas
              pw.Text(
                'DETALLE DE DEUDAS',
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
                      _buildCell('Descripción', isHeader: true),
                      _buildCell(
                        'Monto Inicial',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                      _buildCell(
                        'Pagado',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
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
                        _buildCell(r.description),
                        _buildCell(
                          _currencyFormat.format(r.initialAmount),
                          align: pw.TextAlign.right,
                        ),
                        _buildCell(
                          _currencyFormat.format(r.paidAmount),
                          align: pw.TextAlign.right,
                        ),
                        _buildCell(
                          _currencyFormat.format(r.pendingAmount),
                          align: pw.TextAlign.right,
                          color: r.isPaid
                              ? PdfColors.green700
                              : PdfColors.red700,
                        ),
                      ],
                    ),
                  ),
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
                  'Documento informativo de carácter personal.',
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

      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Estado_Cuenta_${debtor.name.replaceAll(' ', '_')}.pdf',
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
