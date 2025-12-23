import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool isTrackInventory = true;
  String selectedUnit = 'pcs';
  bool _isLoading = false;

  final _firestoreService = FirestoreService();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _lowStockAlertCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();

  // --- Design Colors ---
  final Color backgroundColor = const Color(0xFF050608);
  final Color surfaceColor = const Color(0x14181818);
  final Color accentColor = const Color(0xFF00C59E);
  final Color borderColor = const Color(0xFF12332D);
  final Color textWhite = Colors.white;
  final Color textGray = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameCtrl.text = product.name;
    _descriptionCtrl.text = product.description ?? '';
    _categoryCtrl.text = product.category ?? '';
    _sellingPriceCtrl.text = product.sellingPrice.toString();
    _costPriceCtrl.text = product.costPrice?.toString() ?? '';
    _stockCtrl.text = product.currentStock.toString();
    _lowStockAlertCtrl.text = product.lowStockAlert?.toString() ?? '';
    _skuCtrl.text = product.sku ?? '';
    _barcodeCtrl.text = product.barcode ?? '';
    isTrackInventory = product.trackInventory;
    selectedUnit = product.unit;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _categoryCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _stockCtrl.dispose();
    _lowStockAlertCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    // Validate required fields
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }
    if (_sellingPriceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter selling price')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.product != null) {
        // Update existing product
        final updatedProduct = ProductModel(
          id: widget.product!.id,
          name: _nameCtrl.text.trim(),
          description: _descriptionCtrl.text.trim().isEmpty
              ? null
              : _descriptionCtrl.text.trim(),
          category: _categoryCtrl.text.trim().isEmpty
              ? null
              : _categoryCtrl.text.trim(),
          sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0,
          costPrice: _costPriceCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_costPriceCtrl.text),
          trackInventory: isTrackInventory,
          currentStock: int.tryParse(_stockCtrl.text) ?? 0,
          unit: selectedUnit,
          lowStockAlert: _lowStockAlertCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_lowStockAlertCtrl.text),
          sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
          barcode: _barcodeCtrl.text.trim().isEmpty
              ? null
              : _barcodeCtrl.text.trim(),
          createdAt: widget.product!.createdAt,
          updatedAt: DateTime.now(),
        );

        await _firestoreService.updateProduct(updatedProduct);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        // Add new product
        final product = ProductModel(
          name: _nameCtrl.text.trim(),
          description: _descriptionCtrl.text.trim().isEmpty
              ? null
              : _descriptionCtrl.text.trim(),
          category: _categoryCtrl.text.trim().isEmpty
              ? null
              : _categoryCtrl.text.trim(),
          sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0,
          costPrice: _costPriceCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_costPriceCtrl.text),
          trackInventory: isTrackInventory,
          currentStock: int.tryParse(_stockCtrl.text) ?? 0,
          unit: selectedUnit,
          lowStockAlert: _lowStockAlertCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_lowStockAlertCtrl.text),
          sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
          barcode: _barcodeCtrl.text.trim().isEmpty
              ? null
              : _barcodeCtrl.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.addProduct(product);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product != null ? "Edit Product" : "Add Product",
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Basic Information ---
            _buildSectionHeader("Basic Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameCtrl,
              icon: Icons.inventory_2,
              hint: "Product Name *",
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionCtrl,
              icon: Icons.description, 
              hint: "Description", 
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildSelectorField(
              icon: Icons.category,
              hint: _categoryCtrl.text.isEmpty ? "Select Category" : _categoryCtrl.text,
              label: "Category",
              onTap: _showCategoryPicker,
              showDropdownIcon: true,
            ),
            const SizedBox(height: 30),

            // --- 2. Pricing ---
            _buildSectionHeader("Pricing"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _sellingPriceCtrl,
                    icon: Icons.attach_money, 
                    hint: "Selling Price *",
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _costPriceCtrl,
                    icon: Icons.money_off, 
                    hint: "Cost Price",
                    inputType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- 3. Inventory ---
            _buildSectionHeader("Inventory"),
            const SizedBox(height: 16),
            _buildToggleTile(
              title: "Track Inventory",
              subtitle: "Monitor stock levels",
              icon: Icons.inventory,
              value: isTrackInventory,
              onChanged: (val) => setState(() => isTrackInventory = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _stockCtrl,
                    icon: Icons.numbers, 
                    hint: "0",
                    label: "Current Stock",
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectorField(
                    hint: selectedUnit,
                    label: "Unit",
                    showDropdownIcon: true,
                    onTap: () => _showUnitPicker(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lowStockAlertCtrl,
              icon: Icons.warning_amber, 
              hint: "Low Stock Alert",
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 30),

            // --- 4. Identification (Optional) ---
            _buildSectionHeader("Identification (Optional)"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _skuCtrl,
                    icon: Icons.qr_code,
                    hint: "SKU",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _barcodeCtrl,
                    icon: Icons.barcode_reader,
                    hint: "Barcode",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- 5. Save Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: accentColor.withOpacity(0.4),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.black),
                label: Text(
                  _isLoading 
                      ? "Saving..." 
                      : (widget.product != null ? "Update Product" : "Save Product"),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() async {
    try {
      final categories = await _firestoreService.getCategories();
      
      if (!mounted) return;
      
      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No categories available. Add categories from Products screen.'),
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _categoryCtrl.text == category;
                    return ListTile(
                      title: Text(
                        category,
                        style: TextStyle(color: textWhite),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: accentColor)
                          : null,
                      onTap: () {
                        setState(() => _categoryCtrl.text = category);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.clear, color: Colors.red),
                title: Text('Clear Selection', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _categoryCtrl.text = '');
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  void _showUnitPicker() {
    final units = ['pcs', 'kg', 'g', 'l', 'ml', 'box', 'pack', 'dozen', 'm', 'cm'];
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: units.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                units[index],
                style: TextStyle(color: textWhite),
              ),
              trailing: selectedUnit == units[index]
                  ? Icon(Icons.check, color: accentColor)
                  : null,
              onTap: () {
                setState(() => selectedUnit = units[index]);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // --- Helper: Section Header with Vertical Bar ---
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 4,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- Helper: Standard Text Field ---
  Widget _buildTextField({
    TextEditingController? controller,
    required IconData icon,
    required String hint,
    String? label,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: TextStyle(color: textGray, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor.withOpacity(0.6)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: textWhite),
            keyboardType: inputType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textGray),
              prefixIcon: Icon(icon, color: textGray),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper: Selector Field (like Dropdown) ---
  Widget _buildSelectorField({
    IconData? icon,
    required String hint,
    String? label,
    required VoidCallback onTap,
    bool showDropdownIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: TextStyle(color: textGray, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borderColor.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textGray),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(color: textWhite),
                  ),
                ),
                Icon(
                  showDropdownIcon ? Icons.arrow_drop_down : Icons.arrow_forward_ios,
                  color: textGray,
                  size: showDropdownIcon ? 24 : 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper: Toggle Switch Tile ---
  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor.withOpacity(0.6)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        secondary: Icon(icon, color: textGray),
        title: Text(title, style: TextStyle(color: textWhite, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: textGray)),
      ),
    );
  }
}