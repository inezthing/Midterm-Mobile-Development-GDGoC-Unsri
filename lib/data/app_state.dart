import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  List<Product> _products = List.from(mockProducts);
  List<CommunityPost> _posts = List.from(mockPosts);
  List<CartItem> _cart = [];

  ThemeMode get themeMode => _themeMode;
  List<Product> get products => _products;
  List<CommunityPost> get posts => _posts;
  List<CartItem> get cart => _cart;

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].isFavorite = !_products[index].isFavorite;
      notifyListeners();
    }
  }

  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void addPost(CommunityPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    final q = query.toLowerCase();
    return _products.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.brand.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q) ||
      p.description.toLowerCase().contains(q) ||
      p.sellerName.toLowerCase().contains(q),
    ).toList();
  }

  List<Product> get verifiedProducts =>
      _products.where((p) => p.sellerVerified).toList();
}
