// Assuming Product model is defined in product.dart
import 'product.dart';

/// ----------------------
/// ORDER ITEM MODEL
/// ----------------------
class OrderItem {
  final Product product;
  final int quantity;
  final double unitPrice; // price at the time of order / backend 'price' field

  OrderItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final prodJson = json['product'];
    final product = prodJson != null
        ? Product.fromJson(prodJson)
        : Product(
            id: 'unknown',
            name: 'Unknown',
            sku: '',
            price: 0,
            stock: 0,
          );

    return OrderItem(
      product: product,
      quantity: (json['quantity'] ?? 0) is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0,
      unitPrice: (json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": product.id,
      "quantity": quantity,
      "price": unitPrice,
    };
  }
}

/// ----------------------
/// ORDER MODEL
/// ----------------------
class Order {
  final String id;
  final String orderNumber;
  final double totalAmount;
  final List<OrderItem> lineItems;
  final DateTime createdAt;
  final String? customerName;
  final String? status;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.lineItems,
    required this.createdAt,
    this.customerName,
    this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: json['order_number']?.toString() ?? '',
      totalAmount: (json['total_amount'] is int)
          ? (json['total_amount'] as int).toDouble()
          : (json['total_amount'] ?? 0).toDouble(),
      customerName: json['customer_name']?.toString(),
      status: json['status']?.toString(),
      lineItems: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "order_number": orderNumber,
      "total_amount": totalAmount,
      "customer_name": customerName,
      "status": status,
      "items": lineItems.map((e) => e.toJson()).toList(),
    };
  }
}
