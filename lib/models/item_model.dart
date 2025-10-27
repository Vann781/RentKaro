// lib/models/item_model.dart

class Item {
  final String id;
  final String title;
  final String description;
  final double pricePerDay;
  final String imageUrl;
  final String ownerUsername;
  final double distance;
  final String ownerProfilePic;
  final String ownerId;
  final bool isAvailable; // <-- CRITICAL: ADDED MISSING FIELD

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerDay,
    required this.imageUrl,
    required this.ownerUsername,
    required this.distance,
    required this.ownerProfilePic,
    required this.ownerId,
    required this.isAvailable, // <-- ADDED TO CONSTRUCTOR
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? 'default_id',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      pricePerDay: (json['pricePerDay'] as num? ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      ownerUsername: json['ownerUsername'] ?? 'A User',
      distance: (json['distance'] as num? ?? 0.0).toDouble(),
      ownerProfilePic: json['ownerProfilePic'] ?? '',
      ownerId: json['ownerId'] ?? '',
      // <-- CRITICAL: PARSE THE FIELD -->
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}