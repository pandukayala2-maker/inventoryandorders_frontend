import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Assuming these are defined in your project
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/header_bar.dart';

// New/Existing Screen Imports
import './product_create_screen.dart';
import './product_detail_screen.dart'; // New Import
import './product_edit_screen.dart'; // New Import

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _currentSearchQuery = '';
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_handleSearchTextChange);
    // Fetch data immediately when the screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  // --- Data Management Methods ---

  Future<void> _deleteProduct(BuildContext context, Product product,
      ProductProvider provider, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: Text("Are you sure you want to delete '${product.name}'?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final ok = await provider.deleteProduct(product.id, auth);
      if (context.mounted) {
        if (ok) {
          _fetchData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.error ?? "Deletion failed")));
        }
      }
    }
  }

  void _fetchData() {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Setting listen: false prevents potential rebuild loops if called directly in initState
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      auth,
      limit: _limit,
      page: _currentPage,
      q: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
    );
  }

  void _handleSearchTextChange() {
    final newQuery = _searchCtrl.text.trim();
    if (_currentSearchQuery != newQuery) {
      // Debounce the search
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || newQuery != _searchCtrl.text.trim()) return;
        _onSearchQueryApplied(newQuery);
      });
    }
  }

  void _onSearchQueryApplied(String query) {
    setState(() {
      _currentSearchQuery = query;
      _currentPage = 1; // Always reset to page 1 on new search
    });
    _fetchData();
  }

  void _onPageChange(int newPage) {
    setState(() => _currentPage = newPage);
    _fetchData();
  }

  // --- Navigation Methods ---

  void _navigateToCreateProduct() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const ProductCreateScreen()));
    _fetchData(); // Refresh list after potential creation
  }

  void _navigateToEditProduct(Product product) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ProductEditScreen(product: product)));
    _fetchData(); // Refresh list after potential edit
  }

  void _navigateToProductDetails(Product product) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ProductDetailScreen(product: product)));
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_handleSearchTextChange);
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- UI Building ---

  Widget _buildListState(ProductProvider provider, AuthProvider auth) {
    if (provider.isLoading && provider.products.isEmpty) {
      // Initial loading state (no data yet)
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.products.isEmpty) {
      // Error state (failed to fetch)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text("Error: ${provider.error}", textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchData, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      // Empty state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(_currentSearchQuery.isEmpty
                ? "No products found."
                : "No results for '$_currentSearchQuery'."),
          ],
        ),
      );
    }

    // Success state: Display list
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final product = provider.products[i];
        return _ProductListItem(
          product: product,
          onDelete: () => _deleteProduct(context, product, provider, auth),
          onEdit: () => _navigateToEditProduct(product), // Navigate to Edit
          onTap: () =>
              _navigateToProductDetails(product), // Navigate to Details
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Only calculate total pages if not searching/no results
    final totalPages =
        _limit > 0 ? (provider.totalProductsCount / _limit).ceil() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products Management"),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // Header Bar
          HeaderBar(
            title: "Product List (${provider.totalProductsCount})",
            action: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
              onPressed: _navigateToCreateProduct,
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: "Search by Name or SKU",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchQueryApplied('');
                        })
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Product List Content (Handles Loading, Empty, Error)
          Expanded(
            child: _buildListState(provider, auth),
          ),

          // Pagination
          if (totalPages > 1 &&
              !provider.isLoading) // Hide pagination while loading
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Prev"),
                    onPressed: _currentPage > 1
                        ? () => _onPageChange(_currentPage - 1)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text("Page $_currentPage of $totalPages"),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: const Text("Next"),
                    label: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < totalPages
                        ? () => _onPageChange(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// Product List Item Widget (Updated for onTap)
// -----------------------------------------------------------

class _ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap; // New property for tapping the whole item

  const _ProductListItem({
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.onTap, // Required
  });

  @override
  Widget build(BuildContext context) {
    // Formatting the price to match the style in the image ('889')
    final priceDisplay = product.price.toStringAsFixed(0);

    return InkWell(
      // Use InkWell for tap effect
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Product Image
              Container(
                height: 90,
                width: 50, // Slightly reduced width to match screenshot look
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.broken_image, size: 24)),
                        )
                      : const Center(
                          child: Icon(Icons.inventory,
                              size: 24, color: Color.fromARGB(255, 13, 13, 13)),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Right Side Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1, // Limiting to one line for tight list view
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // SKU
                    Text(
                      "SKU: ${product.sku}",
                      style: const TextStyle(color: Color.fromARGB(255, 18, 17, 17), fontSize: 12),
                    ),
                    const SizedBox(height: 6),

                    // Price/Stock Count
                    Text(
                      priceDisplay,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 201, 17, 234),
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Buttons
                    Row(
                      children: [
                        // Edit Button
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: OutlinedButton(
                              onPressed: onEdit,
                              style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              child: const Text("Edit",
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Delete Button
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: OutlinedButton(
                              onPressed: onDelete,
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              child: const Text("Delete",
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
