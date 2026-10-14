import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _productService;

  ProductViewModel({ProductService? productService})
      : _productService = productService ?? ProductService();

  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';

  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _displayedProducts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize and load products & categories
  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productService.fetchProducts(),
        _productService.fetchCategories(),
      ]);

      _allProducts = results[0] as List<Product>;
      _categories = ['all', ...(results[1] as List<String>)];
      _filterProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Filter by category
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _filterProducts();
    notifyListeners();
  }

  // Filter by search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterProducts();
    notifyListeners();
  }

  void _filterProducts() {
    _displayedProducts = _allProducts.where((product) {
      final matchesCategory = _selectedCategory.toLowerCase() == 'all' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Refresh
  Future<void> refresh() async {
    await loadInitialData();
  }
}
