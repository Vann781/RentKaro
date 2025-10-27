// lib/screens/add_item_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../services/location_service.dart';
import '../services/item_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _image;

  final LocationService _locationService = LocationService();
  final ItemService _itemService = ItemService();
  LocationData? _locationData;
  bool _isLoadingLocation = true;
  bool _isUploading = false;

  // --- NEW: Category State ---
  String? _selectedCategory;
  final List<String> _categories = [
    'Tools',
    'Electronics',
    'Sports',
    'Vehicles',
    'Other'
  ];
  // --- END NEW ---

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    // ... (This function is unchanged)
    setState(() { _isLoadingLocation = true; });
    try {
      final location = await _locationService.getUserLocation();
      if (location != null) {
        setState(() { _locationData = location; });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location is required to list an item.'),
            backgroundColor: Colors.red,
          ));
          Navigator.pop(context);
        }
      }
    } catch (e) { print("Failed to get location: $e"); }
    finally {
      if (mounted) { setState(() { _isLoadingLocation = false; }); }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() { _image = File(pickedFile.path); });
    }
  }

  void _handleSubmit() async {
    // --- UPDATED: Added category check ---
    if (_locationData == null || _image == null || _selectedCategory == null || !_formKey.currentState!.validate()) {
      String errorMsg = 'Please fix all errors';
      if (_locationData == null) {
        errorMsg = 'Still finding location...';
      } else if (_image == null) {
        errorMsg = 'Please add an image.';
      } else if (_selectedCategory == null) {
        errorMsg = 'Please select a category.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() { _isUploading = true; });

    try {
      // Get all values
      String title = _titleController.text;
      String description = _descriptionController.text;
      double price = double.tryParse(_priceController.text) ?? 0.0;
      String category = _selectedCategory!; // We know it's not null
      File image = _image!;
      LocationData location = _locationData!;

      // Call the service
      bool success = await _itemService.addItem(
        title: title,
        description: description,
        pricePerDay: price,
        category: category, // <-- NEW
        image: image,
        latitude: location.latitude!,
        longitude: location.longitude!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Item listed successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context); // Go back to home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to list item. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Error in _handleSubmit: $e");
    } finally {
      if (mounted) {
        setState(() { _isUploading = false; });
      }
    }
  }

  // --- Helper for styled text fields ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- VIBRANT APP BAR ---
      appBar: AppBar(
        title: const Text('List a New Item'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingLocation
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      )
      // --- UPDATED BODY LAYOUT ---
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- STYLED Image Picker ---
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add a photo',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // --- STYLED Title Field ---
            TextFormField(
              controller: _titleController,
              decoration: _buildInputDecoration('Item Title', Icons.title),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a title';
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // --- STYLED Description Field ---
            TextFormField(
              controller: _descriptionController,
              decoration: _buildInputDecoration('Description', Icons.description),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a description';
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            TextFormField(
              controller: _priceController,
              decoration: _buildInputDecoration('Price per Day', Icons.money),
              // Corrected this line:
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a price';
                if (double.tryParse(value) == null) return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // --- NEW: Category Dropdown ---
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _buildInputDecoration('Category', Icons.category),
              hint: const Text('Select a Category'),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) {
                if (value == null) return 'Please select a category';
                return null;
              },
            ),
            const SizedBox(height: 32.0),

            // --- NEW: STYLED Submit Button ---
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'List My Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}