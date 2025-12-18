import 'package:flutter/material.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00C59E),
          labelColor: const Color(0xFF00C59E),
          unselectedLabelColor: Colors.white54,
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
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0x14181818),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.white24),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
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
              children: const [
                _EmptyBillingState(),
                _EmptyBillingState(),
                _EmptyBillingState(),
              ],
            ),
          ),
        ],
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to CreateInvoiceScreen
        },
        backgroundColor: const Color(0xFF00C59E),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0E5A4A),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 36,
              color: Color(0xFF00C59E),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No invoices yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Create your first invoice to get started',
            style: TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to CreateInvoiceScreen
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C59E),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
