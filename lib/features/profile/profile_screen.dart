// File: lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/edit-profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(authProvider.user!.id),
            const SizedBox(height: 16),
            _buildProfileMenus(context),
          ],
        ),
      ),
    );
  }

  // Updated _buildProfileHeader uses FutureBuilder to fetch user's full_name and email.
  Widget _buildProfileHeader(String userId) {
    return FutureBuilder<UserModel>(
      future: UserService().getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(child: Text('Error loading profile')),
          );
        }
        // final user = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                snapshot.data?.fullName ?? 'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.data?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenus(BuildContext context) {
    return Column(
      children: [
        _buildMenuSection(
          title: AppLocalizations.of(context)!.account,
          icon: Icons.account_circle_outlined,
          items: [
            ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: AppLocalizations.of(context)!.myOrders,
              onTap: () => context.push('/orders'),
            ),
            ProfileMenuItem(
              icon: Icons.card_giftcard_outlined,
              title: AppLocalizations.of(context)!.myRewards,
              badge: '3',
              onTap: () => context.push('/rewards'),
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context)!.shippingAddresses,
              onTap: () => context.push('/addresses'),
            ),
            ProfileMenuItem(
              icon: Icons.credit_card_outlined,
              title: AppLocalizations.of(context)!.paymentMethods,
              onTap: () => context.push('/payment-methods'),
            ),
          ],
        ),
        _buildMenuSection(
          title: AppLocalizations.of(context)!.preferences,
          icon: Icons.settings_outlined,
          items: [
            ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: AppLocalizations.of(context)!.notifications,
              onTap: () => context.push('/notifications-settings'),
            ),
            ProfileMenuItem(
              icon: Icons.language_outlined,
              title: AppLocalizations.of(context)!.language,
              subtitle: Provider.of<LanguageProvider>(context).currentLanguage,
              onTap: () => context.push('/language-settings'),
            ),
            ProfileMenuItem(
              icon: Icons.dark_mode_outlined,
              title: AppLocalizations.of(context)!.darkMode,
              trailing: Switch(
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                activeColor: Colors.indigo.shade700,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
            ),
          ],
        ),
        _buildMenuSection(
          title: AppLocalizations.of(context)!.support,
          icon: Icons.help_outline,
          items: [
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: AppLocalizations.of(context)!.helpCenter,
              onTap: () => context.push('/help'),
            ),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: AppLocalizations.of(context)!.aboutUs,
              onTap: () => context.push('/about'),
            ),
            ProfileMenuItem(
              icon: Icons.policy_outlined,
              title: AppLocalizations.of(context)!.privacyPolicy,
              onTap: () => context.push('/privacy'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.signOut(context);
                          if (context.mounted) {
                            context.go('/');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You have been signed out'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Sign out failed: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('SIGN OUT'),
                    )
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: const Text(
              'SIGN OUT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<ProfileMenuItem> items,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.indigo.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.shade200,
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
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.indigo.shade700,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
