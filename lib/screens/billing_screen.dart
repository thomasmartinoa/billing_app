import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/screens/create_invoice_screen.dart';
import 'package:billing_app/screens/invoice_receipt_screen.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.accent,
          labelColor: context.accent,
          unselectedLabelColor: context.textPrimary.withValues(alpha: 0.54),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Paid'),
          ],
        ),
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: context.textPrimary.withValues(alpha: 0.24)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        hintStyle: TextStyle(color: context.textPrimary.withValues(alpha: 0.24)),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: context.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvoiceList(null), // All
                _buildInvoiceList(InvoiceStatus.pending),
                _buildInvoiceList(InvoiceStatus.paid),
              ],
            ),
          ),
        ],
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
          );
        },
        backgroundColor: context.accent,
        foregroundColor: context.textPrimary,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  Widget _buildInvoiceList(InvoiceStatus? status) {
    Stream<List<InvoiceModel>> stream;
    if (status == null) {
      stream = _firestoreService.streamInvoices();
    } else {
      stream = _firestoreService.streamInvoicesByStatus(status);
    }

    return StreamBuilder<List<InvoiceModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: context.accent),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final invoices = snapshot.data ?? [];
        final filteredInvoices = invoices.where((inv) {
          return inv.invoiceNumber.toLowerCase().contains(_searchQuery) ||
              (inv.customerName?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (invoices.isEmpty) {
          return const _EmptyBillingState();
        }

        if (filteredInvoices.isEmpty) {
          return Center(
            child: Text(
              'No invoices matching "$_searchQuery"',
              style: TextStyle(color: context.textPrimary.withValues(alpha: 0.54)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredInvoices.length,
          itemBuilder: (context, index) {
            final invoice = filteredInvoices[index];
            return _buildInvoiceCard(invoice);
          },
        );
      },
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceReceiptScreen(invoice: invoice),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.accent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: invoice.status == InvoiceStatus.paid
                    ? context.accent.withValues(alpha: 0.2)
                    : context.cardColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.receipt_long,
                color: invoice.status == InvoiceStatus.paid
                    ? context.accent
                    : context.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.customerName ?? 'Walk-in Customer',
                    style: TextStyle(
                      color: context.textPrimary.withValues(alpha: 0.54),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    dateFormat.format(invoice.createdAt),
                    style: TextStyle(
                      color: context.textPrimary.withValues(alpha: 0.38),
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
                  '₹${invoice.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: invoice.status == InvoiceStatus.paid
                        ? context.accent.withValues(alpha: 0.2)
                        : context.cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    invoice.status == InvoiceStatus.paid ? 'PAID' : 'PENDING',
                    style: TextStyle(
                      color: invoice.status == InvoiceStatus.paid
                          ? context.accent
                          : context.textSecondary,
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

// ---------------- EMPTY STATE WIDGET ----------------

class _EmptyBillingState extends StatelessWidget {
  const _EmptyBillingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.accent.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.receipt_long,
              size: 36,
              color: context.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No invoices yet',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your first invoice to get started',
            style: TextStyle(color: context.textPrimary.withValues(alpha: 0.54)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: context.textPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
