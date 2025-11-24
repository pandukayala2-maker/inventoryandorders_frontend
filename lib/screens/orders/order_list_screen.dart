import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import './order_detail_screen.dart';
import './order_create_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrderProvider>(context, listen: false).fetchOrders(auth);
      _isLoaded = true;
    }
  }

  Future<void> _refreshOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<OrderProvider>(context, listen: false).fetchOrders(auth);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      // Replacing FloatingActionButton with a fixed-width "Add Order" button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity, // Full width button
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text(
              "Add Order",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
              );
            },
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshOrders,
              child: provider.orders.isEmpty
                  ? const Center(child: Text("No Orders Found"))
                  : ListView.builder(
                      itemCount: provider.orders.length,
                      itemBuilder: (context, index) {
                        final order = provider.orders[index];

                        // Prepare item summary
                        final itemSummary = order.lineItems.isEmpty
                            ? "No items"
                            : order.lineItems
                                .map((item) =>
                                    "${item.product.name.isNotEmpty ? item.product.name : 'Unknown Product'} x${item.quantity}")
                                .join(", ");

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          elevation: 2,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailScreen(orderId: order.id),
                                ),
                              );
                            },
                            title: Text(
                              order.orderNumber.isNotEmpty
                                  ? order.orderNumber
                                  : 'Order #${order.id.substring(0, 6)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("₹ ${order.totalAmount.toStringAsFixed(2)}"),
                                Text(
                                  "Date: ${DateFormat.yMMMd().format(order.createdAt)}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Items: $itemSummary",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.blue),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
