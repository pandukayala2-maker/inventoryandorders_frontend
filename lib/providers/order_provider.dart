import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import './auth_provider.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Order> _orders = [];
  final List<CartItem> _cart = [];
  Order? _currentOrder;

  bool _isLoading = false;
  String? _error;
  int _totalOrdersCount = 0;

  // GETTERS
  List<Order> get orders => _orders;
  List<CartItem> get cartItems => _cart;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrdersCount => _totalOrdersCount;

  // ---------------------------
  // CART MANAGEMENT
  // ---------------------------
  void addToCart(Product product) {
    final index = _cart.indexWhere((c) => c.product.id == product.id);
    if (index == -1) {
      _cart.add(CartItem(product: product, quantity: 1));
    } else {
      _cart[index].quantity += 1;
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((c) => c.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  double get totalAmount {
    double total = 0;
    for (final item in _cart) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ---------------------------
  // CREATE ORDER
  // ---------------------------
  Future<bool> createOrder(AuthProvider auth) async {
    if (_cart.isEmpty) {
      _error = "Cart is empty";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        "items": _cart.map((e) => {
              "product_id": e.product.id,
              "quantity": e.quantity,
              "price": e.product.price,
            }).toList(),
      };

      final response = await _api.postRequest(
        "/orders",
        payload,
        token: auth.user?.token,
      );

      final respData = response is Map && response['data'] != null
          ? response['data']
          : response;

      final newOrder = Order.fromJson(respData);
      _orders.insert(0, newOrder);
      clearCart();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------
  // FETCH A SINGLE ORDER
  // ---------------------------
  Future<void> fetchOrderDetails(AuthProvider auth, String orderId) async {
    _isLoading = true;
    _error = null;
    _currentOrder = null;
    notifyListeners();

    try {
      final response = await _api.getRequest(
        "/orders/$orderId",
        token: auth.user?.token,
      );

      final orderData = response is Map && response['data'] != null
          ? response['data']
          : response;

      _currentOrder = Order.fromJson(orderData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------
  // FETCH ALL ORDERS
  // ---------------------------
  Future<void> fetchOrders(
    AuthProvider auth, {
    int? limit,
    int? page,
    String? q,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit.toString();
      if (page != null) params['page'] = page.toString();
      if (q != null && q.isNotEmpty) params['q'] = q;

      String url = "/orders";
      if (params.isNotEmpty) {
        url = "/orders?${Uri(queryParameters: params).query}";
      }

      final response = await _api.getRequest(
        url,
        token: auth.user?.token,
      );

      final orderData = response is Map && response['data'] != null
          ? response['data'] as List<dynamic>
          : response as List<dynamic>;

      _totalOrdersCount =
          (response is Map && response['total'] != null) ? response['total'] as int : orderData.length;

      _orders = orderData
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ---------------------------
// CART ITEM MODEL
// ---------------------------
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}
