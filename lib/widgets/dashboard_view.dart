import 'package:flutter/material.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';
import 'package:billing_app/utils/currency_formatter.dart';
import 'package:billing_app/widgets/dashboard_card.dart';
import 'package:billing_app/widgets/quick_button.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatelessWidget {
  final Map<String, dynamic> stats;
  final ShopSettings? shopSettings;
  final List<InvoiceModel> recentInvoices;
  final VoidCallback onNewInvoice;
  final VoidCallback onAddProduct;
  final VoidCallback onAddCustomer;
  final VoidCallback onViewAllInvoices;
  final void Function(InvoiceModel) onInvoiceTap;
  final Future<void> Function() onRefresh;

  static final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  const DashboardView({
    super.key,
    required this.stats,
    required this.shopSettings,
    required this.recentInvoices,
    required this.onNewInvoice,
    required this.onAddProduct,
    required this.onAddCustomer,
    required this.onViewAllInvoices,
    required this.onInvoiceTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: context.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SHOP HEADER
              if (shopSettings != null) ...[
                _buildShopHeader(context),
                const SizedBox(height: AppSpacing.xl),
              ],

              // TOP CARDS
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.people,
                      value: "${stats['customers']}",
                      title: "Customers",
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.inventory_2_outlined,
                      value: "${stats['products']}",
                      title: "Products",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.shopping_cart,
                      value: "${stats['sales']}",
                      title: "Sales",
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.warning_amber_rounded,
                      value: "${stats['lowStock']}",
                      title: "Low Stock",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                "Quick Actions",
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: QuickButton(
                      icon: Icons.shopping_cart,
                      title: "New Invoice",
                      onTap: onNewInvoice,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: QuickButton(
                      icon: Icons.add_box,
                      title: "Add Product",
                      onTap: onAddProduct,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: QuickButton(
                      icon: Icons.person_add,
                      title: "Add Customer",
                      onTap: onAddCustomer,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Invoices",
                    style: TextStyle(
                        color: context.textSecondary,
                        fontSize: AppFontSize.lg,
                        fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: onViewAllInvoices,
                    child: Text(
                      "View All",
                      style: TextStyle(color: context.accent),
                    ),
                  )
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              recentInvoices.isEmpty
                  ? _buildEmptyInvoices(context)
                  : Column(
                      children: recentInvoices.map((invoice) {
                        return _buildInvoiceCard(context, invoice);
                      }).toList(),
                    ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: context.accent.withValues(alpha: OpacityConstants.medium)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: OpacityConstants.light),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: shopSettings != null
                ? Icon(
                    IconData(shopSettings!.iconCodePoint,
                        fontFamily: 'MaterialIcons'),
                    color: context.accent,
                    size: 32,
                  )
                : Icon(
                    Icons.store,
                    color: context.accent,
                    size: 32,
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopSettings!.name,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (shopSettings!.tagline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    shopSettings!.tagline,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (shopSettings!.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: context.accent),
                      const SizedBox(width: 4),
                      Text(
                        shopSettings!.phone,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInvoices(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: context.accent.withValues(alpha: OpacityConstants.medium)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long,
              color: context.textSecondary.withValues(alpha: OpacityConstants.high),
              size: 45),
          const SizedBox(height: 10),
          Text("No invoices yet",
              style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onNewInvoice,
            icon: Icon(Icons.add, color: context.accent),
            label: Text("Create First Invoice",
                style: TextStyle(color: context.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceModel invoice) {
    final isPaid = invoice.status == InvoiceStatus.paid;

    return GestureDetector(
      onTap: () => onInvoiceTap(invoice),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: context.accent.withValues(alpha: OpacityConstants.medium)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isPaid
                    ? context.successBackground
                    : context.warningBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? context.successColor : context.warningColor,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: AppFontSize.lg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.customerName ?? 'Walk-in Customer',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateFormat.format(invoice.createdAt),
                    style: TextStyle(
                      color: context.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(invoice.total),
                  style: TextStyle(
                    color: context.accent,
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? context.successBackground
                        : context.warningBackground,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Pending',
                    style: TextStyle(
                      color:
                          isPaid ? context.successColor : context.warningColor,
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
  }
}
