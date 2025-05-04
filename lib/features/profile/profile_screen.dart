// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data after the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<UserProvider>(context, listen: false)
            .fetchUserData(authProvider.user!.id);
      }
    });
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildProfileMenus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userProvider = Provider.of<UserProvider>(context);
    Provider.of<AuthProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.indigo.shade50],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildProfileAvatar(),
          const SizedBox(height: 16),
          _buildProfileInfo(userProvider),
          const SizedBox(height: 24),
          _buildProfileActions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.indigo.shade100,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Center(
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.indigo.shade300,
              ),
            ),
          ),
        ),
        
      ],
    );
  }

  Widget _buildProfileInfo(UserProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null || provider.user == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 30),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Could not load profile',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                provider.invalidateCache();
                provider.fetchUserData(authProvider.user!.id);
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final user = provider.user!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            user.fullName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (user.phoneNumber != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  user.phoneNumber!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // _buildActionButton(
        //   icon: Icons.edit_outlined,
        //   label: AppLocalizations.of(context)!.editProfile,
        //   onPressed: () {
        //     HapticFeedback.lightImpact();
        //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
        //     context.push('/edit-profile').then((_) {
        //       // Invalidate cache and fetch fresh data when returning
        //       final userProvider = Provider.of<UserProvider>(context, listen: false);
        //       userProvider.invalidateCache();
        //       userProvider.fetchUserData(authProvider.user!.id);
        //     });
        //   },
        // ),
        // const SizedBox(width: 16),
        // _buildActionButton(
        //   icon: Icons.favorite_outline,
        //   label: AppLocalizations.of(context)!.wishlist,
        //   onPressed: () {
        //     HapticFeedback.lightImpact();
        //     context.push('/favorites');
        //   },
        // ),
      ],
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
          
          ],
        ),
        _buildMenuSection(
          title: AppLocalizations.of(context)!.preferences,
          icon: Icons.settings_outlined,
          items: [
           
            ProfileMenuItem(
              icon: Icons.language_outlined,
              title: AppLocalizations.of(context)!.language,
              subtitle: Provider.of<LanguageProvider>(context).currentLanguage,
              onTap: () => context.push('/language-settings'),
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
            ProfileMenuItem(
              icon: Icons.delete_forever_outlined,
              title: AppLocalizations.of(context)!.deleteAccount,
              onTap: () {
                HapticFeedback.mediumImpact();
                //navigate to account deletion screen
                context.push('/delete-account');
              },
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
                  title: Text(AppLocalizations.of(context)!.signOut),
                  content:
                      Text(AppLocalizations.of(context)!.signOutConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
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
                              SnackBar(
                                content: Text('Signed Out'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${'Signed Out Failed'}: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.signOut),
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
            child: Text(
              AppLocalizations.of(context)!.signOut.toUpperCase(),
              style: const TextStyle(
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
                color: Colors.black.withValues(alpha: .04),
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
