import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/user_model.dart';

class PdfService {
  /// Generate a PDF document for the given invoice
  static Future<pw.Document> generateInvoicePdf(
    InvoiceModel invoice,
    ShopSettings? shopSettings,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Shop Info
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 2, color: PdfColors.grey300),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      shopSettings?.shopName ?? 'My Shop',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (shopSettings?.tagline != null &&
                        shopSettings!.tagline.isNotEmpty)
                      pw.Text(
                        shopSettings.tagline,
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700),
                      ),
                    pw.SizedBox(height: 8),
                    if (shopSettings?.address != null &&
                        shopSettings!.address.isNotEmpty)
                      pw.Text(
                        shopSettings.address,
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey700),
                      ),
                    pw.Row(
                      children: [
                        if (shopSettings?.phone != null &&
                            shopSettings!.phone.isNotEmpty)
                          pw.Text(
                            'Tel: ${shopSettings.phone}',
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700),
                          ),
                        if (shopSettings?.email != null &&
                            shopSettings!.email.isNotEmpty) ...[
                          pw.SizedBox(width: 16),
                          pw.Text(
                            'Email: ${shopSettings.email}',
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700),
                          ),
                        ],
                      ],
                    ),
                    if (shopSettings?.gstNumber != null &&
                        shopSettings!.gstNumber.isNotEmpty)
                      pw.Text(
                        'GSTIN: ${shopSettings.gstNumber}',
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey700),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Invoice Details & Customer Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Invoice Info
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildInfoRow('Invoice #', invoice.invoiceNumber),
                      _buildInfoRow(
                          'Date', dateFormat.format(invoice.createdAt)),
                      if (invoice.status == InvoiceStatus.paid &&
                          invoice.paidAt != null)
                        _buildInfoRow(
                            'Paid On', dateFormat.format(invoice.paidAt!)),
                    ],
                  ),
                  // Customer Info
                  if (invoice.customerName != null ||
                      invoice.customerId != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILL TO',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            invoice.customerName ?? 'Walk-in Customer',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              pw.SizedBox(height: 24),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Item', isHeader: true),
                      _buildTableCell('Unit Price',
                          isHeader: true, align: pw.TextAlign.right),
                      _buildTableCell('Qty',
                          isHeader: true, align: pw.TextAlign.center),
                      _buildTableCell('Amount',
                          isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Items
                  ...invoice.items.map((item) => pw.TableRow(
                        children: [
                          _buildTableCell(
                            '${item.productName}\n${item.unit}',
                            fontSize: 9,
                          ),
                          _buildTableCell(
                            'Rs.${item.price.toStringAsFixed(2)}',
                            align: pw.TextAlign.right,
                            fontSize: 9,
                          ),
                          _buildTableCell(
                            '${item.quantity}',
                            align: pw.TextAlign.center,
                            fontSize: 9,
                          ),
                          _buildTableCell(
                            'Rs.${item.total.toStringAsFixed(2)}',
                            align: pw.TextAlign.right,
                            fontSize: 9,
                          ),
                        ],
                      )),
                ],
              ),

              pw.SizedBox(height: 16),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Subtotal',
                            'Rs.${invoice.subtotal.toStringAsFixed(2)}'),
                        if (invoice.discount > 0)
                          _buildTotalRow('Discount',
                              '-Rs.${invoice.discount.toStringAsFixed(2)}'),
                        _buildTotalRow(
                          'Tax (${invoice.taxRate.toStringAsFixed(1)}%)',
                          'Rs.${invoice.taxAmount.toStringAsFixed(2)}',
                        ),
                        pw.Divider(thickness: 1),
                        _buildTotalRow(
                          'TOTAL',
                          'Rs.${invoice.total.toStringAsFixed(2)}',
                          isBold: true,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Payment Info
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Information',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Payment Method',
                        _getPaymentMethodName(invoice.paymentMethod)),
                    _buildInfoRow(
                      'Status',
                      invoice.status == InvoiceStatus.paid ? 'PAID' : 'PENDING',
                    ),
                  ],
                ),
              ),

              // Notes
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Notes:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.notes!,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // Footer
              if (shopSettings?.thankYouNote != null &&
                  shopSettings!.thankYouNote!.isNotEmpty)
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.only(top: 16),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300),
                    ),
                  ),
                  child: pw.Text(
                    shopSettings.thankYouNote!,
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Generate a thermal printer receipt (58mm width)
  static Future<pw.Document> generateThermalReceipt(
    InvoiceModel invoice,
    ShopSettings? shopSettings,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
        margin: const pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Shop Name
              pw.Text(
                shopSettings?.shopName ?? 'My Shop',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (shopSettings?.tagline != null &&
                  shopSettings!.tagline.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  shopSettings.tagline,
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              if (shopSettings?.address != null &&
                  shopSettings!.address.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  shopSettings.address,
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              if (shopSettings?.phone != null &&
                  shopSettings!.phone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Tel: ${shopSettings.phone}',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              if (shopSettings?.gstNumber != null &&
                  shopSettings!.gstNumber.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'GSTIN: ${shopSettings.gstNumber}',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Invoice Details
              pw.Text(
                'INVOICE #${invoice.invoiceNumber}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                dateFormat.format(invoice.createdAt),
                style: const pw.TextStyle(fontSize: 8),
              ),
              if (invoice.customerName != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'Customer: ${invoice.customerName}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Items
              ...invoice.items.map((item) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          item.productName,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '${item.quantity} ${item.unit} x Rs.${item.price.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'Rs.${item.total.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    'Rs.${invoice.subtotal.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (invoice.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(
                      '-Rs.${invoice.discount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Tax (${invoice.taxRate.toStringAsFixed(1)}%):',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Rs.${invoice.taxAmount.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rs.${invoice.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Payment Info
              pw.Text(
                'Payment: ${_getPaymentMethodName(invoice.paymentMethod)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                invoice.status == InvoiceStatus.paid
                    ? 'Status: PAID'
                    : 'Status: PENDING',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              // Notes
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Note: ${invoice.notes}',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              ],

              // Thank You
              if (shopSettings?.thankYouNote != null &&
                  shopSettings!.thankYouNote!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  shopSettings.thankYouNote!,
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Text(
                invoice.status == InvoiceStatus.paid
                    ? '*** PAID ***'
                    : '*** PENDING ***',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Save PDF to file and return the path
  static Future<File> savePdfToFile(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Print using system printer dialog
  static Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// Print thermal receipt directly
  static Future<void> printThermalReceipt(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      format: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
    );
  }

  // Helper widgets
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    double fontSize = 10,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.credit:
        return 'Credit';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}
