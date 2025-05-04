// lib/features/help/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final primaryColor = Colors.indigo.shade700;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the profile route
            context.go('/profile');
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: localizations.searchHelp,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onSubmitted: (value) {
                  // Handle search
                  if (value.isEmpty) {
                    setState(() {
                      _isSearching = false;
                    });
                  }
                },
              )
            : Text(
                localizations.helpCenter,
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
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportHeader(primaryColor),
            const SizedBox(height: 24),
            _buildFaqCategories(context),
            _buildContactSection(context, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader(Color primaryColor) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.howCanWeHelp,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.helpCenterDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('https://t.me/anexon_iv');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch Telegram'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_outlined, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    localizations.chatWithSupport,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCategories(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            localizations.frequentlyAskedQuestions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildFaqCategory(
          context,
          icon: Icons.shopping_bag_outlined,
          title: localizations.orders,
          items: [
            localizations.trackOrder,
            localizations.cancelOrder,
            localizations.returnRefund,
            localizations.deliveryIssues,
          ],
        ),
        _buildFaqCategory(
          context,
          icon: Icons.account_circle_outlined,
          title: localizations.account,
          items: [
            localizations.accountSettings,
            localizations.loginIssues,
            localizations.dataPrivacy,
          ],
        ),
        _buildFaqCategory(
          context,
          icon: Icons.credit_card_outlined,
          title: localizations.payments,
          items: [
            localizations.paymentMethods,
            localizations.paymentFailures,
            localizations.refundProcess,
          ],
        ),
        _buildFaqCategory(
          context,
          icon: Icons.inventory_2_outlined,
          title: localizations.products,
          items: [
            localizations.productDetails,
            localizations.availability,
            localizations.warranties,
            localizations.reportIssue,
          ],
        ),
      ],
    );
  }

  Widget _buildFaqCategory(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
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
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: items.map((item) => _buildFaqItem(item)).toList(),
      ),
    );
  }

// Add this map at the top of your _HelpCenterScreenState class:
final Map<String, String> faqAnswers = {
  'Track my order': 'To track your order, please visit the "My Orders" section in your account. You will find real-time tracking information there.',
  'Cancel order': 'Orders can only be cancelled within 24 hours of placement. Please go to My Orders and select the cancel option if available.',
  'Returns and refunds': 'To return a product or request a refund, please fill out our return/refund form or contact our support team.',
  'Delivery issues': 'If you are facing delivery issues, please check the tracking status or contact our support team for assistance.',
  'Account settings': 'You can update your account settings from the profile page by selecting "Account Settings".',
  'Login issues': 'If you are having trouble logging in, try resetting your password or contact support for further help.',
  'Data and privacy': 'We take data privacy seriously. Your personal data is handled according to our Privacy Policy available on our website.',
  'Payment Methods': 'We accept multiple payment methods including credit/debit cards, PayPal, and COD (Cash On Delivery).',
  'Payment failures': 'In case of payment failures, please verify your payment details and try again. If the issue persists, contact support.',
  'Refund process': 'Refunds are processed within 5-7 business days after your refund request is approved.',
  'Product details': 'For detailed product information, please check the product page which includes images, descriptions, and specifications.',
  'Product availability': 'Product availability is updated in real-time. Please check the product listing for accurate stock information.',
  'Warranties': 'All our products come with a minimum one-year warranty. Please see the product details for warranty terms.',
  'Report issue': 'If there is an issue with a product, please report it via our support chat or email us at support@yourapp.com.'
};

Widget _buildFaqItem(String question) {
  final answer =
      faqAnswers[question] ?? 'Sorry, no answer available for this topic.';
  return ExpansionTile(
    title: Text(
      question,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          answer,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    ],
  );
}

  Widget _buildContactSection(BuildContext context, Color primaryColor) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.contactUs,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactMethod(
            icon: Icons.email_outlined,
            title: localizations.email,
            subtitle: 'anwarnasir0970@gmail.com',
            onTap: () {
              // Open email client
            },
          ),
          const Divider(height: 24),
          _buildContactMethod(
            icon: Icons.phone_outlined,
            title: localizations.phone,
            subtitle: '+251 917 41 36 22',
            onTap: () {
              // Open phone dialer
            },
          ),
          const Divider(height: 24),
          _buildContactMethod(
            icon: Icons.chat_bubble_outline,
            title: localizations.liveChat,
            subtitle: localizations.availableHours,
            onTap: () {
              // Open live chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
}
