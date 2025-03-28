import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../data/datasources/remote/supabase_service.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();

  // For category selection
  String? _selectedCategory;
  final List<String> _categories = [
    'Electronics',
    'Gadgets',
    'Clothing',
    'Home',
    'Sports',
    'Books'
  ];

  // For image selection
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  bool _isLoading = false;
// Add this to your state variables
  List<String> _keyFeatures = [];
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

// File: lib/features/profile/create_product_screen.dart
// Inside _submit method:
  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Upload images and get list of image URLs
        final imageUrls = await SupabaseService().uploadImages(_selectedImages);
        final productData = {
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text) ?? 0,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'image_urls': imageUrls,
          'in_stock': true,
          'discount_percentage': 0,
          'rating': 0,
          'key_features': _keyFeatures,
        };
        await SupabaseService().createProduct(productData);

        if (mounted) {
          if (Navigator.canPop(context)) {
            context.pop();
          } else {
            context.go('/profile');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _addFeature(String feature) {
    if (feature.isNotEmpty) {
      setState(() {
        _keyFeatures.add(feature);
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      _keyFeatures.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: r'Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter product name'
                    : null,
              ),
              const SizedBox(height: 16),
              // Price field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: r'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter product price'
                    : null,
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: r'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter product description'
                    : null,
              ),
              const SizedBox(height: 16),
              // Category dropdown field
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: r'Category'),
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a category' : null,
              ),
// Add this before the submit button in your build method
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Features',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _featureController,
                          decoration: const InputDecoration(
                            hintText: 'Add a key feature',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (value) {
                            _addFeature(value);
                            _featureController.clear();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          _addFeature(_featureController.text);
                          _featureController.clear();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _keyFeatures.isEmpty
                      ? const Text('No key features added yet')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _keyFeatures.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.circle, size: 8),
                              title: Text(_keyFeatures[index]),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFeature(index),
                              ),
                            );
                          },
                        ),
                ],
              ),
              const SizedBox(height: 16),
              // Image picker section
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Select Images'),
              ),
              const SizedBox(height: 8),
              _selectedImages.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedImages
                          .map((image) => Image.file(image,
                              width: 80, height: 80, fit: BoxFit.cover))
                          .toList(),
                    )
                  : const Text('No images selected'),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: AppColors.primaryWhite,
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
