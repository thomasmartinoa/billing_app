// lib/create_invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/screens/invoice_receipt_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _firestoreService = FirestoreService();
  
  List<ProductModel> products = [];
  List<CustomerModel> customers = [];
  UserModel? userData;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController discountController = TextEditingController(text: '0');
  final TextEditingController notesController = TextEditingController();

  List<CartItem> cart = [];
  String selectedPayment = 'Cash';
  bool markAsPaid = false;
  CustomerModel? selectedCustomer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final productsData = await _firestoreService.getProducts();
      final customersData = await _firestoreService.getCustomers();
      final user = await _firestoreService.getUserData();
      
      if (mounted) {
        setState(() {
          products = productsData;
          customers = customersData;
          userData = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  // Add product to cart (or increment if exists)
  void addToCart(ProductModel product) {
    final idx = cart.indexWhere((c) => c.product.id == product.id);
    setState(() {
      if (idx >= 0) {
        cart[idx].qty += 1;
      } else {
        cart.add(CartItem(product: product, qty: 1));
      }
    });
  }

  void removeFromCart(String? productId) {
    if (productId == null) return;
    setState(() {
      cart.removeWhere((c) => c.product.id == productId);
    });
  }

  void changeQty(String? productId, int delta) {
    if (productId == null) return;
    final idx = cart.indexWhere((c) => c.product.id == productId);
    if (idx < 0) return;
    setState(() {
      cart[idx].qty += delta;
      if (cart[idx].qty <= 0) cart.removeAt(idx);
    });
  }

  double get taxRate => userData?.shopSettings?.taxRate ?? 15.0;

  double get subTotal {
    double s = 0;
    for (final c in cart) s += c.product.sellingPrice * c.qty;
    final discount = double.tryParse(discountController.text) ?? 0;
    s -= discount;
    if (s < 0) s = 0;
    return s;
  }

  double get tax => subTotal * (taxRate / 100);
  double get total => subTotal + tax;

  // Filtered product list based on search
  List<ProductModel> get filteredProducts {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _createInvoice() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to cart')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final invoiceNumber = await _firestoreService.generateInvoiceNumber();
      
      final invoice = InvoiceModel(
        invoiceNumber: invoiceNumber,
        customerId: selectedCustomer?.id,
        customerName: selectedCustomer?.name,
        items: cart.map((c) => InvoiceItem(
          productId: c.product.id!,
          productName: c.product.name,
          price: c.product.sellingPrice,
          quantity: c.qty,
          unit: c.product.unit,
        )).toList(),
        subtotal: subTotal,
        discount: double.tryParse(discountController.text) ?? 0,
        taxRate: taxRate,
        taxAmount: tax,
        total: total,
        paymentMethod: _getPaymentMethod(),
        status: markAsPaid ? InvoiceStatus.paid : InvoiceStatus.pending,
        notes: notesController.text.isEmpty ? null : notesController.text,
        createdAt: DateTime.now(),
        paidAt: markAsPaid ? DateTime.now() : null,
      );

      final invoiceId = await _firestoreService.addInvoice(invoice);
      final savedInvoice = await _firestoreService.getInvoice(invoiceId);

      if (mounted && savedInvoice != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceReceiptScreen(invoice: savedInvoice),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating invoice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  PaymentMethod _getPaymentMethod() {
    switch (selectedPayment) {
      case 'Cash': return PaymentMethod.cash;
      case 'Card': return PaymentMethod.card;
      case 'UPI': return PaymentMethod.upi;
      case 'Bank Transfer': return PaymentMethod.bankTransfer;
      case 'Cheque': return PaymentMethod.cheque;
      case 'Credit': return PaymentMethod.credit;
      default: return PaymentMethod.other;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    discountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('New Invoice'), leading: BackButton()),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00C59E))),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('New Invoice'),
        leading: BackButton(),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                cart.clear();
                discountController.text = '0';
                selectedPayment = 'Cash';
                markAsPaid = false;
                selectedCustomer = null;
              });
            },
            child: Text('Clear', style: TextStyle(color: Color(0xFF00C59E))),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, cart.isEmpty ? 16 : 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer card
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF0E5A4A).withValues(alpha: 0.8)),
                    color: Color(0x14181818),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.person, color: Color(0xFF00C59E)),
                        SizedBox(width: 8),
                        Text('Customer', style: TextStyle(color: Colors.white70)),
                      ]),
                      SizedBox(height: 12),
                      InkWell(
                        onTap: _showCustomerSelection,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(0xFF0E5A4A).withValues(alpha: 0.5)),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Icon(selectedCustomer != null ? Icons.person : Icons.person_add, color: Color(0xFF00C59E)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedCustomer?.name ?? 'Select Customer (Optional)',
                                  style: TextStyle(color: Color(0xFF00C59E)),
                                ),
                              ),
                              if (selectedCustomer != null)
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white54, size: 18),
                                  onPressed: () => setState(() => selectedCustomer = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Search
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0x14181818),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white24),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(color: Colors.white70),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white24),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Product grid
                if (filteredProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        products.isEmpty ? 'No products yet. Add products first.' : 'No products match your search.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: filteredProducts.map((p) {
                      final inCart = cart.any((c) => c.product.id == p.id);
                      return GestureDetector(
                        onTap: () => addToCart(p),
                        child: Container(
                          width: 110,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: inCart ? Color(0x0F00C59E) : Color(0x14181818),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: inCart ? Color(0xFF00C59E) : Colors.transparent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0E5A4A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.inventory_2, color: Color(0xFF00C59E)),
                              ),
                              SizedBox(height: 8),
                              Text(p.name, style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 6),
                              Text('₹${p.sellingPrice.toStringAsFixed(0)}', style: TextStyle(color: Color(0xFF00C59E))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 18),

                // Cart header - only show when items in cart
                if (cart.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Color(0xFF00C59E)),
                      SizedBox(width: 8),
                      Text('Cart (${cart.fold<int>(0, (sum, c) => sum + c.qty)} items)',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Cart items list
                  Column(
                    children: cart.map((c) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0x14181818),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.product.name, style: TextStyle(color: Colors.white70)),
                                  SizedBox(height: 6),
                                  Text('₹${c.product.sellingPrice.toStringAsFixed(2)} × ${c.qty}',
                                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0x33181818),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    icon: Icon(Icons.remove, color: Colors.white54),
                                    onPressed: () => changeQty(c.product.id, -1),
                                  ),
                                  SizedBox(width: 8),
                                  Text('${c.qty}', style: TextStyle(color: Colors.white)),
                                  SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    icon: Icon(Icons.add, color: Colors.white54),
                                    onPressed: () => changeQty(c.product.id, 1),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${(c.product.sellingPrice * c.qty).toStringAsFixed(2)}',
                                    style: TextStyle(color: Color(0xFF00C59E))),
                                SizedBox(height: 8),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => removeFromCart(c.product.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 12),

                  // Discount row
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0x14181818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, color: Color(0xFF00C59E)),
                        SizedBox(width: 12),
                        Expanded(child: Text('Discount', style: TextStyle(color: Colors.white70))),
                        SizedBox(width: 12),
                        Container(
                          width: 110,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Color(0x11181818),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: discountController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                            style: TextStyle(color: Colors.white70),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              prefixStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18),

                  // Payment method chips
                  Text('Payment Method', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Cash', 'Card', 'UPI', 'Bank Transfer', 'Cheque', 'Credit', 'Other']
                        .map((m) => ChoiceChip(
                              label: Text(m),
                              selected: selectedPayment == m,
                              onSelected: (_) => setState(() => selectedPayment = m),
                              selectedColor: Color(0xFF0B8E73),
                              backgroundColor: Color(0x14181818),
                              labelStyle: TextStyle(color: selectedPayment == m ? Colors.white : Colors.white70),
                            ))
                        .toList(),
                  ),

                  SizedBox(height: 18),

                  // Mark as Paid
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0x14181818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.credit_card, color: Color(0xFF00C59E)),
                        SizedBox(width: 12),
                        Expanded(child: Text('Mark as Paid', style: TextStyle(color: Colors.white70))),
                        Switch(
                          value: markAsPaid,
                          onChanged: (v) => setState(() => markAsPaid = v),
                          activeColor: Color(0xFF00C59E),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 18),

                  // Notes
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0x14181818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, color: Color(0xFF00C59E)),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: notesController,
                            style: TextStyle(color: Colors.white70),
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Notes',
                              hintStyle: TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),

      // Bottom totals & Create button - only show when cart has items
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Color(0xFF141618),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // totals row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Subtotal', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 6),
                        Text('Tax (${taxRate.toStringAsFixed(1)}%)', style: TextStyle(color: Colors.white70)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₹${subTotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 6),
                        Text('₹${tax.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                      ]),
                    ],
                  ),

                  SizedBox(height: 8),

                  Divider(color: Colors.white12, thickness: 1),

                  SizedBox(height: 8),

                  // total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      Text('₹${total.toStringAsFixed(2)}',
                          style: TextStyle(color: Color(0xFF00C59E), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),

                  SizedBox(height: 12),

                  // button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _createInvoice,
                      icon: _isSaving 
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Icon(Icons.receipt_long),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(_isSaving ? 'Creating...' : 'Create Invoice', style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C59E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  void _showCustomerSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Customer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (customers.isEmpty)
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No customers yet', style: TextStyle(color: Colors.white54))),
                )
              else
                Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF0E5A4A),
                          child: Text(customer.name[0].toUpperCase(), style: TextStyle(color: Color(0xFF00C59E))),
                        ),
                        title: Text(customer.name, style: TextStyle(color: Colors.white)),
                        subtitle: Text(customer.phone ?? '', style: TextStyle(color: Colors.white54)),
                        onTap: () {
                          setState(() => selectedCustomer = customer);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Cart item class using ProductModel
class CartItem {
  final ProductModel product;
  int qty;
  CartItem({required this.product, this.qty = 1});
}
