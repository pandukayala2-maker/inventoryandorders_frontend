// lib/providers/product_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import './auth_provider.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  
  // State for total count
  int _totalProductsCount = 0; 

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Getter used by the Dashboard screen
  int get totalProductsCount => _totalProductsCount; 

  // --- API FETCH OPERATIONS ---

  /// Fetches a paginated list of products and the total count.
  Future<void> fetchProducts(AuthProvider auth, {int limit = 5, int page = 1, String? q}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Construct query parameters for pagination/search
      String query = '/products?limit=$limit&page=$page';
      if (q != null && q.isNotEmpty) {
        query += '&q=$q';
      }

      final data = await _api.getRequest(query, token: auth.user?.token);

      // 1. Map the list of products from the 'products' key in the response body.
      _products = (data['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList();
      
      // 2. Extract the total count from the 'total' key in the response body.
      _totalProductsCount = data['total'] ?? _products.length; 

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CRUD OPERATIONS ---

  /// Creates a new product without an image.
  Future<bool> addProduct(Product p, AuthProvider auth) async {
    try {
      _isLoading = true;
      notifyListeners();
      final data = await _api.postRequest('/products', p.toJson(), token: auth.user?.token);
      
      _products.add(Product.fromJson(data));
      _totalProductsCount++; // INCREMENT COUNT
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new product with image upload.
  Future<bool> addProductWithImage(File imageFile, Product p, AuthProvider auth, {void Function(double)? onProgress}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Upload image
      final uploadResp = await _api.uploadFile('/upload', imageFile, fieldName: 'image', token: auth.user?.token,
          progressCallback: (progress) {
        if (onProgress != null) onProgress(progress);
      });

      final imageUrl = uploadResp['url'] ?? uploadResp['file'] ?? uploadResp['data']?['url'];

      // 2. Create product with image URL
      final payload = {
        ...p.toJson(),
        'imageUrl': imageUrl,
      };

      final created = await _api.postRequest('/products', payload, token: auth.user?.token);
      
      _products.add(Product.fromJson(created));
      _totalProductsCount++; // INCREMENT COUNT

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing product (non-image fields).
  Future<bool> updateProduct(Product p, AuthProvider auth) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Send PUT request
      await _api.putRequest('/products/${p.id}', p.toJson(), token: auth.user?.token);
      
      // Update local list
      final idx = _products.indexWhere((x) => x.id == p.id);
      if (idx != -1) _products[idx] = p;

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing product including a new image upload.
  Future<bool> updateProductWithImage(File imageFile, Product p, AuthProvider auth, {void Function(double)? onProgress}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 1. Upload image
      final uploadResp = await _api.uploadFile('/upload', imageFile, fieldName: 'image', token: auth.user?.token,
          progressCallback: (progress) {
        if (onProgress != null) onProgress(progress);
      });

      final imageUrl = uploadResp['url'] ?? uploadResp['file'] ?? uploadResp['data']?['url'];

      // 2. Create updated product object
      final updated = Product(
        id: p.id,
        name: p.name,
        sku: p.sku,
        price: p.price,
        // Assuming stock is not managed here, but you'd need to include it if you update stock
        imageUrl: imageUrl, 
      );

      // 3. Send updated product to the API and update local list
      await updateProduct(updated, auth); 
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a product.
  Future<bool> deleteProduct(String id, AuthProvider auth) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 1. Store whether the product exists locally before API call
      final productIndex = _products.indexWhere((p) => p.id == id);
      
      await _api.deleteRequest('/products/$id', token: auth.user?.token);
      
      // 2. If API call succeeds, remove product from local list and decrement count
      if (productIndex != -1) {
          _products.removeAt(productIndex); // Use removeAt for index-based removal
          _totalProductsCount--;           // DECREMENT COUNT
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}