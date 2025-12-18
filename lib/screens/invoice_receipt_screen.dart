import 'package:flutter/material.dart';

class InvoiceReceiptScreen extends StatelessWidget {
  const InvoiceReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice INV-00001'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),

      body: Center(
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
                const Text(
                  'Test Shop1',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('hi there', style: TextStyle(color: Colors.black54)),
                const Text('kollam', style: TextStyle(color: Colors.black54)),
                const Text('Tel: 9134554', style: TextStyle(color: Colors.black54)),

                const Divider(height: 28),

                // INVOICE META
                _row('Invoice', 'INV-00001'),
                _row('Date', '07/12/2025 11:38 PM'),

                const Divider(height: 28),

                // HEADER
                _headerRow(),

                const SizedBox(height: 6),

                // ITEMS
                _itemRow(
                  name: 'testp1',
                  sub: '₹1000.00 × 2 pcs',
                  qty: '2',
                  amount: '₹2000.00',
                ),
                _itemRow(
                  name: 'p2',
                  sub: '₹20.00 × 2 box',
                  qty: '2',
                  amount: '₹40.00',
                ),

                const Divider(height: 28),

                // TOTALS
                _row('Subtotal', '₹2040.00'),
                _row('Tax (15.0%)', '₹306.00'),

                const SizedBox(height: 10),

                _row(
                  'TOTAL',
                  '₹2346.00',
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
                      _row('Payment Method', 'Cash'),
                      _row('Paid', '₹2346.00'),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'thankyou',
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 8),

                const Text(
                  '*** PAID ***',
                  style: TextStyle(
                    color: Colors.green,
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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
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
                onPressed: () {},
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
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
