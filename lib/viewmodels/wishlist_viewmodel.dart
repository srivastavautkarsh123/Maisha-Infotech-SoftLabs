import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final List<Product> _wishlistItems = [];

  List<Product> get items => List.unmodifiable(_wishlistItems);
  int get itemCount => _wishlistItems.length;

  bool isWishlisted(int productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  void toggleWishlist(Product product) {
    final index = _wishlistItems.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _wishlistItems.removeAt(index);
    } else {
      _wishlistItems.add(product);
    }
    notifyListeners();
  }

  void removeFromWishlist(int productId) {
    _wishlistItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
