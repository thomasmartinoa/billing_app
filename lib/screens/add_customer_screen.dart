import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/customer_model.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;
  
  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // --- Design Colors from Image ---
  static const Color backgroundColor = Color(0xFF050608);
  static const Color surfaceColor = Color(0x14181818);
  static const Color accentColor = Color(0xFF00C59E);
  static const Color borderColor = Color(0xFF12332D);
  static const Color textWhite = Colors.white;
  static const Color textGray = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _loadCustomerData();
    }
  }

  void _loadCustomerData() {
    final customer = widget.customer!;
    _nameCtrl.text = customer.name;
    _phoneCtrl.text = customer.phone ?? '';
    _emailCtrl.text = customer.email ?? '';
    _addressCtrl.text = customer.address ?? '';
    _gstCtrl.text = customer.gstNumber ?? '';
    _notesCtrl.text = customer.notes ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _gstCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.customer != null) {
        // Update existing customer
        final updatedCustomer = CustomerModel(
          id: widget.customer!.id,
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
          gstNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          createdAt: widget.customer!.createdAt,
          updatedAt: DateTime.now(),
        );

        await _firestoreService.updateCustomer(updatedCustomer);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer updated successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        // Add new customer
        final customer = CustomerModel(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
          gstNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.addCustomer(customer);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding customer: $e')),
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
          icon: const Icon(Icons.arrow_back, color: accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customer != null ? "Edit Customer" : "Add Customer",
          style: const TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Top Glowing Icon ---
            Center(
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person_add, color: accentColor, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- 2. Contact Information Section ---
            _buildSectionHeader(accentColor, "Contact Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameCtrl,
              icon: Icons.person,
              hint: "Customer Name *",
              isMandatory: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneCtrl,
              icon: Icons.phone,
              hint: "Phone Number",
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailCtrl,
              icon: Icons.email,
              hint: "Email Address",
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),

            // --- 3. Address Section ---
            _buildSectionHeader(accentColor, "Address"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressCtrl,
              icon: Icons.location_on,
              hint: "Address",
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            // --- 4. Business Information Section ---
            _buildSectionHeader(accentColor, "Business Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _gstCtrl,
              icon: Icons.receipt,
              hint: "GST Number",
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesCtrl,
              icon: Icons.note,
              hint: "Notes",
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // --- 5. Bottom Add Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveCustomer,
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
                    : const Icon(Icons.person_add, color: Colors.black),
                label: Text(
                  _isLoading 
                      ? "Saving..." 
                      : (widget.customer != null ? "Update Customer" : "Add Customer"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Section Header with Vertical Bar ---
  Widget _buildSectionHeader(Color accentColor, String title) {
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

  // --- Helper Widget: Custom Text Field ---
  Widget _buildTextField({
    TextEditingController? controller,
    required IconData icon,
    required String hint,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool isMandatory = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor.withOpacity(0.6)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textGray),
          prefixIcon: Icon(icon, color: textGray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: accentColor, width: 2),
          ),
        ),
      ),
    );
  }
}

