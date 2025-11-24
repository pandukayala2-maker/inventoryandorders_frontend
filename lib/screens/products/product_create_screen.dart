import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});
  @override
  State<ProductCreateScreen> createState() => _ProductCreateState();
}
class _ProductCreateState extends State<ProductCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController(); // Added SKU controller
  final _priceCtrl = TextEditingController();
  File? _image;
  double _uploadProgress = 0.0;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (xfile != null) {
      setState(() {
        _image = File(xfile.path);
      });
    }
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Create Product")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HeaderBar(title: "Add New Product"),
          const SizedBox(height: 16),
          // --- Image Picker ---
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _image == null
                  ? const Center(child: Text("Tap to select image"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
          ),

          const SizedBox(height: 12),
          if (_uploadProgress > 0 && _uploadProgress < 1)
            LinearProgressIndicator(value: _uploadProgress),

          const SizedBox(height: 16),
          // --- Input Fields ---
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Product Name")),
          const SizedBox(height: 12),
          TextField(
              controller: _skuCtrl,
              decoration: const InputDecoration(
                  labelText:
                      "SKU (Leave blank to auto-generate)")), // Added SKU field
          const SizedBox(height: 12),
          TextField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Price")),
          const SizedBox(height: 24),
          // --- Save Button ---
          PrimaryButton(
            label: "Save Product",
            isLoading: provider.isLoading,
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter product name")));
                return;
              }
              // Use user input SKU or generate a unique one
              final sku = _skuCtrl.text.trim().isNotEmpty
                  ? _skuCtrl.text.trim()
                  : "SKU-${DateTime.now().millisecondsSinceEpoch}";
              final product = Product(
                id: "",
                name: name,
                sku: sku,
                price: double.tryParse(_priceCtrl.text) ?? 0.0,
                imageUrl: null,
              );
              bool ok;
              if (_image != null) {
                ok = await provider.addProductWithImage(_image!, product, auth,
                    onProgress: (p) {
                  setState(() {
                    _uploadProgress = p;
                  });
                });
              } else {
                ok = await provider.addProduct(product, auth);
              }
              if (!mounted) return;
              if (ok) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.error ?? "Create failed")));
              }
            },
          ),
        ],
      ),
    );
 }
}
