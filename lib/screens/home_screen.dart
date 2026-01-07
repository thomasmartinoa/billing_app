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
import 'package:intl/intl.dart';

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

      // Calculate notifications
      final lowStockCount = products.where((p) => p.isLowStock).length;
      final unpaidInvoicesCount =
          invoices.where((inv) => inv.status == InvoiceStatus.pending).length;

      if (mounted) {
        setState(() {
          _stats = stats;
          _shopSettings = userData?.shopSettings;
          _recentInvoices = invoices.take(5).toList(); // Get latest 5 invoices
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

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ProductListScreen();
      case 2:
        return const BillingScreen();
      case 3:
        return const CustomerListScreen();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If not on dashboard, go to dashboard
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }

        // If on dashboard, show exit confirmation
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
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
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
        drawer: _buildDrawer(),
        body: _buildCurrentScreen(),
        floatingActionButton: _selectedIndex == 0 || _selectedIndex == 2
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
                  ).then((_) => _loadStats());
                },
                backgroundColor: context.accent,
                label: Text("New Invoice",
                    style: TextStyle(
                        color: context.textPrimary, fontWeight: FontWeight.bold)),
                icon: Icon(Icons.add, color: context.textPrimary),
              )
            : null,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: context.textPrimary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.grid_view_rounded,
                    label: "Dashboard",
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.inventory_2_rounded,
                    label: "Products",
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.receipt_long_rounded,
                    label: "Invoices",
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.people_rounded,
                    label: "Customers",
                    index: 3,
                  ),
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
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? context.accent : context.textSecondary.withValues(alpha: 0.6),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? context.accent : context.textSecondary.withValues(alpha: 0.6),
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
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: context.accent),
            const SizedBox(width: 12),
            Text(
              'Exit App',
              style:
                  TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold),
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Exit',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor ?? context.backgroundColor,
      child: Column(
        children: [
          // Drawer Header - Dark Theme
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: context.surfaceColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.accent.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: _shopSettings != null
                      ? Icon(
                          IconData(_shopSettings!.iconCodePoint,
                              fontFamily: 'MaterialIcons'),
                          color: context.accent,
                          size: 35,
                        )
                      : Icon(
                          Icons.store,
                          color: context.accent,
                          size: 35,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  _shopSettings?.name ?? 'Billing App',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_shopSettings?.tagline != null &&
                    _shopSettings!.tagline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _shopSettings!.tagline,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen()),
                    ).then((_) => _loadStats());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AboutScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Sign Out at Bottom
          Divider(
            color: context.accent.withValues(alpha: 0.2),
            thickness: 1,
            height: 1,
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Sign Out',
            isDestructive: true,
            onTap: () async {
              // Close drawer first
              Navigator.of(context).pop();

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(color: context.accent),
                ),
              );

              try {
                await _authService.signOut();
                // Pop loading dialog
                if (mounted) Navigator.of(context).pop();
                // The AuthWrapper will automatically navigate to WelcomePage
              } catch (e) {
                // Pop loading dialog
                if (mounted) Navigator.of(context).pop();
                // Show error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? context.errorBackground
              : context.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          color: isDestructive ? context.errorColor : context.accent,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? context.errorColor : context.textPrimary,
          fontSize: AppFontSize.xl,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: context.accent.withValues(alpha: 0.05),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadStats,
        color: context.accent,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SHOP HEADER
              if (_shopSettings != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: context.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: context.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _shopSettings != null
                            ? Icon(
                                IconData(_shopSettings!.iconCodePoint,
                                    fontFamily: 'MaterialIcons'),
                                color: context.accent,
                                size: 32,
                              )
                            : Icon(
                                Icons.store,
                                color: context.accent,
                                size: 32,
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _shopSettings!.name,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_shopSettings!.tagline.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                _shopSettings!.tagline,
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (_shopSettings!.phone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 12, color: context.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    _shopSettings!.phone,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // TOP CARDS
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.people,
                      value: "${_stats['customers']}",
                      title: "Customers",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.inventory_2_outlined,
                      value: "${_stats['products']}",
                      title: "Products",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.shopping_cart,
                      value: "${_stats['sales']}",
                      title: "Sales",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.warning_amber_rounded,
                      value: "${_stats['lowStock']}",
                      title: "Low Stock",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text(
                "Quick Actions",
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                      child: QuickButton(
                    icon: Icons.shopping_cart,
                    title: "New Invoice",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreateInvoiceScreen()),
                      ).then((_) => _loadStats());
                    },
                  )),
                  SizedBox(width: 12),
                  Expanded(
                      child: QuickButton(
                    icon: Icons.add_box,
                    title: "Add Product",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddProductScreen()),
                      ).then((_) => _loadStats());
                    },
                  )),
                  SizedBox(width: 12),
                  Expanded(
                      child: QuickButton(
                    icon: Icons.person_add,
                    title: "Add Customer",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddCustomerScreen()),
                      ).then((_) => _loadStats());
                    },
                  )),
                ],
              ),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Invoices",
                    style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => _onNavTap(2),
                    child: Text(
                      "View All",
                      style: TextStyle(color: context.accent),
                    ),
                  )
                ],
              ),

              SizedBox(height: 12),

              _recentInvoices.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                context.accent.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long,
                              color: context.textSecondary.withValues(alpha: 0.4), size: 45),
                          const SizedBox(height: 10),
                          Text("No invoices yet",
                              style: TextStyle(color: context.textSecondary)),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CreateInvoiceScreen()),
                              ).then((_) => _loadStats());
                            },
                            icon:
                                Icon(Icons.add, color: context.accent),
                            label: Text("Create First Invoice",
                                style: TextStyle(color: context.accent)),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _recentInvoices.map((invoice) {
                        return _buildInvoiceCard(invoice);
                      }).toList(),
                    ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final isPaid = invoice.status == InvoiceStatus.paid;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceReceiptScreen(invoice: invoice),
          ),
        ).then((_) => _loadStats());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: context.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isPaid
                    ? context.successBackground
                    : context.warningBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? context.successColor : context.warningColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    invoice.customerName ?? 'Walk-in Customer',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    dateFormat.format(invoice.createdAt),
                    style: TextStyle(
                      color: context.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${invoice.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? context.successBackground
                        : context.warningBackground,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Pending',
                    style: TextStyle(
                      color: isPaid ? context.successColor : context.warningColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- WIDGETS -----------------------

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  DashboardCard({required this.icon, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: context.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: context.accent),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(color: context.textSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class QuickButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: context.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.accent, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
