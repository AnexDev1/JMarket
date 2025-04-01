// dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShippingDetailsStep extends StatelessWidget {
  final Function(String?) onNameSaved;
  final Function(String?) onAddressSaved;
  final Function(String?) onCitySaved;
  final Function(String?) onZipCodeSaved;
  final Function(String?) onPhoneNumberSaved;

  // New optional parameters for hint text
  final String? fullNameHint;
  final String? phoneHint;

  const ShippingDetailsStep({
    Key? key,
    required this.onNameSaved,
    required this.onAddressSaved,
    required this.onCitySaved,
    required this.onZipCodeSaved,
    required this.onPhoneNumberSaved,
    this.fullNameHint,
    this.phoneHint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.shippingInformation,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          // Name field
          _buildInputField(
            context: context,
            label: localizations.fullName,
            hint: fullNameHint ?? localizations.enterFullName,
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterName;
              }
              if (value.length < 3) {
                return localizations.nameTooShort;
              }
              return null;
            },
            onSaved: onNameSaved,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          // Address field
          _buildInputField(
            context: context,
            label: localizations.streetAddress,
            hint: localizations.enterStreetAddress,
            prefixIcon: Icons.home_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterAddress;
              }
              if (value.length < 5) {
                return localizations.addressTooShort;
              }
              return null;
            },
            onSaved: onAddressSaved,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          // Phone number field with phone hint
          _buildInputField(
            context: context,
            label: localizations.phoneNumber,
            hint: phoneHint ?? localizations.enterPhoneNumber,
            prefixIcon: Icons.phone_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.enterPhoneNumber;
              }
              if (!RegExp(r'^\d{10}$')
                  .hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                return localizations.invalidPhoneNumber;
              }
              return null;
            },
            onSaved: onPhoneNumberSaved,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 24),
          // Privacy note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield,
                  color: Colors.indigo.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.informationSecureNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey.shade600,
              size: 18,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade700, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
          onSaved: onSaved,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
