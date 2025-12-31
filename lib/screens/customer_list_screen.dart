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

  // Sort & Filter options
  String _sortBy = 'name_asc'; // name_asc, name_desc, date_new, date_old
  String _filterBy = 'all'; // all, recent_30, recent_60, recent_90

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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort & Filter',
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _sortBy = 'name_asc';
                            _filterBy = 'all';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(color: accentColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort Section
                  Text(
                    'Sort By',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildFilterOption(
                    title: 'Name (A-Z)',
                    value: 'name_asc',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                      setState(() => _sortBy = value!);
                    },
                  ),
                  _buildFilterOption(
                    title: 'Name (Z-A)',
                    value: 'name_desc',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                      setState(() => _sortBy = value!);
                    },
                  ),
                  _buildFilterOption(
                    title: 'Newest First',
                    value: 'date_new',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                      setState(() => _sortBy = value!);
                    },
                  ),
                  _buildFilterOption(
                    title: 'Oldest First',
                    value: 'date_old',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                      setState(() => _sortBy = value!);
                    },
                  ),

                  const SizedBox(height: 20),
                  Divider(color: borderColor),
                  const SizedBox(height: 20),

                  // Filter Section
                  Text(
                    'Filter By Activity',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterOption(
                    title: 'All Customers',
                    value: 'all',
                    groupValue: _filterBy,
                    onChanged: (value) {
                      setModalState(() => _filterBy = value!);
                      setState(() => _filterBy = value!);
                    },
                  ),
                  _buildFilterOption(
                    title: 'Active (Last 30 days)',
                    value: 'recent_30',
                    groupValue: _filterBy,
                    onChanged: (value) {
                      setModalState(() => _filterBy = value!);
                      setState(() => _filterBy = value!);
                    },
                  ),
                  _buildFilterOption(
                    title: 'Active (Last 60 days)',
                    value: 'recent_60',
                    groupValue: _filterBy,
                    onChanged: (value) {
                      setModalState(() => _filterBy = value!);
                      setState(() => _filterBy = value!);
                    },
                  ),
                  _buildFilterOption(
                    title: 'Active (Last 90 days)',
                    value: 'recent_90',
                    groupValue: _filterBy,
                    onChanged: (value) {
                      setModalState(() => _filterBy = value!);
                      setState(() => _filterBy = value!);
                    },
                  ),

                  SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? accentColor : borderColor.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? accentColor : textGray,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? accentColor : textWhite,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
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
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: accentColor,
                      size: 28,
                    ),
                    onPressed: () => _showFilterBottomSheet(),
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
                    borderSide:
                        BorderSide(color: borderColor.withValues(alpha: 0.6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: borderColor.withValues(alpha: 0.6)),
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

                    // Apply search filter
                    var filteredCustomers = customers.where((c) {
                      return c.name.toLowerCase().contains(_searchQuery) ||
                          (c.phone?.toLowerCase().contains(_searchQuery) ??
                              false) ||
                          (c.email?.toLowerCase().contains(_searchQuery) ??
                              false);
                    }).toList();

                    // Apply date filter
                    if (_filterBy != 'all') {
                      final now = DateTime.now();
                      int daysAgo = 30;
                      if (_filterBy == 'recent_60') daysAgo = 60;
                      if (_filterBy == 'recent_90') daysAgo = 90;

                      final filterDate = now.subtract(Duration(days: daysAgo));
                      filteredCustomers = filteredCustomers.where((c) {
                        return c.updatedAt.isAfter(filterDate);
                      }).toList();
                    }

                    // Apply sorting
                    filteredCustomers.sort((a, b) {
                      switch (_sortBy) {
                        case 'name_asc':
                          return a.name
                              .toLowerCase()
                              .compareTo(b.name.toLowerCase());
                        case 'name_desc':
                          return b.name
                              .toLowerCase()
                              .compareTo(a.name.toLowerCase());
                        case 'date_new':
                          return b.createdAt.compareTo(a.createdAt);
                        case 'date_old':
                          return a.createdAt.compareTo(b.createdAt);
                        default:
                          return 0;
                      }
                    });

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
          border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
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
                        builder: (_) =>
                            CustomerDetailsScreen(customer: customer),
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
                      const Icon(Icons.edit, color: accentColor, size: 20),
                      const SizedBox(width: 12),
                      Text('Edit', style: TextStyle(color: textWhite)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_history',
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: accentColor, size: 20),
                      const SizedBox(width: 12),
                      Text('View History', style: TextStyle(color: textWhite)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
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
                    const SnackBar(
                        content: Text('Customer deleted successfully')),
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
              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
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
