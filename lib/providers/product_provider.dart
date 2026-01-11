import 'package:flutter/foundation.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load products
  Future<void> loadProducts() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _products = await _firestoreService.getProducts();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Add product
  Future<bool> addProduct(ProductModel product) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.addProduct(product);
      await loadProducts(); // Reload products
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.updateProduct(product);
      await loadProducts(); // Reload products
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.deleteProduct(productId);
      await loadProducts(); // Reload products
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Get product by ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search products
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             (product.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
