import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/screens/add_customer_screen.dart';
import 'package:billing_app/screens/customer_details_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Design Colors
  static const Color backgroundColor = Color(0xFF050608);
  static const Color surfaceColor = Color(0x14181818);
  static const Color accentColor = Color(0xFF00C59E);
  static const Color borderColor = Color(0xFF12332D);
  static const Color textWhite = Colors.white;
  static const Color textGray = Colors.grey;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Customers",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.filter_list,
                    color: accentColor,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 2. Search Bar ---
              TextField(
                controller: _searchController,
                style: const TextStyle(color: textWhite),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceColor,
                  hintText: "Search customers...",
                  hintStyle: const TextStyle(color: textGray),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor.withOpacity(0.6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor.withOpacity(0.6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // --- 3. Customer List ---
              Expanded(
                child: StreamBuilder<List<CustomerModel>>(
                  stream: _firestoreService.streamCustomers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: accentColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final customers = snapshot.data ?? [];
                    final filteredCustomers = customers.where((c) {
                      return c.name.toLowerCase().contains(_searchQuery) ||
                          (c.phone?.toLowerCase().contains(_searchQuery) ?? false) ||
                          (c.email?.toLowerCase().contains(_searchQuery) ?? false);
                    }).toList();

                    if (customers.isEmpty) {
                      return _buildEmptyState();
                    }

                    if (filteredCustomers.isEmpty) {
                      return Center(
                        child: Text(
                          'No customers matching "$_searchQuery"',
                          style: const TextStyle(color: textGray),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return _buildCustomerCard(customer);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
      // --- Floating Action Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
        backgroundColor: accentColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Add Customer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerDetailsScreen(customer: customer),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      color: textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer.phone!,
                      style: const TextStyle(
                        color: textGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: textGray),
              color: const Color(0xFF1F1F1F),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editCustomer(customer);
                    break;
                  case 'view_history':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerDetailsScreen(customer: customer),
                      ),
                    );
                    break;
                  case 'delete':
                    _deleteCustomer(customer);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: accentColor, size: 20),
                      SizedBox(width: 12),
                      Text('Edit', style: TextStyle(color: textWhite)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_history',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: accentColor, size: 20),
                      SizedBox(width: 12),
                      Text('View History', style: TextStyle(color: textWhite)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editCustomer(CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(customer: customer),
      ),
    );
  }

  void _deleteCustomer(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Customer',
          style: TextStyle(color: textWhite),
        ),
        content: Text(
          'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
          style: const TextStyle(color: textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteCustomer(customer.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Customer deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor.withOpacity(0.6)),
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline,
                size: 48,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No customers yet",
            style: TextStyle(
              color: textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first customer to get started",
            style: TextStyle(
              color: textGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                "Add Customer",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


