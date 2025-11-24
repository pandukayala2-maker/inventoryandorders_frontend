import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';
import './product_edit_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  Future<void> _navigateToEdit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ProductEditScreen(product: product),
      ),
    );
    // Do NOT pop here — user stays on detail screen
  }

  Future<void> _deleteProduct(
    BuildContext context,
    ProductProvider provider,
    AuthProvider auth,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: Text("Are you sure you want to delete '${product.name}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Delete",
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final ok = await provider.deleteProduct(product.id, auth);

      if (!context.mounted) return;

      if (ok) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? "Deletion failed"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: "Edit Product",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HeaderBar(title: "Product Overview"),
          const SizedBox(height: 16),

          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: (product.imageUrl != null &&
                    product.imageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.inventory_2,
                        size: 50, color: Colors.grey),
                  ),
          ),

          const SizedBox(height: 24),

          _buildDetailRow("Name", product.name),
          _buildDetailRow("SKU", product.sku),
          _buildDetailRow(
            "Price",
            "\$${product.price.toStringAsFixed(2)}",
            isPrice: true,
          ),

          const SizedBox(height: 40),

          PrimaryButton(
            label: "Delete Product",
            isLoading: provider.isLoading,
            onPressed: () => _deleteProduct(context, provider, auth),
            width: double.infinity,
          ),

          const SizedBox(height: 16),

          PrimaryButton(
            label: "Edit Product",
            onPressed: () => _navigateToEdit(context),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
              color: isPrice ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
