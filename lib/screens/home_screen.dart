import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/services/auth_service.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/screens/product_list_screen.dart';
import 'package:billing_app/screens/add_product_screen.dart';
import 'package:billing_app/screens/customer_list_screen.dart';
import 'package:billing_app/screens/add_customer_screen.dart';
import 'package:billing_app/screens/billing_screen.dart';
import 'package:billing_app/screens/create_invoice_screen.dart';
import 'package:billing_app/screens/invoice_receipt_screen.dart';
import 'package:billing_app/screens/settings_screen.dart';
import 'package:billing_app/screens/about_screen.dart';
import 'package:billing_app/screens/notifications_screen.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';
import 'package:billing_app/utils/error_handler.dart';
import 'package:billing_app/widgets/app_drawer.dart';
import 'package:billing_app/widgets/dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  Map<String, dynamic> _stats = {
    'customers': 0,
    'products': 0,
    'sales': 0,
    'lowStock': 0,
  };

  ShopSettings? _shopSettings;
  List<InvoiceModel> _recentInvoices = [];
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _firestoreService.getDashboardStats();
      final userData = await _firestoreService.getUserData();
      final invoices = await _firestoreService.getInvoices();
      final products = await _firestoreService.getProducts();

      final lowStockCount = products.where((p) => p.isLowStock).length;
      final unpaidInvoicesCount =
          invoices.where((inv) => inv.status == InvoiceStatus.pending).length;

      if (mounted) {
        setState(() {
          _stats = stats;
          _shopSettings = userData?.shopSettings;
          _recentInvoices = invoices.take(5).toList();
          _notificationCount = lowStockCount + unpaidInvoicesCount;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _navigateToCreateInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
    ).then((_) => _loadStats());
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return DashboardView(
          stats: _stats,
          shopSettings: _shopSettings,
          recentInvoices: _recentInvoices,
          onNewInvoice: _navigateToCreateInvoice,
          onAddProduct: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            ).then((_) => _loadStats());
          },
          onAddCustomer: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
            ).then((_) => _loadStats());
          },
          onViewAllInvoices: () => _onNavTap(2),
          onInvoiceTap: (invoice) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InvoiceReceiptScreen(invoice: invoice),
              ),
            ).then((_) => _loadStats());
          },
          onRefresh: _loadStats,
        );
      case 1:
        return const ProductListScreen();
      case 2:
        return const BillingScreen();
      case 3:
        return const CustomerListScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }

        final shouldExit = await _showExitDialog();
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: context.accent),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none,
                            color: context.accent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => NotificationsScreen()),
                          ).then((_) => _loadStats());
                        },
                      ),
                      if (_notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _notificationCount > 99
                                  ? '99+'
                                  : _notificationCount.toString(),
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              )
            : null,
        drawer: AppDrawer(
          shopSettings: _shopSettings,
          onSettingsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ).then((_) => _loadStats());
          },
          onAboutTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen()),
            );
          },
          onSignOut: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: CircularProgressIndicator(color: context.accent),
              ),
            );

            try {
              await _authService.signOut();
              if (mounted) Navigator.of(context).pop();
            } catch (e) {
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ErrorHandler.handleFirebaseError(e))),
                );
              }
            }
          },
        ),
        body: _buildCurrentScreen(),
        floatingActionButton: _selectedIndex == 0 || _selectedIndex == 2
            ? FloatingActionButton.extended(
                onPressed: _navigateToCreateInvoice,
                backgroundColor: context.accent,
                label: Text("New Invoice",
                    style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold)),
                icon: Icon(Icons.add, color: context.textPrimary),
              )
            : null,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: context.textPrimary.withValues(alpha: OpacityConstants.light),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.grid_view_rounded, label: "Dashboard", index: 0),
                  _buildNavItem(icon: Icons.inventory_2_rounded, label: "Products", index: 1),
                  _buildNavItem(icon: Icons.receipt_long_rounded, label: "Invoices", index: 2),
                  _buildNavItem(icon: Icons.people_rounded, label: "Customers", index: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? context.accent
                  : context.textSecondary.withValues(alpha: 0.6),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.accent
                    : context.textSecondary.withValues(alpha: 0.6),
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: context.accent),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Exit App',
              style: TextStyle(
                  color: context.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to exit the application?',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: Text(
              'Exit',
              style: TextStyle(
                  color: context.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
