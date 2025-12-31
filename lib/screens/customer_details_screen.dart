import 'package:flutter/material.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/screens/invoice_receipt_screen.dart';
import 'package:intl/intl.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _firestoreService = FirestoreService();
  List<InvoiceModel> _customerInvoices = [];
  bool _isLoading = true;

  static const Color backgroundColor = Color(0xFF050608);
  static const Color surfaceColor = Color(0x14181818);
  static const Color accentColor = Color(0xFF00C59E);
  static const Color borderColor = Color(0xFF12332D);
  static const Color textWhite = Colors.white;
  static const Color textGray = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadCustomerInvoices();
  }

  Future<void> _loadCustomerInvoices() async {
    try {
      final invoices = await _firestoreService.getInvoices();
      final customerInvoices = invoices
          .where((inv) => inv.customerId == widget.customer.id)
          .toList();

      if (mounted) {
        setState(() {
          _customerInvoices = customerInvoices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customer Details',
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.customer.name.isNotEmpty
                            ? widget.customer.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.customer.name,
                    style: const TextStyle(
                      color: textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.customer.phone != null &&
                      widget.customer.phone!.isNotEmpty)
                    _buildInfoRow(Icons.phone, widget.customer.phone!),
                  if (widget.customer.email != null &&
                      widget.customer.email!.isNotEmpty)
                    _buildInfoRow(Icons.email, widget.customer.email!),
                  if (widget.customer.address != null &&
                      widget.customer.address!.isNotEmpty)
                    _buildInfoRow(Icons.location_on, widget.customer.address!),
                  if (widget.customer.gstNumber != null &&
                      widget.customer.gstNumber!.isNotEmpty)
                    _buildInfoRow(Icons.receipt_long,
                        'GST: ${widget.customer.gstNumber}'),
                  if (widget.customer.notes != null &&
                      widget.customer.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes:',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.customer.notes!,
                            style:
                                const TextStyle(color: textGray, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Purchase History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchase History',
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_customerInvoices.length} ${_customerInvoices.length == 1 ? 'Invoice' : 'Invoices'}',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: accentColor),
                    ),
                  )
                : _customerInvoices.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: borderColor.withValues(alpha: 0.6)),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              const Icon(Icons.receipt_long,
                                  color: textGray, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No purchase history',
                                style: TextStyle(color: textGray),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _customerInvoices.map((invoice) {
                          final isPaid = invoice.status == InvoiceStatus.paid;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvoiceReceiptScreen(invoice: invoice),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: borderColor.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? accentColor.withValues(alpha: 0.1)
                                          : Colors.orange
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isPaid
                                          ? Icons.check_circle
                                          : Icons.pending,
                                      color:
                                          isPaid ? accentColor : Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          invoice.invoiceNumber,
                                          style: const TextStyle(
                                            color: textWhite,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateFormat.format(invoice.createdAt),
                                          style: const TextStyle(
                                            color: textGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\u20b9${invoice.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? accentColor.withValues(
                                                  alpha: 0.2)
                                              : Colors.orange
                                                  .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isPaid ? 'Paid' : 'Pending',
                                          style: TextStyle(
                                            color: isPaid
                                                ? accentColor
                                                : Colors.orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textGray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
