import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/models/invoice_model.dart';

class FirestoreService {
  // Singleton pattern - ensures only one instance exists
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ==================== USER METHODS ====================

  /// Get user document reference
  DocumentReference<Map<String, dynamic>> get _userDoc {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId);
  }

  /// Get user data
  Future<UserModel?> getUserData() async {
    if (_userId == null) return null;
    final doc = await _userDoc.get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Update user shop settings
  Future<void> updateShopSettings(ShopSettings settings) async {
    await _userDoc.update({
      'shopSettings': settings.toMap(),
      'isSetupComplete': true,
    });
  }

  /// Stream user data
  Stream<UserModel?> streamUserData() {
    if (_userId == null) return Stream.value(null);
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  // ==================== CUSTOMER METHODS ====================

  /// Get customers collection reference
  CollectionReference<Map<String, dynamic>> get _customersCollection {
    return _userDoc.collection('customers');
  }

  /// Add a new customer
  Future<String> addCustomer(CustomerModel customer) async {
    final doc = await _customersCollection.add(customer.toMap());
    return doc.id;
  }

  /// Update a customer
  Future<void> updateCustomer(CustomerModel customer) async {
    if (customer.id == null) throw Exception('Customer ID is required');
    await _customersCollection.doc(customer.id).update(customer.toMap());
  }

  /// Delete a customer
  Future<void> deleteCustomer(String customerId) async {
    await _customersCollection.doc(customerId).delete();
  }

  /// Get a single customer
  Future<CustomerModel?> getCustomer(String customerId) async {
    final doc = await _customersCollection.doc(customerId).get();
    if (!doc.exists) return null;
    return CustomerModel.fromMap(doc.data()!, doc.id);
  }

  /// Stream all customers
  Stream<List<CustomerModel>> streamCustomers() {
    return _customersCollection.orderBy('name').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get all customers (one-time)
  Future<List<CustomerModel>> getCustomers() async {
    final snapshot = await _customersCollection.orderBy('name').get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Get customer count
  Future<int> getCustomerCount() async {
    final snapshot = await _customersCollection.count().get();
    return snapshot.count ?? 0;
  }

  // ==================== PRODUCT METHODS ====================

  /// Get products collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection {
    return _userDoc.collection('products');
  }

  /// Add a new product
  Future<String> addProduct(ProductModel product) async {
    final doc = await _productsCollection.add(product.toMap());
    return doc.id;
  }

  /// Update a product
  Future<void> updateProduct(ProductModel product) async {
    if (product.id == null) throw Exception('Product ID is required');
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  /// Get a single product
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _productsCollection.doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.data()!, doc.id);
  }

  /// Stream all products
  Stream<List<ProductModel>> streamProducts() {
    return _productsCollection.orderBy('name').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get all products (one-time)
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _productsCollection.orderBy('name').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Get product count
  Future<int> getProductCount() async {
    final snapshot = await _productsCollection.count().get();
    return snapshot.count ?? 0;
  }

  /// Get low stock products count
  Future<int> getLowStockCount() async {
    final products = await getProducts();
    return products.where((p) => p.isLowStock).length;
  }

  /// Update product stock
  Future<void> updateProductStock(String productId, int newStock) async {
    await _productsCollection.doc(productId).update({
      'currentStock': newStock,
      'updatedAt': Timestamp.now(),
    });
  }

  // ==================== INVOICE METHODS ====================

  /// Get invoices collection reference
  CollectionReference<Map<String, dynamic>> get _invoicesCollection {
    return _userDoc.collection('invoices');
  }

  /// Generate next invoice number
  Future<String> generateInvoiceNumber() async {
    final userData = await getUserData();
    final prefix = userData?.shopSettings?.invoicePrefix ?? 'INV';

    final snapshot = await _invoicesCollection
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1;
    if (snapshot.docs.isNotEmpty) {
      final lastInvoice = InvoiceModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
      // Extract number from last invoice
      final lastNumber =
          lastInvoice.invoiceNumber.replaceAll(RegExp(r'[^0-9]'), '');
      nextNumber = int.tryParse(lastNumber) ?? 0;
      nextNumber++;
    }

    return '$prefix-${nextNumber.toString().padLeft(5, '0')}';
  }

  /// Add a new invoice
  Future<String> addInvoice(InvoiceModel invoice) async {
    final doc = await _invoicesCollection.add(invoice.toMap());

    // Update product stock if tracking inventory
    for (final item in invoice.items) {
      final product = await getProduct(item.productId);
      if (product != null && product.trackInventory) {
        await updateProductStock(
          item.productId,
          product.currentStock - item.quantity,
        );
      }
    }

    return doc.id;
  }

  /// Update an invoice (full update)
  Future<void> updateInvoiceFull(InvoiceModel invoice) async {
    if (invoice.id == null) throw Exception('Invoice ID is required');
    await _invoicesCollection.doc(invoice.id).update(invoice.toMap());
  }

  /// Update invoice fields (partial update)
  Future<void> updateInvoice(
      String invoiceId, Map<String, dynamic> data) async {
    await _invoicesCollection.doc(invoiceId).update(data);
  }

  /// Delete an invoice
  Future<void> deleteInvoice(String invoiceId) async {
    await _invoicesCollection.doc(invoiceId).delete();
  }

  /// Get a single invoice
  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final doc = await _invoicesCollection.doc(invoiceId).get();
    if (!doc.exists) return null;
    return InvoiceModel.fromMap(doc.data()!, doc.id);
  }

  /// Stream all invoices
  Stream<List<InvoiceModel>> streamInvoices() {
    return _invoicesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvoiceModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream invoices by status
  Stream<List<InvoiceModel>> streamInvoicesByStatus(InvoiceStatus status) {
    return _invoicesCollection
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
      final invoices = snapshot.docs
          .map((doc) => InvoiceModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in memory to avoid index requirement
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return invoices;
    });
  }

  /// Get all invoices (one-time)
  Future<List<InvoiceModel>> getInvoices() async {
    final snapshot =
        await _invoicesCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => InvoiceModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Get invoice count
  Future<int> getInvoiceCount() async {
    final snapshot = await _invoicesCollection.count().get();
    return snapshot.count ?? 0;
  }

  /// Get recent invoices
  Future<List<InvoiceModel>> getRecentInvoices({int limit = 5}) async {
    final snapshot = await _invoicesCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => InvoiceModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Mark invoice as paid
  Future<void> markInvoiceAsPaid(String invoiceId) async {
    await _invoicesCollection.doc(invoiceId).update({
      'status': InvoiceStatus.paid.name,
      'paidAt': Timestamp.now(),
    });
  }

  // ==================== DASHBOARD STATS ====================

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final customerCount = await getCustomerCount();
    final productCount = await getProductCount();
    final invoiceCount = await getInvoiceCount();
    final lowStockCount = await getLowStockCount();

    return {
      'customers': customerCount,
      'products': productCount,
      'sales': invoiceCount,
      'lowStock': lowStockCount,
    };
  }

  // ==================== CATEGORY METHODS ====================

  /// Get categories collection reference
  CollectionReference<Map<String, dynamic>> get _categoriesCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _userDoc.collection('categories');
  }

  /// Add category
  Future<void> addCategory(String categoryName) async {
    await _categoriesCollection.add({
      'name': categoryName,
      'createdAt': Timestamp.now(),
    });
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    final snapshot = await _categoriesCollection.orderBy('name').get();
    return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
  }

  /// Stream categories
  Stream<List<Map<String, dynamic>>> streamCategories() {
    return _categoriesCollection.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    'name': doc.data()['name'] as String,
                  })
              .toList(),
        );
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
  }
}
