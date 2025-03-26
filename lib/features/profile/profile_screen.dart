import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Navigate to edit profile
              context.go('/edit-profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileMenus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray300, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.gray500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            'John Doe',
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 4),

          // User Email
          Text(
            'john.doe@example.com',
            style: TextStyles.body2.copyWith(color: AppColors.textMuted),
          ),

          const SizedBox(height: 16),

          // Membership Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: AppColors.primaryBlack,
                ),
                const SizedBox(width: 4),
                Text(
                  'Premium Member',
                  style:
                      TextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenus(BuildContext context) {
    return Column(
      children: [
        _buildMenuSection(
          title: 'Products',
          items: [
            ProfileMenuItem(
              icon: Icons.add,
              title: 'Create Product',
              onTap: () => context.go('/create-product'),
            ),
            // You can add more product related options here if needed.
          ],
        ),
        _buildMenuSection(
          title: 'Account',
          items: [
            ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () => context.go('/orders'),
            ),
            ProfileMenuItem(
              icon: Icons.card_giftcard_outlined,
              title: 'My Rewards',
              onTap: () => context.go('/rewards'),
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Shipping Addresses',
              onTap: () => context.go('/addresses'),
            ),
            ProfileMenuItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              onTap: () => context.go('/payment-methods'),
            ),
          ],
        ),

        _buildMenuSection(
          title: 'Preferences',
          items: [
            ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.go('/notifications-settings'),
            ),
            ProfileMenuItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              onTap: () => context.go('/language-settings'),
            ),
            ProfileMenuItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // Toggle theme
                },
              ),
            ),
          ],
        ),

        _buildMenuSection(
          title: 'Support',
          items: [
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () => context.go('/help'),
            ),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () => context.go('/about'),
            ),
            ProfileMenuItem(
              icon: Icons.policy_outlined,
              title: 'Privacy Policy',
              onTap: () => context.go('/privacy'),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () {
              // Logout functionality
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ),

        // App version
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            'Version 1.0.0',
            style: TextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.gray300,
              indent: 56,
            ),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.gray700,
      ),
      title: Text(
        title,
        style: TextStyles.body1,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyles.caption.copyWith(color: AppColors.textMuted),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.gray500,
          ),
      onTap: onTap,
    );
  }
}
