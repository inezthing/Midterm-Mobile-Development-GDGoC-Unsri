import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;
  // ==========================================
  // AUTHENTICATION
  // ==========================================
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'avatar_url': '🌷'},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // PRODUCTS
  // ==========================================
  Future<List<Product>> fetchProducts() async {
    final userId = currentUser?.id;
    // Join products with profiles and favorites to get all details at once
    final response = await _client
        .from('products')
        .select('*, profiles(*), favorites(*)')
        .order('listed_at', ascending: false);
    return (response as List).map((json) {
      return Product.fromJson(json, currentUserId: userId);
    }).toList();
  }

  Future<Product> createProduct({
    required String name,
    required String brand,
    required String description,
    required String category,
    required double price,
    required String condition,
    required String size,
    String? imageUrl,
    required List<String> paymentMethods,
  }) async {
    if (currentUser == null) throw Exception('User not logged in');
    final response = await _client
        .from('products')
        .insert({
          'name': name,
          'brand': brand,
          'description': description,
          'category': category,
          'price': price,
          'condition': condition,
          'size': size,
          'seller_id': currentUser!.id,
          'image_url': imageUrl,
          'payment_methods': paymentMethods,
          'image_emoji': _getCategoryEmoji(category),
          'image_color': _getCategoryColor(category),
        })
        .select('*, profiles(*)')
        .single();
    return Product.fromJson(response, currentUserId: currentUser!.id);
  }

  Future<String?> uploadProductImage(File file) async {
    try {
      if (currentUser == null) return null;
      final fileName =
          '${currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload file to product_images bucket
      await _client.storage
          .from('product_images')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      // Get public URL
      final publicUrl = _client.storage
          .from('product_images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleFavorite(String productId, bool isFavorite) async {
    if (currentUser == null) return;
    if (isFavorite) {
      await _client.from('favorites').insert({
        'user_id': currentUser!.id,
        'product_id': productId,
      });
    } else {
      await _client.from('favorites').delete().match({
        'user_id': currentUser!.id,
        'product_id': productId,
      });
    }
  }

  // ==========================================
  // CART
  // ==========================================
  Future<List<CartItem>> fetchCart() async {
    if (currentUser == null) return [];

    final response = await _client
        .from('cart_items')
        .select('*, products(*, profiles(*))')
        .eq('user_id', currentUser!.id);
    return (response as List).map((json) {
      final productJson = json['products'];
      final product = Product.fromJson(
        productJson,
        currentUserId: currentUser!.id,
      );
      return CartItem(
        id: json['id'] as String,
        product: product,
        quantity: json['quantity'] as int,
      );
    }).toList();
  }

  Future<CartItem> addToCart(Product product) async {
    if (currentUser == null) throw Exception('User not logged in');
    // Check if item already in cart
    final existing = await _client
        .from('cart_items')
        .select()
        .eq('user_id', currentUser!.id)
        .eq('product_id', product.id)
        .maybeSingle();
    if (existing != null) {
      final newQty = (existing['quantity'] as int) + 1;
      final response = await _client
          .from('cart_items')
          .update({'quantity': newQty})
          .eq('id', existing['id'])
          .select('*, products(*, profiles(*))')
          .single();
      final prod = Product.fromJson(
        response['products'],
        currentUserId: currentUser!.id,
      );
      return CartItem(
        id: response['id'] as String,
        product: prod,
        quantity: response['quantity'] as int,
      );
    } else {
      final response = await _client
          .from('cart_items')
          .insert({
            'user_id': currentUser!.id,
            'product_id': product.id,
            'quantity': 1,
          })
          .select('*, products(*, profiles(*))')
          .single();
      final prod = Product.fromJson(
        response['products'],
        currentUserId: currentUser!.id,
      );
      return CartItem(
        id: response['id'] as String,
        product: prod,
        quantity: response['quantity'] as int,
      );
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (currentUser == null) return;
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    if (currentUser == null) return;
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  // ==========================================
  // COMMUNITY
  // ==========================================
  Future<List<CommunityPost>> fetchPosts() async {
    final userId = currentUser?.id;
    final response = await _client
        .from('community_posts')
        .select('*, profiles(*), post_likes(*), community_replies(count)')
        .order('posted_at', ascending: false);
    return (response as List).map((json) {
      // Map replies count from relation aggregates if available
      final repliesCount =
          (json['community_replies'] as List?)?.first?['count'] ?? 0;
      final enrichedJson = Map<String, dynamic>.from(json);
      enrichedJson['community_replies_count'] = repliesCount;
      return CommunityPost.fromJson(enrichedJson, currentUserId: userId);
    }).toList();
  }

  Future<CommunityPost> createPost({
    required String community,
    required String type,
    required String title,
    required String content,
  }) async {
    if (currentUser == null) throw Exception('User not logged in');
    final response = await _client
        .from('community_posts')
        .insert({
          'user_id': currentUser!.id,
          'community': community,
          'type': type,
          'title': title,
          'content': content,
        })
        .select('*, profiles(*)')
        .single();
    return CommunityPost.fromJson(response, currentUserId: currentUser!.id);
  }

  Future<void> toggleLikePost(String postId, bool isLiked) async {
    if (currentUser == null) return;
    if (isLiked) {
      await _client.from('post_likes').insert({
        'user_id': currentUser!.id,
        'post_id': postId,
      });
    } else {
      await _client.from('post_likes').delete().match({
        'user_id': currentUser!.id,
        'post_id': postId,
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchReplies(String postId) async {
    final response = await _client
        .from('community_replies')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createReply(String postId, String content) async {
    if (currentUser == null) throw Exception('User not logged in');
    await _client.from('community_replies').insert({
      'post_id': postId,
      'user_id': currentUser!.id,
      'content': content,
    });
  }

  // ==========================================
  // HELPER EMOJIS & COLORS (FALLBACK)
  // ==========================================
  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Woman Fashion':
        return '👗';
      case 'Man Fashion':
        return '👕';
      case 'Health & Beauty':
        return '💄';
      case 'Keychain':
        return '🔑';
      case 'Trinket':
        return '🧸';
      case 'Shoes':
        return '👟';
      case 'Playing Card':
        return '🃏';
      case 'Sticker':
        return '🏷️';
      default:
        return '📦';
    }
  }

  String _getCategoryColor(String category) {
    switch (category) {
      case 'Woman Fashion':
        return '#FFCCD5';
      case 'Man Fashion':
        return '#D8E2DC';
      case 'Health & Beauty':
        return '#FFCAD4';
      case 'Keychain':
        return '#F4ACB7';
      case 'Trinket':
        return '#FFE5D9';
      case 'Shoes':
        return '#D8E2DC';
      case 'Playing Card':
        return '#ECE4DB';
      case 'Sticker':
        return '#FFE5D9';
      default:
        return '#E3F2FD';
    }
  }
}
