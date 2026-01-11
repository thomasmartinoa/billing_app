import 'package:flutter/material.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/screens/add_product_screen.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final profit = product.costPrice != null
        ? product.sellingPrice - product.costPrice!
        : null;
    final profitMargin = profit != null && product.costPrice! > 0
        ? (profit / product.costPrice!) * 100
        : null;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details',
          style: TextStyle(color: context.textWhite, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: context.accent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: context.accent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: TextStyle(
                      color: context.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: TextStyle(
                        color: context.textGray,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (product.category != null &&
                      product.category!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.category!,
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Price & Stock Section
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    icon: Icons.currency_rupee,
                    title: 'Selling Price',
                    value: '\u20b9${product.sellingPrice.toStringAsFixed(2)}',
                    color: context.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Stock',
                    value: '${product.currentStock} ${product.unit}',
                    color: product.isLowStock ? context.warningColor : context.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Detailed Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Information',
                    style: TextStyle(
                      color: context.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, 'Unit', product.unit),
                  if (product.costPrice != null)
                    _buildDetailRow(context, 'Cost Price',
                        '\u20b9${product.costPrice!.toStringAsFixed(2)}'),
                  if (profit != null)
                    _buildDetailRow(context,
                        'Profit per Unit', '\u20b9${profit.toStringAsFixed(2)}',
                        valueColor: context.successColor),
                  if (profitMargin != null)
                    _buildDetailRow(context,
                        'Profit Margin', '${profitMargin.toStringAsFixed(1)}%',
                        valueColor: context.successColor),
                  if (product.sku != null && product.sku!.isNotEmpty)
                    _buildDetailRow(context, 'SKU', product.sku!),
                  if (product.barcode != null && product.barcode!.isNotEmpty)
                    _buildDetailRow(context, 'Barcode', product.barcode!),
                  _buildDetailRow(context,
                      'Track Inventory', product.trackInventory ? 'Yes' : 'No'),
                  if (product.lowStockAlert != null)
                    _buildDetailRow(context, 'Low Stock Alert',
                        '${product.lowStockAlert} ${product.unit}',
                        valueColor: product.isLowStock ? context.warningColor : null),
                  Divider(color: context.borderColor, height: 32),
                  _buildDetailRow(context,
                      'Created', dateFormat.format(product.createdAt)),
                  _buildDetailRow(context,
                      'Last Updated', dateFormat.format(product.updatedAt)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stock Status Warning
            if (product.isLowStock)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.warningBackground,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.warningColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: context.warningColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Low stock alert! Consider restocking soon.',
                        style: TextStyle(color: context.warningColor, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: context.textGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textGray,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? context.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
