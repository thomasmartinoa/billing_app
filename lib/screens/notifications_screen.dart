import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/screens/invoice_receipt_screen.dart';
import 'package:billing_app/screens/product_details_screen.dart';
import 'package:billing_app/theme/theme_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<ProductModel> _lowStockProducts = [];
  List<InvoiceModel> _unpaidInvoices = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final products = await _firestoreService.getProducts();
      final invoices = await _firestoreService.getInvoices();

      if (mounted) {
        setState(() {
          _lowStockProducts = products.where((p) => p.isLowStock).toList();
          _unpaidInvoices = invoices
              .where((inv) => inv.status == InvoiceStatus.pending)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  int get totalNotifications =>
      _lowStockProducts.length + _unpaidInvoices.length;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Go back',
        ),
        title: Text(
          'Notifications',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _loadNotifications,
              child: totalNotifications == 0
                  ? _buildEmptyState(context)
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.2),
                                  colorScheme.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.notifications_active,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$totalNotifications Alert${totalNotifications != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: context.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Requires your attention',
                                        style: TextStyle(
                                          color: context.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Low Stock Section
                          if (_lowStockProducts.isNotEmpty) ...[
                            _buildSectionHeader(
                              context: context,
                              icon: Icons.inventory_2,
                              title: 'Low Stock Products',
                              count: _lowStockProducts.length,
                              color: context.warningColor,
                            ),
                            const SizedBox(height: 12),
                            ..._lowStockProducts
                                .map((product) => _buildLowStockCard(context, product)),
                            const SizedBox(height: 24),
                          ],

                          // Unpaid Invoices Section
                          if (_unpaidInvoices.isNotEmpty) ...[
                            _buildSectionHeader(
                              context: context,
                              icon: Icons.receipt_long,
                              title: 'Pending Payments',
                              count: _unpaidInvoices.length,
                              color: context.errorColor,
                            ),
                            const SizedBox(height: 12),
                            ..._unpaidInvoices.map(
                                (invoice) => _buildUnpaidInvoiceCard(context, invoice)),
                          ],
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockCard(BuildContext context, ProductModel product) {
    final warningColor = context.warningColor;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: warningColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: warningColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Current Stock: ${product.currentStock} ${product.unit}',
                        style: TextStyle(
                          color: warningColor,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: context.textSecondary),
                      ),
                      Text(
                        'Min: ${product.lowStockAlert ?? 'N/A'}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpaidInvoiceCard(BuildContext context, InvoiceModel invoice) {
    final daysOld = DateTime.now().difference(invoice.createdAt).inDays;
    final isOverdue = daysOld > 7;
    final statusColor = isOverdue ? context.errorColor : context.warningColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceReceiptScreen(invoice: invoice),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: isOverdue ? 0.5 : 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOverdue ? Icons.error_outline : Icons.schedule,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.warningColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            color: context.warningColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.customerName ?? 'Walk-in Customer',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${invoice.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (daysOld > 0) ...[
                        Text(' • ', style: TextStyle(color: context.textSecondary)),
                        Text(
                          '$daysOld day${daysOld != 1 ? 's' : ''} old',
                          style: TextStyle(
                            color: isOverdue ? statusColor : context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up! No alerts at the moment.',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
