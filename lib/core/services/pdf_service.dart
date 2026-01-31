import 'package:flutter/foundation.dart';
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
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter, // Usar Carta que es más estándar
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
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
