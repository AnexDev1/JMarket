// dart
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Last Updated: ${DateTime.now().toString().substring(0, 10)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By accessing or using JMarket services, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
            ),
            _buildSection(
              title: '2. Use of Service',
              content:
                  'JMarket provides an e-commerce platform for users to browse and purchase products. Users must register an account to make purchases and are responsible for maintaining the confidentiality of their account information.',
            ),
            _buildSection(
              title: '3. User Conduct',
              content:
                  'Users agree not to use the service for any illegal purposes or in any way that could damage, disable, or impair the service. Users are solely responsible for all content they upload or post through the service.',
            ),
            _buildSection(
              title: '4. Payments and Fees',
              content:
                  'Users agree to pay all fees and charges associated with their purchases on JMarket. All payment information provided must be accurate and complete.',
            ),
            _buildSection(
              title: '5. Modifications to Service',
              content:
                  'JMarket reserves the right to modify or discontinue the service at any time without notice. We shall not be liable to you or any third party for any modification, suspension, or discontinuance of the service.',
            ),
            _buildSection(
              title: '6. Limitation of Liability',
              content:
                  'JMarket shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
            ),
            _buildSection(
              title: '7. Governing Law',
              content:
                  'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which JMarket operates, without regard to its conflict of law provisions.',
            ),
            _buildSection(
              title: '8. Changes to Terms',
              content:
                  'JMarket reserves the right to update or modify these Terms at any time without prior notice. Your continued use of the service following any changes indicates your acceptance of such changes.',
            ),
            _buildSection(
              title: '9. Refund Policy',
              content:
                  'Refunds are eligible only if the product is not damaged. Requests must be made within one hour after the product is received, and only items priced above 500 birr are refundable. Refund eligibility depends on the specific item purchased and some items may not be eligible for a refund.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
