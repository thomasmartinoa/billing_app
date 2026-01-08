import 'package:flutter/foundation.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/invoice_model.dart';

class InvoiceProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stats getters
  double get totalRevenue {
    return _invoices
        .where((inv) => inv.status == InvoiceStatus.paid)
        .fold(0.0, (sum, inv) => sum + inv.total);
  }

  int get totalInvoices => _invoices.length;

  int get paidInvoices {
    return _invoices.where((inv) => inv.status == InvoiceStatus.paid).length;
  }

  int get unpaidInvoices {
    return _invoices.where((inv) => inv.status == InvoiceStatus.pending).length;
  }

  // Load invoices
  Future<void> loadInvoices() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _invoices = await _firestoreService.getInvoices();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Add invoice
  Future<bool> addInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.addInvoice(invoice);
      await loadInvoices(); // Reload invoices
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update invoice
  Future<bool> updateInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.updateInvoiceFull(invoice);
      await loadInvoices(); // Reload invoices
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Delete invoice
  Future<bool> deleteInvoice(String invoiceId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.deleteInvoice(invoiceId);
      await loadInvoices(); // Reload invoices
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Mark as paid
  Future<bool> markAsPaid(String invoiceId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _firestoreService.markInvoiceAsPaid(invoiceId);
      await loadInvoices(); // Reload invoices
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Get invoice by ID
  InvoiceModel? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((inv) => inv.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get recent invoices
  List<InvoiceModel> getRecentInvoices({int limit = 5}) {
    final sortedInvoices = List<InvoiceModel>.from(_invoices)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedInvoices.take(limit).toList();
  }

  // Search invoices
  List<InvoiceModel> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    final lowerQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
             (invoice.customerName?.toLowerCase().contains(lowerQuery) ?? false);
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
