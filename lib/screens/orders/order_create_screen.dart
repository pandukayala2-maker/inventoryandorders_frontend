import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  Product? selectedProduct;
  int quantity = 1;
  TextEditingController searchController = TextEditingController();
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      await productProvider.fetchProducts(auth, limit: 1000, page: 1);
      setState(() {
        filteredProducts = productProvider.products;
      });
    });
  }

  void addItemToCart() {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select a product")));
      return;
    }

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Add product to provider cart with correct quantity
    for (int i = 0; i < quantity; i++) {
      orderProvider.addToCart(selectedProduct!);
    }

    setState(() {
      selectedProduct = null;
      quantity = 1;
      searchController.clear();
      filteredProducts = Provider.of<ProductProvider>(context, listen: false).products;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Order")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Product
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search Product",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  filteredProducts = products
                      .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            const SizedBox(height: 5),

            if (searchController.text.isNotEmpty)
              Container(
                height: filteredProducts.isNotEmpty ? 150 : 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: filteredProducts.isEmpty
                    ? const Center(child: Text("No Products Found"))
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text("₹ ${product.price.toStringAsFixed(2)}"),
                            onTap: () {
                              setState(() {
                                selectedProduct = product;
                                searchController.text = product.name;
                                filteredProducts = [];
                              });
                            },
                          );
                        },
                      ),
              ),
            const SizedBox(height: 15),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quantity", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        }),
                    Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => quantity++)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            ElevatedButton(onPressed: addItemToCart, child: const Text("Add Item")),
            const SizedBox(height: 10),

            // Show Cart Items
            Text("Items Added: ${orderProvider.cartItems.length}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: orderProvider.cartItems.length,
                itemBuilder: (ctx, i) {
                  final item = orderProvider.cartItems[i];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text("Qty: ${item.quantity}"),
                    trailing:
                        Text("₹ ${(item.product.price * item.quantity).toStringAsFixed(2)}"),
                  );
                },
              ),
            ),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹ ${orderProvider.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),

            // Create Order Button
            ElevatedButton(
              child: orderProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Order"),
              onPressed: () async {
                if (orderProvider.cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Add at least one product")));
                  return;
                }

                final auth = Provider.of<AuthProvider>(context, listen: false);
                final success = await orderProvider.createOrder(auth);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order created successfully")));
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(orderProvider.error ?? "Failed")));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

