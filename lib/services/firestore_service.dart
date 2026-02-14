import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/constants/firestore_constants.dart';
import 'package:billing_app/constants/app_constants.dart';
import 'package:billing_app/utils/app_exceptions.dart';
import 'package:billing_app/utils/error_handler.dart';

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
    final userId = _userId;
    if (userId == null) {
      throw AuthenticationException();
    }
    return _firestore.collection(FirestoreCollections.users).doc(userId);
  }

  /// Get user data
  Future<UserModel?> getUserData() async {
    try {
      if (_userId == null) return null;
      final doc = await _userDoc.get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'getUserData');
      throw FirestoreException.fromFirebase(e);
    }
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
    return _userDoc.collection(FirestoreCollections.customers);
  }

  /// Add a new customer
  Future<String> addCustomer(CustomerModel customer) async {
    try {
      final doc = await _customersCollection.add(customer.toMap());
      return doc.id;
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'addCustomer');
      throw FirestoreException.fromFirebase(e);
    }
  }

  /// Update a customer
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      final customerId = customer.id;
      if (customerId == null || customerId.isEmpty) {
        throw MissingFieldException('Customer ID');
      }
      await _customersCollection.doc(customerId).update(customer.toMap());
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'updateCustomer');
      throw FirestoreException.fromFirebase(e);
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _customersCollection.doc(customerId).delete();
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'deleteCustomer');
      throw FirestoreException.fromFirebase(e);
    }
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
    return _userDoc.collection(FirestoreCollections.products);
  }

  /// Add a new product
  Future<String> addProduct(ProductModel product) async {
    try {
      final doc = await _productsCollection.add(product.toMap());
      return doc.id;
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'addProduct');
      throw FirestoreException.fromFirebase(e);
    }
  }

  /// Update a product
  Future<void> updateProduct(ProductModel product) async {
    try {
      final productId = product.id;
      if (productId == null || productId.isEmpty) {
        throw MissingFieldException('Product ID');
      }
      await _productsCollection.doc(productId).update(product.toMap());
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'updateProduct');
      throw FirestoreException.fromFirebase(e);
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'deleteProduct');
      throw FirestoreException.fromFirebase(e);
    }
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
    return _userDoc.collection(FirestoreCollections.invoices);
  }

  /// Generate next invoice number
  Future<String> generateInvoiceNumber() async {
    try {
      final userData = await getUserData();
      final prefix = userData?.shopSettings?.invoicePrefix ?? 
                     BusinessConstants.defaultInvoicePrefix;

      final snapshot = await _invoicesCollection
          .orderBy(FirestoreFields.createdAt, descending: true)
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
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'generateInvoiceNumber');
      throw FirestoreException.fromFirebase(e);
    }
  }

  /// Add a new invoice with atomic stock updates using a transaction
  ///
  /// Throws:
  ///   - [ProductNotFoundException] if a product no longer exists
  ///   - [InsufficientStockException] if stock is insufficient for any item
  ///   - [FirestoreException] for other Firestore errors
  Future<String> addInvoice(InvoiceModel invoice) async {
    try {
      String? docId;
      
      await _firestore.runTransaction((transaction) async {
        // First, verify and reserve stock for all items
        final stockUpdates = <String, int>{};
        
        for (final item in invoice.items) {
          final productDoc = _productsCollection.doc(item.productId);
          final productSnapshot = await transaction.get(productDoc);
          
          if (!productSnapshot.exists) {
            throw ProductNotFoundException(item.productId, item.productName);
          }
          
          final productData = productSnapshot.data()!;
          final trackInventory = productData[FirestoreFields.trackInventory] ?? true;
          
          if (trackInventory) {
            final currentStock = productData[FirestoreFields.currentStock] ?? 0;
            if (currentStock < item.quantity) {
              throw InsufficientStockException(
                item.productName, 
                currentStock, 
                item.quantity,
              );
            }
            stockUpdates[item.productId] = currentStock - item.quantity;
          }
        }
        
        // Create the invoice
        final invoiceDoc = _invoicesCollection.doc();
        docId = invoiceDoc.id;
        transaction.set(invoiceDoc, invoice.toMap());
        
        // Update all stock levels atomically
        for (final entry in stockUpdates.entries) {
          final productDoc = _productsCollection.doc(entry.key);
          transaction.update(productDoc, {
            FirestoreFields.currentStock: entry.value,
            FirestoreFields.updatedAt: Timestamp.now(),
          });
        }
      });
      
      // Ensure docId was set - this should always happen but check for safety
      final generatedId = docId;
      if (generatedId == null) {
        throw FirestoreException(
          code: 'internal',
          message: 'Failed to generate invoice document ID',
        );
      }
      
      return generatedId;
    } on AppException {
      // Re-throw our custom exceptions as-is
      rethrow;
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'addInvoice');
      throw FirestoreException.fromFirebase(e);
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'addInvoice');
      rethrow;
    }
  }

  /// Update an invoice (full update) with atomic stock adjustment
  ///
  /// Uses a transaction to atomically:
  /// 1. Read old invoice to get original quantities
  /// 2. Compute delta per product (new qty - old qty)
  /// 3. Validate sufficient stock for any increases
  /// 4. Adjust stock and update invoice atomically
  Future<void> updateInvoiceFull(InvoiceModel invoice) async {
    if (invoice.id == null) throw MissingFieldException('Invoice ID');

    try {
      await _firestore.runTransaction((transaction) async {
        // Read the old invoice
        final invoiceDoc = _invoicesCollection.doc(invoice.id);
        final oldSnapshot = await transaction.get(invoiceDoc);

        if (!oldSnapshot.exists) {
          throw InvoiceNotFoundException(invoice.id!);
        }

        final oldInvoice = InvoiceModel.fromMap(oldSnapshot.data()!, oldSnapshot.id);

        // Build maps of productId -> quantity for old and new invoices
        final oldQtyMap = <String, int>{};
        for (final item in oldInvoice.items) {
          oldQtyMap[item.productId] = (oldQtyMap[item.productId] ?? 0) + item.quantity;
        }

        final newQtyMap = <String, int>{};
        for (final item in invoice.items) {
          newQtyMap[item.productId] = (newQtyMap[item.productId] ?? 0) + item.quantity;
        }

        // Compute deltas and collect all affected product IDs
        final allProductIds = {...oldQtyMap.keys, ...newQtyMap.keys};
        final stockUpdates = <String, int>{};

        for (final productId in allProductIds) {
          final oldQty = oldQtyMap[productId] ?? 0;
          final newQty = newQtyMap[productId] ?? 0;
          final delta = newQty - oldQty;

          if (delta == 0) continue;

          final productDoc = _productsCollection.doc(productId);
          final productSnapshot = await transaction.get(productDoc);

          if (!productSnapshot.exists) {
            // Product was deleted; skip stock adjustment for removed items,
            // but throw if new invoice references a deleted product
            if (newQty > 0) {
              final name = invoice.items
                  .firstWhere((i) => i.productId == productId)
                  .productName;
              throw ProductNotFoundException(productId, name);
            }
            continue;
          }

          final productData = productSnapshot.data()!;
          final trackInventory = productData[FirestoreFields.trackInventory] ?? true;

          if (trackInventory) {
            final currentStock = productData[FirestoreFields.currentStock] ?? 0;
            final newStock = currentStock - delta; // delta>0 means more consumed

            if (newStock < 0) {
              final name = invoice.items
                  .where((i) => i.productId == productId)
                  .firstOrNull
                  ?.productName ?? productId;
              throw InsufficientStockException(name, currentStock + oldQty, newQty);
            }

            stockUpdates[productId] = newStock;
          }
        }

        // Update the invoice document
        transaction.update(invoiceDoc, invoice.toMap());

        // Apply all stock updates atomically
        for (final entry in stockUpdates.entries) {
          final productDoc = _productsCollection.doc(entry.key);
          transaction.update(productDoc, {
            FirestoreFields.currentStock: entry.value,
            FirestoreFields.updatedAt: Timestamp.now(),
          });
        }
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'updateInvoiceFull');
      throw FirestoreException.fromFirebase(e);
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'updateInvoiceFull');
      rethrow;
    }
  }

  /// Update invoice fields (partial update)
  Future<void> updateInvoice(
      String invoiceId, Map<String, dynamic> data) async {
    try {
      await _invoicesCollection.doc(invoiceId).update(data);
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'updateInvoice');
      throw FirestoreException.fromFirebase(e);
    }
  }

  /// Delete an invoice and restore stock for all items
  ///
  /// Uses a transaction to atomically:
  /// 1. Read the invoice to get its items
  /// 2. Restore stock for each item where the product exists and tracks inventory
  /// 3. Delete the invoice document
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Read the invoice first
        final invoiceDoc = _invoicesCollection.doc(invoiceId);
        final invoiceSnapshot = await transaction.get(invoiceDoc);

        if (!invoiceSnapshot.exists) {
          throw InvoiceNotFoundException(invoiceId);
        }

        final invoice = InvoiceModel.fromMap(invoiceSnapshot.data()!, invoiceSnapshot.id);

        // Restore stock for each item
        for (final item in invoice.items) {
          final productDoc = _productsCollection.doc(item.productId);
          final productSnapshot = await transaction.get(productDoc);

          if (productSnapshot.exists) {
            final productData = productSnapshot.data()!;
            final trackInventory = productData[FirestoreFields.trackInventory] ?? true;

            if (trackInventory) {
              final currentStock = productData[FirestoreFields.currentStock] ?? 0;
              transaction.update(productDoc, {
                FirestoreFields.currentStock: currentStock + item.quantity,
                FirestoreFields.updatedAt: Timestamp.now(),
              });
            }
          }
        }

        // Delete the invoice
        transaction.delete(invoiceDoc);
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'deleteInvoice');
      throw FirestoreException.fromFirebase(e);
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'deleteInvoice');
      rethrow;
    }
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
    if (_userId == null) throw AuthenticationException();
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
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } on FirebaseException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'deleteCategory');
      throw FirestoreException.fromFirebase(e);
    }
  }
}
