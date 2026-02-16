import 'package:flutter/material.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

class AppDrawer extends StatelessWidget {
  final ShopSettings? shopSettings;
  final VoidCallback onSettingsTap;
  final VoidCallback onAboutTap;
  final Future<void> Function() onSignOut;

  const AppDrawer({
    super.key,
    required this.shopSettings,
    required this.onSettingsTap,
    required this.onAboutTap,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
          Theme.of(context).drawerTheme.backgroundColor ?? context.backgroundColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
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
                      color: context.accent.withValues(alpha: OpacityConstants.mediumHigh),
                      width: 2,
                    ),
                  ),
                  child: shopSettings != null
                      ? Icon(
                          IconData(shopSettings!.iconCodePoint,
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  shopSettings?.name ?? 'Billing App',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (shopSettings?.tagline != null &&
                    shopSettings!.tagline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    shopSettings!.tagline,
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    onSettingsTap();
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    onAboutTap();
                  },
                ),
              ],
            ),
          ),
          // Sign Out at Bottom
          Divider(
            color: context.accent.withValues(alpha: OpacityConstants.medium),
            thickness: 1,
            height: 1,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Sign Out',
            isDestructive: true,
            onTap: () async {
              Navigator.of(context).pop();
              onSignOut();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
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
              : context.accent.withValues(alpha: OpacityConstants.light),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: context.accent.withValues(alpha: OpacityConstants.veryLight),
    );
  }
}
