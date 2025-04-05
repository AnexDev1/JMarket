import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.privacyPolicy,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Introduction',
              content:
                  'Welcome to JMarket. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our application.',
            ),
            _buildSection(
              context,
              title: 'Information We Collect',
              content:
                  'We collect several types of information from and about users of our application, including:\n\n'
                  '• Personal information (name, email address, phone number)\n'
                  '• Shipping and billing addresses\n'
                  '• Payment information (processed securely through our payment processors)\n'
                  '• Order history and preferences\n'
                  '• Device information and usage statistics',
            ),
            _buildSection(
              context,
              title: 'How We Use Your Information',
              content: 'We use the information we collect to:\n\n'
                  '• Process and fulfill your orders\n'
                  '• Provide customer support\n'
                  '• Improve our products and services\n'
                  '• Send promotional communications (if you have opted in)\n'
                  '• Detect and prevent fraudulent transactions\n'
                  '• Comply with legal obligations',
            ),
            _buildSection(
              context,
              title: 'Data Security',
              content:
                  'We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
            ),
            _buildSection(
              context,
              title: 'Third-Party Services',
              content:
                  'Our app may use third-party services for analytics, payment processing, and marketing. These services may collect information sent by your device. Please review the privacy policies of these third parties for more information.',
            ),
            _buildSection(
              context,
              title: 'Your Rights',
              content:
                  'Depending on your location, you may have rights regarding your personal information, including:\n\n'
                  '• Access to your personal data\n'
                  '• Correction of inaccurate data\n'
                  '• Deletion of your data\n'
                  '• Restriction or objection to processing\n'
                  '• Data portability',
            ),
            _buildSection(
              context,
              title: 'Children\'s Privacy',
              content:
                  'Our application is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
            ),
            _buildSection(
              context,
              title: 'Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            _buildSection(
              context,
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:\n\nsupport@jmarket.com',
              isLast: true,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Last Updated: March 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.indigo.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How we protect and manage your data',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Your privacy is important to us. Please read this Privacy Policy carefully to understand how we handle your information.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
            thickness: 1,
          ),
        ],
      ],
    );
  }
}
