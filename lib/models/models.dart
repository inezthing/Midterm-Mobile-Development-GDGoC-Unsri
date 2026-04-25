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
    required this.imageEmoji,
    required this.imageColor,
    required this.listedAt,
    required this.paymentMethods,
    this.isFavorite = false,
  });
}

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String community;
  final String type; // WTS, WTB, Discussion
  final String title;
  final String content;
  final DateTime postedAt;
  final List<String> replies;
  final int likes;

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
    required this.replies,
    required this.likes,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}