import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class AppProvider extends ChangeNotifier {
  // --- Network Logic ---
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  AppProvider() {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    // Listen for real-time network changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      // Check if any active connection (WiFi, Mobile, etc.) exists
      bool hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      _isOnline = hasConnection;
      notifyListeners();
    });
  }

  // --- Theme Logic ---
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // --- Cart Logic ---
  final List<Product> _cart = [];
  final Map<int, int> _cartQuantities = {};

  List<Product> get cartItems => _cart;
  Map<int, int> get cartQuantities => _cartQuantities;

  void addToCart(Product p, int quantity) {
    if (!_cart.any((item) => item.id == p.id)) {
      _cart.add(p);
      _cartQuantities[p.id] = quantity;
    } else {
      _cartQuantities[p.id] = (_cartQuantities[p.id] ?? 0) + quantity;
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((item) => item.id == productId);
    _cartQuantities.remove(productId);
    notifyListeners();
  }

  // 🚀 Step 3: Decrease Quantity Logic (New Requirement)
  void decreaseQuantity(Product p) {
    if (_cartQuantities.containsKey(p.id)) {
      if (_cartQuantities[p.id]! > 1) {
        _cartQuantities[p.id] = _cartQuantities[p.id]! - 1;
      } else {
        // If qty is 1, remove item
        removeFromCart(p.id);
      }
      notifyListeners();
    }
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _cart) {
      total += item.price * (_cartQuantities[item.id] ?? 1);
    }
    return total;
  }

  // --- Favorites Logic ---
  List<int> _favoriteIds = [];
  List<int> get favoriteIds => _favoriteIds;

  void setFavorites(List<int> ids) {
    _favoriteIds = ids;
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      try {
        await DatabaseHelper.instance.deleteFavorite(product.id);
      } catch (e) {
        debugPrint("DB Error: $e");
      }
    } else {
      _favoriteIds.add(product.id);
      try {
        await DatabaseHelper.instance.insertFavorite(product.id);
      } catch (e) {
        debugPrint("DB Error: $e");
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel(); // Prevent memory leaks
    super.dispose();
  }
}
