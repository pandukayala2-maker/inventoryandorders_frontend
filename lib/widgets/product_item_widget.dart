// lib/widgets/product_item.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'rounded_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductItem({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color.fromARGB(255, 16, 15, 15)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                    )
                  : const Icon(Icons.inventory_2, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text("SKU: ${product.sku}", style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 6, 6, 6))),
            ]),
          ),
          Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
