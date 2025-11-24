import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';

import '../widgets/product_item_widget.dart';
import '../widgets/rounded_card.dart';

import './products/product_list_screen.dart';
import './orders/order_list_screen.dart';
import './orders/order_detail_screen.dart';
import './login_screen.dart';

enum DashboardTab { products, orders }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardTab _selectedTab = DashboardTab.products;
  String searchQuery = "";

  int _currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(auth, limit: 10);

    await Provider.of<OrderProvider>(context, listen: false)
        .fetchOrders(auth, limit: itemsPerPage, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final totalProducts = productProvider.totalProductsCount;
    final totalOrders = orderProvider.totalOrdersCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(authProvider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  _buildSummaryCards(totalProducts, totalOrders),
                  const SizedBox(height: 20),
                  _buildTabButtons(),
                  const SizedBox(height: 20),
                  if (_selectedTab == DashboardTab.products)
                    _buildProductTab(productProvider),
                  if (_selectedTab == DashboardTab.orders)
                    _buildOrderTab(orderProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultPadding * 1.5,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 7, 7, 7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                  color: Color.fromARGB(255, 206, 205, 206),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: const Text("Logout"),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 66, 20, 193),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
              child: const FlutterLogo(size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int totalProducts, int totalOrders) {
    return Row(
      children: [
        Expanded(
          child: RoundedCard(
            child: Column(
              children: [
                const Text("Total Products", style: TextStyle(color: Color.fromARGB(179, 218, 17, 218))),
                const SizedBox(height: 8),
                Text(
                  "$totalProducts",
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 218, 13, 184)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: RoundedCard(
            child: Column(
              children: [
                const Text("Total Orders", style: TextStyle(color: Color.fromARGB(179, 200, 13, 197))),
                const SizedBox(height: 8),
                Text(
                  "$totalOrders",
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 186, 21, 224)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedTab = DashboardTab.products;
                _currentPage = 1;
              });
            },
            child: const Text("Products"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                _selectedTab = DashboardTab.orders;
                _currentPage = 1;
              });

              final auth =
                  Provider.of<AuthProvider>(context, listen: false);

              await Provider.of<OrderProvider>(context, listen: false)
                  .fetchOrders(auth, limit: itemsPerPage, page: 1);
            },
            child: const Text("Orders"),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTab(OrderProvider orderProvider) {
    final filtered = orderProvider.orders.where((o) {
      return o.orderNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final totalItems = filtered.length;
    final totalPages = (totalItems / itemsPerPage).ceil();

    if (_currentPage > totalPages && totalPages != 0) _currentPage = totalPages;

    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage);

    final paginated = filtered.sublist(
      startIndex,
      endIndex > totalItems ? totalItems : endIndex,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedCard(
          child: TextField(
            style: const TextStyle(color: Color.fromARGB(255, 9, 9, 9)),
            decoration: const InputDecoration(
              hintText: "Search by Order Number",
              prefixIcon: Icon(Icons.search, color: Colors.white70),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _currentPage = 1;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        if (orderProvider.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.pink))
        else if (filtered.isEmpty)
          const Center(child: Text("No matching orders found"))
        else
          Column(
            children: paginated.map((o) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedCard(
                  child: ListTile(
                    title: Text("Order #${o.orderNumber}",
                        style: const TextStyle(color: Color.fromARGB(255, 212, 9, 209))),
                    subtitle: Text(
                        "Total: ₹${o.totalAmount.toStringAsFixed(2)} | Date: ${DateFormat('MMM dd, yyyy').format(o.createdAt)}",
                        style: const TextStyle(color: Color.fromARGB(179, 184, 12, 184))),
                    trailing: const Icon(Icons.chevron_right, color: Color.fromARGB(255, 187, 21, 196)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(orderId: o.id)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text("View All Orders"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderListScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTab(ProductProvider productProvider) {
    final filtered = productProvider.products.where((p) {
      return p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final totalItems = filtered.length;
    final totalPages = (totalItems / itemsPerPage).ceil();

    if (_currentPage > totalPages && totalPages != 0) _currentPage = totalPages;

    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage);

    final paginated = filtered.sublist(
      startIndex,
      endIndex > totalItems ? totalItems : endIndex,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedCard(
          child: TextField(
            style: const TextStyle(color: Color.fromARGB(255, 213, 9, 193)),
            decoration: const InputDecoration(
              hintText: "Search by name or SKU",
              prefixIcon: Icon(Icons.search, color: Color.fromARGB(179, 155, 8, 175)),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _currentPage = 1;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        if (productProvider.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.pink))
        else if (filtered.isEmpty)
          const Center(child: Text("No matching products found"))
        else
          Column(
            children: paginated.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ProductItem(
                  product: p,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductListScreen()),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text("View All Products"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductListScreen()),
            ),
          ),
        ),
      ],
    );
  }
}
