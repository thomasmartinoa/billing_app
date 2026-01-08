import 'package:flutter/foundation.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/customer_model.dart';

class CustomerProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load customers
  Future<void> loadCustomers() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _customers = await _firestoreService.getCustomers();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Add customer
  Future<bool> addCustomer(CustomerModel customer) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.addCustomer(customer);
      await loadCustomers(); // Reload customers
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.updateCustomer(customer);
      await loadCustomers(); // Reload customers
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String customerId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.deleteCustomer(customerId);
      await loadCustomers(); // Reload customers
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Get customer by ID
  CustomerModel? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search customers
  List<CustomerModel> searchCustomers(String query) {
    if (query.isEmpty) return _customers;
    
    final lowerQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
             (customer.email?.toLowerCase().contains(lowerQuery) ?? false) ||
             (customer.phone?.toLowerCase().contains(lowerQuery) ?? false);
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
