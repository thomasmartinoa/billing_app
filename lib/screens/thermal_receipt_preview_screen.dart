import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/services/thermal_printer_service.dart';
import 'package:billing_app/services/pdf_service.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:share_plus/share_plus.dart';

class ThermalReceiptPreviewScreen extends StatefulWidget {
  final InvoiceModel invoice;
  final ShopSettings? shopSettings;

  const ThermalReceiptPreviewScreen({
    super.key,
    required this.invoice,
    this.shopSettings,
  });

  @override
  State<ThermalReceiptPreviewScreen> createState() =>
      _ThermalReceiptPreviewScreenState();
}

class _ThermalReceiptPreviewScreenState
    extends State<ThermalReceiptPreviewScreen> {
  bool _isLoading = false;

  Future<void> _printReceipt() async {
    try {
      final isConnected = await ThermalPrinterService.isConnected();

      if (!isConnected) {
        await _showPrinterSelectionDialog();
        return;
      }

      setState(() => _isLoading = true);
      await ThermalPrinterService.printThermalReceipt(
        widget.invoice,
        widget.shopSettings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Printing...'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToPdf() async {
    setState(() => _isLoading = true);
    try {
      final pdf = await PdfService.generateThermalReceipt(
        widget.invoice,
        widget.shopSettings,
      );

      final file = await PdfService.savePdfToFile(
        pdf,
        'thermal_receipt_${widget.invoice.invoiceNumber}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path}'),
            backgroundColor: context.successColor,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => _sharePdf(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sharePdf(String path) async {
    try {
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Thermal Receipt ${widget.invoice.invoiceNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: $e')),
        );
      }
    }
  }

  Future<void> _showPrinterSelectionDialog() async {
    try {
      final devices = await ThermalPrinterService.getBondedDevices();

      if (!mounted) return;

      if (devices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No Bluetooth printers found. Please pair first.'),
            backgroundColor: context.warningColor,
          ),
        );
        return;
      }

      final selectedDevice = await showDialog<BluetoothDevice>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Select Printer',
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
                  leading: Icon(Icons.print, color: context.infoColor),
                  title: Text(
                    device.name ?? 'Unknown Device',
                    style: TextStyle(color: context.textPrimary),
                  ),
                  subtitle: Text(
                    device.address ?? '',
                    style: TextStyle(color: context.textSecondary),
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

      if (selectedDevice != null && mounted) {
        await _connectAndPrint(selectedDevice);
      }
    } catch (e) {
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
      setState(() => _isLoading = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting...')),
      );

      await ThermalPrinterService.connect(device);

      if (mounted) {
        await ThermalPrinterService.printThermalReceipt(
          widget.invoice,
          widget.shopSettings,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Printed successfully!'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    return Scaffold(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Thermal Receipt Preview',
          style: TextStyle(color: context.textPrimary),
        ),
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: 300, // 58mm ~ 220px at standard DPI
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Shop Name
                      if (widget.shopSettings?.shopName != null)
                        Text(
                          widget.shopSettings!.shopName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      if (widget.shopSettings?.tagline != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.shopSettings!.tagline,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 8),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 8),

                      // Shop Details
                      if (widget.shopSettings?.address != null)
                        Text(
                          widget.shopSettings!.address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      if (widget.shopSettings?.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${widget.shopSettings!.phone}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      if (widget.shopSettings?.gstNumber != null &&
                          widget.shopSettings!.gstNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'GSTIN: ${widget.shopSettings!.gstNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 8),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 8),

                      // Invoice Details
                      Text(
                        'INVOICE',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      _buildRow('Invoice No:', widget.invoice.invoiceNumber),
                      _buildRow(
                          'Date:', dateFormat.format(widget.invoice.createdAt)),
                      if (widget.invoice.customerName != null)
                        _buildRow('Customer:', widget.invoice.customerName!),

                      const SizedBox(height: 8),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 8),

                      // Items
                      ...widget.invoice.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.quantity} x ₹${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '₹${(item.quantity * item.price).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                      const Divider(color: Colors.black26),
                      const SizedBox(height: 8),

                      // Totals
                      _buildRow('Subtotal:',
                          '₹${widget.invoice.subtotal.toStringAsFixed(2)}'),

                      if (widget.invoice.discount > 0)
                        _buildRow('Discount:',
                            '-₹${widget.invoice.discount.toStringAsFixed(2)}'),

                      if (widget.invoice.taxAmount > 0)
                        _buildRow('Tax:',
                            '₹${widget.invoice.taxAmount.toStringAsFixed(2)}'),

                      const SizedBox(height: 4),
                      const Divider(color: Colors.black, thickness: 2),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '₹${widget.invoice.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 8),

                      // Payment & Status
                      _buildRow(
                          'Payment:',
                          widget.invoice.paymentMethod
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase()),
                      _buildRow(
                          'Status:',
                          widget.invoice.status
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase()),

                      if (widget.invoice.notes != null &&
                          widget.invoice.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(color: Colors.black26),
                        const SizedBox(height: 8),
                        Text(
                          'Note: ${widget.invoice.notes}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 8),

                      const Text(
                        'Thank You!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Visit Again',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: context.textPrimary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _saveToPdf,
                    icon: const Icon(Icons.save),
                    label: const Text('Save PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.textPrimary,
                      side: BorderSide(color: context.textPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _printReceipt,
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
