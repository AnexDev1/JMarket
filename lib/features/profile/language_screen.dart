// lib/features/profile/language_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: languageProvider.availableLanguages.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final language = languageProvider.availableLanguages[index];
              final isSelected = language == languageProvider.currentLanguage;

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: Text(
                  language,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.indigo.shade700 : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.indigo.shade700)
                    : null,
                onTap: () {
                  languageProvider.setLanguage(language);
                  context.go('/profile');
                },
              );
            },
          );
        },
      ),
    );
  }
}
