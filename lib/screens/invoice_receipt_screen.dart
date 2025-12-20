import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/services/firestore_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final isPaid = _invoice.status == InvoiceStatus.paid;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${_invoice.invoiceNumber}'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C59E)))
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
                      if (_shopSettings != null && _shopSettings!.tagline.isNotEmpty)
                        Text(_shopSettings!.tagline, style: const TextStyle(color: Colors.black54)),
                      if (_shopSettings != null && _shopSettings!.address.isNotEmpty)
                        Text(_shopSettings!.address, style: const TextStyle(color: Colors.black54)),
                      if (_shopSettings != null && _shopSettings!.phone.isNotEmpty)
                        Text('Tel: ${_shopSettings!.phone}', style: const TextStyle(color: Colors.black54)),

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
                        sub: '₹${item.price.toStringAsFixed(2)} × ${item.quantity} ${item.unit}',
                        qty: '${item.quantity}',
                        amount: '₹${item.total.toStringAsFixed(2)}',
                      )),

                      const Divider(height: 28),

                      // TOTALS
                      _row('Subtotal', '₹${_invoice.subtotal.toStringAsFixed(2)}'),
                      if (_invoice.discount > 0)
                        _row('Discount', '-₹${_invoice.discount.toStringAsFixed(2)}'),
                      _row('Tax (${_invoice.taxRate.toStringAsFixed(1)}%)', '₹${_invoice.taxAmount.toStringAsFixed(2)}'),

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
                            _row('Payment Method', _getPaymentMethodName(_invoice.paymentMethod)),
                            if (isPaid)
                              _row('Paid', '₹${_invoice.total.toStringAsFixed(2)}'),
                            if (!isPaid)
                              _row('Status', 'Pending'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (_shopSettings?.thankYouNote != null && _shopSettings!.thankYouNote!.isNotEmpty)
                        Text(
                          _shopSettings!.thankYouNote!,
                          style: const TextStyle(color: Colors.black54),
                        ),

                      const SizedBox(height: 8),

                      if (_invoice.notes != null && _invoice.notes!.isNotEmpty) ...[
                        Text(
                          'Note: ${_invoice.notes}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Text(
                        isPaid ? '*** PAID ***' : '*** PENDING ***',
                        style: TextStyle(
                          color: isPaid ? Colors.green : Colors.orange,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          children: [
            if (!isPaid) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isMarkingPaid ? null : _markAsPaid,
                  icon: _isMarkingPaid 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle),
                  label: Text(_isMarkingPaid ? 'Marking...' : 'Mark as Paid'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00C59E),
                    side: const BorderSide(color: Color(0xFF00C59E)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share PDF functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00C59E),
                  side: const BorderSide(color: Color(0xFF00C59E)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C59E),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.card: return 'Card';
      case PaymentMethod.upi: return 'UPI';
      case PaymentMethod.bankTransfer: return 'Bank Transfer';
      case PaymentMethod.cheque: return 'Cheque';
      case PaymentMethod.credit: return 'Credit';
      case PaymentMethod.other: return 'Other';
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
        Expanded(child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
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
                Text(sub, style: const TextStyle(color: Colors.black45, fontSize: 12)),
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
