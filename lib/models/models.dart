class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String category;
  final double price;
  final String condition;
  final String size;
  final String sellerId;
  final String sellerName;
  final bool sellerVerified;
  final String? imageUrl;
  final String imageEmoji;
  final String imageColor;
  final DateTime listedAt;
  final List<String> paymentMethods;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.category,
    required this.price,
    required this.condition,
    required this.size,
    required this.sellerId,
    required this.sellerName,
    required this.sellerVerified,
    this.imageUrl,
    this.imageEmoji = '📦',
    this.imageColor = '#E3F2FD',
    required this.listedAt,
    required this.paymentMethods,
    this.isFavorite = false,
  });

  factory Product.fromJson(
    Map<String, dynamic> json, {
    bool isFav = false,
    String? currentUserId,
  }) {
    final sellerProfile = json['profiles'] as Map<String, dynamic>?;

    var favorited = isFav;
    if (json['favorites'] != null && json['favorites'] is List) {
      final favList = json['favorites'] as List;
      if (currentUserId != null) {
        favorited = favList.any((f) => f['user_id'] == currentUserId);
      } else {
        favorited = favList.isNotEmpty;
      }
    }

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      description: json['description'] ?? '',
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      condition: json['condition'] as String,
      size: json['size'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: sellerProfile != null
          ? (sellerProfile['username'] ?? 'seller')
          : 'seller',
      sellerVerified: sellerProfile != null
          ? (sellerProfile['is_verified'] ?? false)
          : false,
      imageUrl: json['image_url'] as String?,
      imageEmoji: json['image_emoji'] ?? '📦',
      imageColor: json['image_color'] ?? '#E3F2FD',
      listedAt: DateTime.parse(json['listed_at'] as String),
      paymentMethods: List<String>.from(json['payment_methods'] ?? []),
      isFavorite: favorited,
    );
  }
}

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String community;
  final String type;
  final String title;
  final String content;
  final DateTime postedAt;
  final List<String> replies;
  final int repliesCount;
  final int likesCount;
  bool isLiked;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.community,
    required this.type,
    required this.title,
    required this.content,
    required this.postedAt,
    this.replies = const [],
    int? repliesCount,
    int? likesCount,
    int? likes,
    this.isLiked = false,
  }) : repliesCount = repliesCount ?? replies.length,
       likesCount = likesCount ?? likes ?? 0;

  factory CommunityPost.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    var liked = false;
    if (json['post_likes'] != null && json['post_likes'] is List) {
      final likesList = json['post_likes'] as List;
      if (currentUserId != null) {
        liked = likesList.any((l) => l['user_id'] == currentUserId);
      } else {
        liked = likesList.isNotEmpty;
      }
    }

    var likesCount = 0;
    if (json['post_likes_count'] != null) {
      likesCount = json['post_likes_count'] as int;
    } else if (json['post_likes'] != null && json['post_likes'] is List) {
      likesCount = (json['post_likes'] as List).length;
    }

    var repliesCount = 0;
    if (json['community_replies_count'] != null) {
      repliesCount = json['community_replies_count'] as int;
    } else if (json['community_replies'] != null &&
        json['community_replies'] is List) {
      repliesCount = (json['community_replies'] as List).length;
    }

    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: profile != null ? (profile['username'] ?? 'user') : 'user',
      userAvatar: profile != null ? (profile['avatar_url'] ?? '🐰') : '🐰',
      community: json['community'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      postedAt: DateTime.parse(json['posted_at'] as String),
      repliesCount: repliesCount,
      likesCount: likesCount,
      isLiked: liked,
    );
  }
}

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({required this.id, required this.product, this.quantity = 1});
}
