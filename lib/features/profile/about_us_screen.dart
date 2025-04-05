import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutUs,
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
              title: 'Our Story',
              content:
                  'JMarket was founded in 2021 with a simple mission: to create an online marketplace that connects customers with quality products from trusted sellers. What started as a small team with big dreams has grown into a thriving platform serving customers worldwide.',
            ),
            _buildSection(
              context,
              title: 'Our Mission',
              content:
                  'To provide a seamless, secure, and enjoyable shopping experience that empowers both buyers and sellers. We strive to build a marketplace where quality, trust, and customer satisfaction are the foundations of every transaction.',
            ),
            _buildSection(
              context,
              title: 'Our Team',
              content:
                  'JMarket is powered by a diverse team of passionate professionals dedicated to innovation and excellence. Our experts in technology, marketing, logistics, and customer service work together to continuously improve your shopping experience.',
            ),
            _buildSection(
              context,
              title: 'Our Values',
              content:
                  '• Customer First: Your satisfaction drives everything we do\n'
                  '• Quality: We maintain high standards for all products and services\n'
                  '• Trust: We build relationships based on transparency and reliability\n'
                  '• Innovation: We constantly evolve to meet changing market needs\n'
                  '• Community: We support the growth of our seller and buyer community',
            ),
            _buildSection(
              context,
              title: 'Our Commitment',
              content:
                  'At JMarket, we are committed to sustainable business practices and ethical commerce. We carefully vet our sellers, enforce quality standards, and continually work to reduce our environmental footprint.',
            ),
            _buildSection(
              context,
              title: 'Contact Us',
              content:
                  'We\'d love to hear from you! Reach out to our team at:\n\n'
                  'Email: support@jmarket.com\n'
                  'Phone: +1 (555) 123-4567\n'
                  'Address: 123 Market Street, Tech City, TC 12345',
              isLast: true,
            ),
            const SizedBox(height: 32),
            _buildSocialLinks(context, isDark),
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
                  Icons.store_outlined,
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
                      'About JMarket',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your trusted marketplace',
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
            'Get to know us better - our story, our mission, and the team behind JMarket.',
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

  Widget _buildSocialLinks(BuildContext context, bool isDark) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect With Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialButton(context, Icons.facebook, 'Facebook', isDark),
              _socialButton(context, Icons.android, 'Twitter', isDark),
              _socialButton(
                  context, Icons.camera_alt_outlined, 'Instagram', isDark),
              _socialButton(
                  context, Icons.messenger_outline, 'LinkedIn', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton(
      BuildContext context, IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.indigo.shade700,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
