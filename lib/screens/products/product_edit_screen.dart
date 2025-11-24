import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';

class ProductEditScreen extends StatefulWidget {
  final Product product;
  const ProductEditScreen({super.key, required this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController skuCtrl;
  late TextEditingController priceCtrl;
  File? _image;
  double _uploadProgress = 0.0;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product.name);
    skuCtrl = TextEditingController(text: widget.product.sku);
    priceCtrl = TextEditingController(text: widget.product.price.toString());
  }

  Future<void> _pickImage() async {
    final XFile? xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (xfile != null) {
      setState(() => _image = File(xfile.path));
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    skuCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Edit ${widget.product.name}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HeaderBar(title: "Edit Product"),
          const SizedBox(height: 12),

          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : (widget.product.imageUrl != null &&
                          widget.product.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        )
                      : const Center(child: Text("Tap to select image")),
            ),
          ),

          const SizedBox(height: 8),
          if (_uploadProgress > 0 && _uploadProgress < 1)
            LinearProgressIndicator(value: _uploadProgress),

          const SizedBox(height: 12),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Product Name"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: skuCtrl,
            decoration: const InputDecoration(labelText: "SKU"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: priceCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Price"),
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            label: "Update Product",
            isLoading: provider.isLoading,
            onPressed: () async {
              final updated = Product(
                id: widget.product.id,
                name: nameCtrl.text.trim(),
                sku: skuCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text) ?? 0.0,
                imageUrl: _image != null ? null : widget.product.imageUrl,
              );

              bool ok;

              if (_image != null) {
                ok = await provider.updateProductWithImage(
                  _image!,
                  updated,
                  auth,
                  onProgress: (p) {
                    setState(() => _uploadProgress = p);
                  },
                );
              } else {
                ok = await provider.updateProduct(updated, auth);
              }
              if (!mounted) return;
              if (ok) {
                Navigator.pop(context); // return to previous screen
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(provider.error ?? "Update failed"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
