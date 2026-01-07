import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/services/pdf_service.dart';
import 'package:billing_app/services/thermal_printer_service.dart';
import 'package:billing_app/screens/thermal_receipt_preview_screen.dart';
import 'package:billing_app/constants/app_constants.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceReceiptScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceReceiptScreen({super.key, required this.invoice});

  @override
  State<InvoiceReceiptScreen> createState() => _InvoiceReceiptScreenState();
}

class _InvoiceReceiptScreenState extends State<InvoiceReceiptScreen> {
  final _firestoreService = FirestoreService();
  ShopSettings? _shopSettings;
  bool _isLoading = true;
  bool _isMarkingPaid = false;
  bool _isPdfLoading = false;
  late InvoiceModel _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _loadShopSettings();
  }

  Future<void> _loadShopSettings() async {
    try {
      final userData = await _firestoreService.getUserData();
      if (mounted) {
        setState(() {
          _shopSettings = userData?.shopSettings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsPaid() async {
    setState(() => _isMarkingPaid = true);
    try {
      await _firestoreService.updateInvoice(_invoice.id!, {
        'status': 'paid',
        'paidAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() {
          _invoice = _invoice.copyWith(
            status: InvoiceStatus.paid,
            paidAt: DateTime.now(),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice marked as paid')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingPaid = false);
    }
  }

  Future<void> _sharePdf() async {
    setState(() => _isPdfLoading = true);
    try {
      // Generate PDF
      final pdf = await PdfService.generateInvoicePdf(_invoice, _shopSettings);

      // Save to file
      final file = await PdfService.savePdfToFile(
        pdf,
        'invoice_${_invoice.invoiceNumber}',
      );

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice ${_invoice.invoiceNumber}',
        text:
            'Please find attached invoice ${_invoice.invoiceNumber} for Rs.${_invoice.total.toStringAsFixed(2)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF shared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  Future<void> _printA4Invoice() async {
    setState(() => _isPdfLoading = true);
    try {
      // Generate A4 PDF
      final pdf = await PdfService.generateInvoicePdf(_invoice, _shopSettings);

      // Print using system printer dialog
      await PdfService.printPdf(pdf);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printing...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  Future<void> _printThermalReceipt() async {
    try {
      // Check if printer is connected
      final isConnected = await ThermalPrinterService.isConnected();

      if (!isConnected) {
        // Show device selection dialog
        await _showPrinterSelectionDialog();
        return;
      }

      setState(() => _isPdfLoading = true);

      // Print using connected thermal printer
      await ThermalPrinterService.printThermalReceipt(_invoice, _shopSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing thermal receipt...'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  Future<void> _showPrinterSelectionDialog() async {
    try {
      setState(() => _isPdfLoading = true);

      // Get bonded devices
      final devices = await ThermalPrinterService.getBondedDevices();

      setState(() => _isPdfLoading = false);

      if (!mounted) return;

      if (devices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No Bluetooth printers found. Please pair a printer first.'),
            backgroundColor: context.warningColor,
          ),
        );
        return;
      }

      // Show device selection dialog
      final selectedDevice = await showDialog<BluetoothDevice>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(
            'Select Thermal Printer',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: Icon(Icons.print, color: context.accent),
                  title: Text(
                    device.name ?? 'Unknown Device',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    device.address ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  onTap: () => Navigator.pop(context, device),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selectedDevice != null) {
        await _connectAndPrint(selectedDevice);
      }
    } catch (e) {
      setState(() => _isPdfLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _connectAndPrint(BluetoothDevice device) async {
    try {
      setState(() => _isPdfLoading = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connecting to printer...')),
        );
      }

      // Connect to printer
      await ThermalPrinterService.connect(device);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected! Printing...'),
            backgroundColor: context.successColor,
          ),
        );
      }

      // Print receipt
      await ThermalPrinterService.printThermalReceipt(_invoice, _shopSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print completed successfully!'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print failed: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  void _showThermalPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThermalReceiptPreviewScreen(
          invoice: _invoice,
          shopSettings: _shopSettings,
        ),
      ),
    );
  }

  Future<void> _saveThermalToPdf() async {
    setState(() => _isPdfLoading = true);
    try {
      final pdf = await PdfService.generateThermalReceipt(
        _invoice,
        _shopSettings,
      );

      final file = await PdfService.savePdfToFile(
        pdf,
        'thermal_receipt_${_invoice.invoiceNumber}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                await Share.shareXFiles(
                  [XFile(file.path)],
                  subject: 'Thermal Receipt ${_invoice.invoiceNumber}',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  void _showPrintOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thermal Receipt Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showThermalPreview();
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Preview & Print'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _printThermalReceipt();
              },
              icon: const Icon(Icons.print),
              label: const Text('Print Directly'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.accent,
                side: BorderSide(color: context.accent),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _saveThermalToPdf();
              },
              icon: const Icon(Icons.save),
              label: const Text('Save as PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final isPaid = _invoice.status == InvoiceStatus.paid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${_invoice.invoiceNumber}'),
        leading: const BackButton(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onSelected: (value) {
              if (value == 'a4') {
                _printA4Invoice();
              } else if (value == 'thermal') {
                _showPrintOptions();
              } else if (value == 'preview') {
                _showThermalPreview();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'a4',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: 8),
                    Text('Print A4 Invoice'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'preview',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20),
                    SizedBox(width: 8),
                    Text('Preview Thermal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'thermal',
                child: Row(
                  children: [
                    Icon(Icons.receipt, size: 20),
                    SizedBox(width: 8),
                    Text('Thermal Options'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share PDF',
            onPressed: _sharePdf,
          ),
        ],
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.accent))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SHOP INFO
                      Text(
                        _shopSettings?.shopName ?? 'My Shop',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_shopSettings != null &&
                          _shopSettings!.tagline.isNotEmpty)
                        Text(_shopSettings!.tagline,
                            style: const TextStyle(color: Colors.black54)),
                      if (_shopSettings != null &&
                          _shopSettings!.address.isNotEmpty)
                        Text(_shopSettings!.address,
                            style: const TextStyle(color: Colors.black54)),
                      if (_shopSettings != null &&
                          _shopSettings!.phone.isNotEmpty)
                        Text('Tel: ${_shopSettings!.phone}',
                            style: const TextStyle(color: Colors.black54)),

                      const Divider(height: 28),

                      // INVOICE META
                      _row('Invoice', _invoice.invoiceNumber),
                      _row('Date', dateFormat.format(_invoice.createdAt)),
                      if (_invoice.customerName != null)
                        _row('Customer', _invoice.customerName!),

                      const Divider(height: 28),

                      // HEADER
                      _headerRow(),

                      const SizedBox(height: 6),

                      // ITEMS
                      ..._invoice.items.map((item) => _itemRow(
                            name: item.productName,
                            sub:
                                '₹${item.price.toStringAsFixed(2)} × ${item.quantity} ${item.unit}',
                            qty: '${item.quantity}',
                            amount: '₹${item.total.toStringAsFixed(2)}',
                          )),

                      const Divider(height: 28),

                      // TOTALS
                      _row('Subtotal',
                          '₹${_invoice.subtotal.toStringAsFixed(2)}'),
                      if (_invoice.discount > 0)
                        _row('Discount',
                            '-₹${_invoice.discount.toStringAsFixed(2)}'),
                      _row('Tax (${_invoice.taxRate.toStringAsFixed(1)}%)',
                          '₹${_invoice.taxAmount.toStringAsFixed(2)}'),

                      const SizedBox(height: 10),

                      _row(
                        'TOTAL',
                        '₹${_invoice.total.toStringAsFixed(2)}',
                        bold: true,
                        large: true,
                      ),

                      const SizedBox(height: 16),

                      // PAYMENT INFO
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _row('Payment Method',
                                _getPaymentMethodName(_invoice.paymentMethod)),
                            if (isPaid)
                              _row('Paid',
                                  '₹${_invoice.total.toStringAsFixed(2)}'),
                            if (!isPaid) _row('Status', 'Pending'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (_shopSettings?.thankYouNote != null &&
                          _shopSettings!.thankYouNote!.isNotEmpty)
                        Text(
                          _shopSettings!.thankYouNote!,
                          style: TextStyle(color: context.textSecondary),
                        ),

                      const SizedBox(height: 8),

                      if (_invoice.notes != null &&
                          _invoice.notes!.isNotEmpty) ...[
                        Text(
                          'Note: ${_invoice.notes}',
                          style: TextStyle(
                              color: context.textSecondary, fontSize: AppFontSize.md),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Text(
                        isPaid ? '*** PAID ***' : '*** PENDING ***',
                        style: TextStyle(
                          color: isPaid ? context.successColor : context.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

      // BOTTOM ACTION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.borderColor.withOpacity(0.2))),
        ),
        child: Row(
          children: [
            if (!isPaid) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isMarkingPaid ? null : _markAsPaid,
                  icon: _isMarkingPaid
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle),
                  label: Text(_isMarkingPaid ? 'Marking...' : 'Mark as Paid'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.accent,
                    side: BorderSide(color: context.accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPdfLoading ? null : _sharePdf,
                icon: _isPdfLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: Text(_isPdfLoading ? 'Generating...' : 'Share PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.accent,
                  side: BorderSide(color: context.accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isPdfLoading ? null : _showPrintOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: context.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isPdfLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    else
                      const Icon(Icons.print),
                    const SizedBox(width: 8),
                    Text(_isPdfLoading ? 'Printing...' : 'Print'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
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

  // ----------------- HELPERS -----------------

  static Widget _row(
    String left,
    String right, {
    bool bold = false,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 16 : 13,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _headerRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
        Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 12),
        Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  static Widget _itemRow({
    required String name,
    required String sub,
    required String qty,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.black)),
                Text(sub,
                    style:
                        const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Text(qty),
          const SizedBox(width: 16),
          Text(amount),
        ],
      ),
    );
  }
}
