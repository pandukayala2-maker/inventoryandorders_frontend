import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _api.postRequest(
        "/auth/login",
        {"email": email, "password": password},
      );

      _user = User.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // FIX: Change void to Future<void> and add async
  Future<void> logout() async {
    _user = null;
    // If you had any persistent storage cleanup (like SharedPreferences or secure storage),
    // you would add the 'await' call here. E.g., await storage.clearToken();
    notifyListeners();
  }
}