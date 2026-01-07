import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/providers/theme_provider.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _invoicePrefixController =
      TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _footerNoteController = TextEditingController();

  String _selectedShopType = 'Retail';
  int _selectedIconCodePoint = 0xe59c; // store icon
  bool _includeTaxInPrice = false;
  String _currency = 'INR';

  @override
  void initState() {
    super.initState();
    _loadShopSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _gstController.dispose();
    _taxRateController.dispose();
    _invoicePrefixController.dispose();
    _termsController.dispose();
    _footerNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadShopSettings() async {
    try {
      final userData = await _firestoreService.getUserData();
      if (userData?.shopSettings != null) {
        final settings = userData!.shopSettings!;
        setState(() {
          _nameController.text = settings.name;
          _taglineController.text = settings.tagline;
          _addressController.text = settings.address;
          _phoneController.text = settings.phone;
          _emailController.text = settings.email;
          _websiteController.text = settings.website;
          _gstController.text = settings.gstNumber;
          _taxRateController.text = settings.taxRate.toString();
          _invoicePrefixController.text = settings.invoicePrefix;
          _termsController.text = settings.termsAndConditions;
          _footerNoteController.text = settings.footerNote;
          _selectedShopType = settings.shopType;
          _selectedIconCodePoint = settings.iconCodePoint;
          _includeTaxInPrice = settings.includeTaxInPrice;
          _currency = settings.currency;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading shop settings: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final settings = ShopSettings(
        shopType: _selectedShopType,
        iconCodePoint: _selectedIconCodePoint,
        name: _nameController.text.trim(),
        tagline: _taglineController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        website: _websiteController.text.trim(),
        gstNumber: _gstController.text.trim(),
        currency: _currency,
        taxRate: double.parse(_taxRateController.text.trim()),
        invoicePrefix: _invoicePrefixController.text.trim(),
        includeTaxInPrice: _includeTaxInPrice,
        termsAndConditions: _termsController.text.trim(),
        footerNote: _footerNoteController.text.trim(),
      );

      await _firestoreService.updateShopSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully'),
            backgroundColor: context.accent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.accent,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: context.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.accent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Settings Section
                    _buildSectionTitle(context, 'Appearance'),
                    const SizedBox(height: 16),
                    _buildThemeSelector(context, themeProvider),
                    const SizedBox(height: 32),

                    _buildSectionTitle(context, 'Shop Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _nameController,
                      label: 'Shop Name',
                      icon: Icons.store,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter shop name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _taglineController,
                      label: 'Tagline',
                      icon: Icons.text_fields,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Business Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _gstController,
                      label: 'GST Number',
                      icon: Icons.numbers,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _taxRateController,
                      label: 'Tax Rate (%)',
                      icon: Icons.percent,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter tax rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calculate, color: context.accent),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Include Tax in Price',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Switch(
                            value: _includeTaxInPrice,
                            onChanged: (value) {
                              setState(() => _includeTaxInPrice = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Invoice Settings'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _invoicePrefixController,
                      label: 'Invoice Prefix',
                      icon: Icons.receipt,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter invoice prefix';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _termsController,
                      label: 'Terms & Conditions',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      controller: _footerNoteController,
                      label: 'Footer Note',
                      icon: Icons.note,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: context.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Theme Mode',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  icon: Icons.light_mode,
                  label: 'Light',
                  isSelected: themeProvider.isLightMode,
                  onTap: () => themeProvider.setLightMode(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  context,
                  icon: Icons.dark_mode,
                  label: 'Dark',
                  isSelected: themeProvider.isDarkMode,
                  onTap: () => themeProvider.setDarkMode(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  context,
                  icon: Icons.settings_suggest,
                  label: 'System',
                  isSelected: themeProvider.isSystemMode,
                  onTap: () => themeProvider.setSystemMode(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? context.accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? context.accent : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? context.accent : context.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? context.accent : context.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.accent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: context.textPrimary),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: context.accent),
      ),
    );
  }
}
