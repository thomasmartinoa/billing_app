// lib/create_invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/screens/invoice_receipt_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _firestoreService = FirestoreService();

  List<ProductModel> products = [];
  List<CustomerModel> customers = [];
  UserModel? userData;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController discountController =
      TextEditingController(text: '0');
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
    // Check if product tracks inventory
    if (!product.trackInventory) {
      final idx = cart.indexWhere((c) => c.product.id == product.id);
      setState(() {
        if (idx >= 0) {
          cart[idx].qty += 1;
        } else {
          cart.add(CartItem(product: product, qty: 1));
        }
      });
      return;
    }

    // Check available stock
    final idx = cart.indexWhere((c) => c.product.id == product.id);
    final currentQtyInCart = idx >= 0 ? cart[idx].qty : 0;

    if (currentQtyInCart >= product.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot add more. Only ${product.currentStock} ${product.unit} available in stock'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

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

    final cartItem = cart[idx];
    final newQty = cartItem.qty + delta;

    // If decreasing, just allow it
    if (delta < 0) {
      setState(() {
        cart[idx].qty = newQty;
        if (cart[idx].qty <= 0) cart.removeAt(idx);
      });
      return;
    }

    // If increasing, check stock availability
    if (cartItem.product.trackInventory &&
        newQty > cartItem.product.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot add more. Only ${cartItem.product.currentStock} ${cartItem.product.unit} available in stock'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    setState(() {
      cart[idx].qty = newQty;
      if (cart[idx].qty <= 0) cart.removeAt(idx);
    });
  }

  double get taxRate => userData?.shopSettings?.taxRate ?? 15.0;

  double get subTotal {
    double s = 0;
    for (final c in cart) {
      s += c.product.sellingPrice * c.qty;
    }
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

    // Validate stock availability before creating invoice
    for (final cartItem in cart) {
      if (cartItem.product.trackInventory &&
          cartItem.qty > cartItem.product.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Insufficient stock for ${cartItem.product.name}. Only ${cartItem.product.currentStock} available.'),
            backgroundColor: context.errorColor,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final invoiceNumber = await _firestoreService.generateInvoiceNumber();

      final invoice = InvoiceModel(
        invoiceNumber: invoiceNumber,
        customerId: selectedCustomer?.id,
        customerName: selectedCustomer?.name,
        items: cart
            .map((c) => InvoiceItem(
                  productId: c.product.id!,
                  productName: c.product.name,
                  price: c.product.sellingPrice,
                  quantity: c.qty,
                  unit: c.product.unit,
                ))
            .toList(),
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
      case 'Cash':
        return PaymentMethod.cash;
      case 'Card':
        return PaymentMethod.card;
      case 'UPI':
        return PaymentMethod.upi;
      case 'Bank Transfer':
        return PaymentMethod.bankTransfer;
      case 'Cheque':
        return PaymentMethod.cheque;
      case 'Credit':
        return PaymentMethod.credit;
      default:
        return PaymentMethod.other;
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('New Invoice'), leading: const BackButton()),
        body: Center(
            child: CircularProgressIndicator(color: context.accent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
        leading: const BackButton(),
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
            child:
                Text('Clear', style: TextStyle(color: context.accent)),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: context.accent.withValues(alpha: 0.3)),
                    color: context.cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.person, color: context.accent),
                        const SizedBox(width: 8),
                        Text('Customer',
                            style: TextStyle(color: context.textSecondary)),
                      ]),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _showCustomerSelection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: context.accent
                                    .withValues(alpha: 0.3)),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  selectedCustomer != null
                                      ? Icons.person
                                      : Icons.person_add,
                                  color: context.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedCustomer?.name ??
                                      'Select Customer (Optional)',
                                  style:
                                      TextStyle(color: context.accent),
                                ),
                              ),
                              if (selectedCustomer != null)
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: context.textSecondary, size: 18),
                                  onPressed: () =>
                                      setState(() => selectedCustomer = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: context.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(color: context.textSecondary),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: context.textSecondary.withValues(alpha: 0.4)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Product grid
                if (filteredProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        products.isEmpty
                            ? 'No products yet. Add products first.'
                            : 'No products match your search.',
                        style: TextStyle(color: context.textSecondary),
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: inCart
                                ? context.accent.withValues(alpha: 0.15)
                                : context.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: inCart
                                    ? context.accent
                                    : Colors.transparent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: context.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.inventory_2,
                                    color: context.accent),
                              ),
                              const SizedBox(height: 8),
                              Text(p.name,
                                  style: TextStyle(
                                      color: context.textSecondary, fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Text('₹${p.sellingPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      color: context.accent)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 18),

                // Cart header - only show when items in cart
                if (cart.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.shopping_cart, color: context.accent),
                      const SizedBox(width: 8),
                      Text(
                          'Cart (${cart.fold<int>(0, (sum, c) => sum + c.qty)} items)',
                          style: TextStyle(color: context.textSecondary)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Cart items list
                  Column(
                    children: cart.map((c) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.product.name,
                                      style: TextStyle(
                                          color: context.textSecondary)),
                                  const SizedBox(height: 6),
                                  Text(
                                      '₹${c.product.sellingPrice.toStringAsFixed(2)} × ${c.qty}',
                                      style: TextStyle(
                                          color: context.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.cardColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.remove,
                                        color: context.textSecondary),
                                    onPressed: () =>
                                        changeQty(c.product.id, -1),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${c.qty}',
                                      style:
                                          TextStyle(color: context.textPrimary)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.add,
                                        color: context.textSecondary),
                                    onPressed: () => changeQty(c.product.id, 1),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    '₹${(c.product.sellingPrice * c.qty).toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: context.accent)),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: context.errorColor),
                                  onPressed: () => removeFromCart(c.product.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Discount row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, color: context.accent),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('Discount',
                                style: TextStyle(color: context.textSecondary))),
                        const SizedBox(width: 12),
                        Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: context.cardColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: discountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'))
                            ],
                            style: TextStyle(color: context.textSecondary),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              prefixStyle: TextStyle(color: context.textSecondary),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Payment method chips
                  Text('Payment Method',
                      style: TextStyle(color: context.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Cash',
                      'Card',
                      'UPI',
                      'Bank Transfer',
                      'Cheque',
                      'Credit',
                      'Other'
                    ]
                        .map((m) => ChoiceChip(
                              label: Text(m),
                              selected: selectedPayment == m,
                              onSelected: (_) =>
                                  setState(() => selectedPayment = m),
                              selectedColor: context.accent.withValues(alpha: 0.8),
                              backgroundColor: context.cardColor,
                              labelStyle: TextStyle(
                                  color: selectedPayment == m
                                      ? context.textPrimary
                                      : context.textSecondary),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 18),

                  // Mark as Paid
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.credit_card, color: context.accent),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('Mark as Paid',
                                style: TextStyle(color: context.textSecondary))),
                        Switch(
                          value: markAsPaid,
                          onChanged: (v) => setState(() => markAsPaid = v),
                          activeThumbColor: context.accent,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Notes
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, color: context.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: notesController,
                            style: TextStyle(color: context.textSecondary),
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Notes',
                              hintStyle: TextStyle(color: context.textSecondary.withValues(alpha: 0.4)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
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
                color: context.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: context.textPrimary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // totals row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subtotal',
                                style: TextStyle(color: context.textSecondary)),
                            const SizedBox(height: 6),
                            Text('Tax (${taxRate.toStringAsFixed(1)}%)',
                                style: TextStyle(color: context.textSecondary)),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${subTotal.toStringAsFixed(2)}',
                                style: TextStyle(color: context.textPrimary)),
                            const SizedBox(height: 6),
                            Text('₹${tax.toStringAsFixed(2)}',
                                style: TextStyle(color: context.textPrimary)),
                          ]),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Divider(color: context.textSecondary.withValues(alpha: 0.2), thickness: 1),

                  const SizedBox(height: 8),

                  // total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              color: context.textSecondary,
                              fontWeight: FontWeight.bold)),
                      Text('₹${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: context.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _createInvoice,
                      icon: _isSaving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: context.textPrimary))
                          : const Icon(Icons.receipt_long),
                      label: Text(_isSaving ? 'Creating...' : 'Create Invoice',
                          style: const TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.accent,
                        foregroundColor: context.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
    );
  }

  void _showCustomerSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Customer',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (customers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                      child: Text('No customers yet',
                          style: TextStyle(color: context.textSecondary))),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.accent.withValues(alpha: 0.2),
                          child: Text(customer.name[0].toUpperCase(),
                              style: TextStyle(color: context.accent)),
                        ),
                        title: Text(customer.name,
                            style: TextStyle(color: context.textPrimary)),
                        subtitle: Text(customer.phone ?? '',
                            style: TextStyle(color: context.textSecondary)),
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
