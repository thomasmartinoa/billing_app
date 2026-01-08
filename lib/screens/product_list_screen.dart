import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/product_model.dart';
import 'package:billing_app/screens/add_product_screen.dart';
import 'package:billing_app/screens/product_details_screen.dart';
import 'package:billing_app/screens/manage_categories_dialog.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory; // null means "All"

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header (Title + Icon) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Products",
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.category,
                      color: context.accent,
                      size: 28,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ManageCategoriesDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 2. Search Bar ---
              TextField(
                controller: _searchController,
                style: TextStyle(color: context.textPrimary),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.surfaceColor,
                  hintText: "Search products...",
                  hintStyle: TextStyle(color: context.textSecondary),
                  prefixIcon: Icon(Icons.search, color: context.accent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: context.borderColor.withValues(alpha: 0.6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: context.borderColor.withValues(alpha: 0.6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.accent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // --- 3. Category Filter Chips ---
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.streamCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];

                  return SizedBox(
                    height: 45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // "All" chip
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            labelStyle: TextStyle(
                              color: _selectedCategory == null
                                  ? context.textPrimary
                                  : context.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            selected: _selectedCategory == null,
                            selectedColor: context.accent,
                            backgroundColor: context.surfaceColor,
                            checkmarkColor: context.textPrimary,
                            side: BorderSide(
                              color: _selectedCategory == null
                                  ? context.accent
                                  : context.borderColor,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                        ),
                        // Category chips
                        ...categories.map((category) {
                          final categoryName = category['name'] as String;
                          final isSelected = _selectedCategory == categoryName;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(categoryName),
                              labelStyle: TextStyle(
                                color: isSelected ? context.textPrimary : context.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              selected: isSelected,
                              selectedColor: context.accent,
                              backgroundColor: context.surfaceColor,
                              checkmarkColor: context.textPrimary,
                              side: BorderSide(
                                color: isSelected ? context.accent : context.borderColor,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? categoryName : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // --- 4. Product List ---
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: _firestoreService.streamProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: context.accent),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: context.errorColor),
                        ),
                      );
                    }

                    final products = snapshot.data ?? [];
                    final filteredProducts = products.where((p) {
                      // Filter by search query
                      final matchesSearch =
                          p.name.toLowerCase().contains(_searchQuery) ||
                              (p.description
                                      ?.toLowerCase()
                                      .contains(_searchQuery) ??
                                  false);

                      // Filter by category
                      final matchesCategory = _selectedCategory == null ||
                          p.category == _selectedCategory;

                      return matchesSearch && matchesCategory;
                    }).toList();

                    if (products.isEmpty) {
                      return _buildEmptyState();
                    }

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products matching "$_searchQuery"',
                          style: TextStyle(color: context.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // --- 5. Floating Action Button (Bottom Right) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        backgroundColor: context.accent,
        icon: Icon(Icons.add, color: context.textPrimary),
        label: Text(
          'Add Product',
          style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: context.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.sellingPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock: ${product.currentStock}',
                  style: TextStyle(
                    color: product.isLowStock ? context.warningColor : context.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (product.isLowStock)
                  Text(
                    'Low Stock!',
                    style: TextStyle(
                      color: context.warningColor,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: context.textSecondary),
              color: context.surfaceColor,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editProduct(product);
                    break;
                  case 'update_stock':
                    _showUpdateStockDialog(product);
                    break;
                  case 'delete':
                    _deleteProduct(product);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: context.accent, size: 20),
                      const SizedBox(width: 12),
                      Text('Edit', style: TextStyle(color: context.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'update_stock',
                  child: Row(
                    children: [
                      Icon(Icons.inventory, color: context.accent, size: 20),
                      const SizedBox(width: 12),
                      Text('Update Stock', style: TextStyle(color: context.textPrimary)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: _DeleteMenuItem(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(product: product),
      ),
    );
  }

  void _showUpdateStockDialog(ProductModel product) {
    final stockController = TextEditingController(
      text: product.currentStock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text(
              'Update Stock - ${product.name}',
              style: TextStyle(color: context.textPrimary, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${product.currentStock} ${product.unit}',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Quantity',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: context.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: context.textPrimary, fontSize: 18),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(color: context.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid quantity')),
                );
                return;
              }

              try {
                await _firestoreService.updateProductStock(
                  product.id!,
                  newStock,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stock updated successfully')),
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
              backgroundColor: context.accent,
              foregroundColor: context.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Product',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteProduct(product.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Product deleted successfully')),
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
              backgroundColor: context.errorColor,
              foregroundColor: context.textPrimary,
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
              color: context.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor.withValues(alpha: 0.6)),
            ),
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: context.accent,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No products yet",
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first product to get started",
            style: TextStyle(
              color: context.textSecondary,
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
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              icon: Icon(Icons.add, color: context.textPrimary),
              label: Text(
                "Add Product",
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
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
// Helper widget for delete menu item to avoid const issues
class _DeleteMenuItem extends StatelessWidget {
  const _DeleteMenuItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.delete, color: context.errorColor, size: 20),
        const SizedBox(width: 12),
        Text('Delete', style: TextStyle(color: context.errorColor)),
      ],
    );
  }
}
