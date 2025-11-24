import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrderDetails());
  }

  Future<void> _loadOrderDetails() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await orderProvider.fetchOrderDetails(auth, widget.orderId);

    if (orderProvider.error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(orderProvider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.currentOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text(order?.orderNumber ?? "Order Details"),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(child: Text(orderProvider.error ?? "Order not found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order #${order.orderNumber}",
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                "Date:",
                                DateFormat.yMMMd().format(order.createdAt),
                              ),
                              _buildInfoRow(
                                "Total Amount:",
                                "₹${order.totalAmount.toStringAsFixed(2)}",
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Order Items",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.lineItems.length,
                        itemBuilder: (ctx, i) {
                          final item = order.lineItems[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.product.name),
                            subtitle: Text(
                                "Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}"),
                            trailing: Text(
                              "₹${(item.unitPrice * item.quantity).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
