class Product {
  final String id;
  final String name;
  final String sku;
  final double price;
  final int? stock;          // optional (only used in inventory)
  final String? imageUrl;    // optional

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.stock,
    this.imageUrl,
  });

  // ------- JSON → Product -------
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // Support both MongoDB `_id` and normal `id`
      id: (json['_id'] ?? json['id'] ?? '').toString(),

      name: json['name'] ?? '',
      sku: json['sku'] ?? '',

      // Ensure price is always double
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0).toDouble(),

      // stock may not exist in some API responses
      stock: json['stock'] is int
          ? json['stock']
          : (json['stock'] != null ? int.tryParse(json['stock'].toString()) : null),

      // support null/empty image URL
      imageUrl: (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty)
          ? json['imageUrl'].toString()
          : null,
    );
  }

  // ------- Product → JSON -------
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "name": name,
      "sku": sku,
      "price": price,
    };

    // Only send stock when needed (e.g., admin inventory updates)
    if (stock != null) {
      map['stock'] = stock;
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      map['imageUrl'] = imageUrl!;
    }

    return map;
  }
}
