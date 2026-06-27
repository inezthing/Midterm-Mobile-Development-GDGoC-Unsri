import 'package:flutter/material.dart';
import '../models/models.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  final _api = SupabaseService();
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.system;
  List<Product> _products = [];
  List<CommunityPost> _posts = [];
  List<CartItem> _cart = [];
  Map<String, dynamic>? _userProfile;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  List<Product> get products => _products;
  List<CommunityPost> get posts => _posts;
  List<CartItem> get cart => _cart;
  Map<String, dynamic>? get userProfile => _userProfile;
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotalPrice => _cart.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // ==========================================
  // INITIAL DATA LOADING
  // ==========================================
  Future<void> loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadUserProfile(),
        loadProducts(),
        loadCart(),
        loadPosts(),
      ]);
    } catch (e) {
      debugPrint('Error loading Whimsify data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserProfile() async {
    if (_api.currentUser != null) {
      _userProfile = await _api.fetchUserProfile(_api.currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    try {
      _products = await _api.fetchProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> loadCart() async {
    try {
      _cart = await _api.fetchCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> loadPosts() async {
    try {
      _posts = await _api.fetchPosts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading posts: $e');
    }
  }

  // ==========================================
  // ACTIONS & MUTATIONS
  // ==========================================
  Future<void> toggleFavorite(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = _products[index];
      final newFavState = !product.isFavorite;

      // Update local UI state immediately for responsive feel
      product.isFavorite = newFavState;
      notifyListeners();
      try {
        await _api.toggleFavorite(productId, newFavState);
      } catch (e) {
        // Rollback local state on error
        product.isFavorite = !newFavState;
        notifyListeners();
        debugPrint('Error toggling favorite: $e');
      }
    }
  }

  Future<void> addToCart(Product product) async {
    try {
      final newItem = await _api.addToCart(product);
      final index = _cart.indexWhere((item) => item.product.id == product.id);

      if (index != -1) {
        _cart[index] = newItem;
      } else {
        _cart.add(newItem);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _api.removeFromCart(cartItemId);
      _cart.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> incrementCartItem(CartItem item) async {
    final newQty = item.quantity + 1;
    item.quantity = newQty;
    notifyListeners();
    try {
      await _api.updateCartQuantity(item.id, newQty);
    } catch (e) {
      item.quantity = newQty - 1;
      notifyListeners();
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> decrementCartItem(CartItem item) async {
    if (item.quantity <= 1) {
      await removeFromCart(item.id);
      return;
    }
    final newQty = item.quantity - 1;
    item.quantity = newQty;
    notifyListeners();
    try {
      await _api.updateCartQuantity(item.id, newQty);
    } catch (e) {
      item.quantity = newQty + 1;
      notifyListeners();
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    // Inserts at the beginning of local state
    _products.insert(0, product);
    notifyListeners();
  }

  Future<void> addPost(CommunityPost post) async {
    _posts.insert(0, post);
    notifyListeners();
  }

  Future<void> toggleLikePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newLikeState = !post.isLiked;

      // Update locally
      post.isLiked = newLikeState;
      final offset = newLikeState ? 1 : -1;
      final newPost = CommunityPost(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userAvatar: post.userAvatar,
        community: post.community,
        type: post.type,
        title: post.title,
        content: post.content,
        postedAt: post.postedAt,
        repliesCount: post.repliesCount,
        likesCount: post.likesCount + offset,
        isLiked: newLikeState,
      );
      _posts[index] = newPost;
      notifyListeners();
      try {
        await _api.toggleLikePost(postId, newLikeState);
      } catch (e) {
        // Rollback on error
        _posts[index] = post;
        notifyListeners();
        debugPrint('Error liking post: $e');
      }
    }
  }

  // ==========================================
  // ACCESSORS & FILTERS
  // ==========================================
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    final q = query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.sellerName.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Product> get verifiedProducts =>
      _products.where((p) => p.sellerVerified).toList();
}
