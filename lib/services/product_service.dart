import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'https://fakestoreapi.com';

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw 'Failed to load products (Status ${response.statusCode})';
      }
    } catch (e) {
      throw 'Error loading products: ${e.toString()}';
    }
  }

  // Fetch all categories
  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products/categories'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item.toString()).toList();
      } else {
        throw 'Failed to load categories';
      }
    } catch (e) {
      throw 'Error loading categories: ${e.toString()}';
    }
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final encoded = Uri.encodeComponent(category);
      final response = await _client.get(Uri.parse('$baseUrl/products/category/$encoded'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw 'Failed to load products for $category';
      }
    } catch (e) {
      throw 'Error loading products by category: ${e.toString()}';
    }
  }
}
