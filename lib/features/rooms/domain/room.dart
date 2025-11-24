import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String title;
  final String description;
  final String type;
  final String location;
  final String address;
  final double price;
  final List<String> features;
  final List<String> imageUrls;
  final String ownerId;
  final String ownerName;
  final String? ownerPhone;
  final bool isAvailable;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Room({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.address,
    required this.price,
    required this.features,
    required this.imageUrls,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone,
    required this.isAvailable,
    this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Room copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? location,
    String? address,
    double? price,
    List<String>? features,
    List<String>? imageUrls,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      address: address ?? this.address,
      price: price ?? this.price,
      features: features ?? this.features,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'address': address,
      'price': price,
      'features': features,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPhone: map['ownerPhone'],
      isAvailable: map['isAvailable'] ?? true,
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, title: $title, location: $location, price: $price, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(covariant Room other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

DateTime parseTimestamp(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is Timestamp) return value.toDate();
  throw Exception('Invalid timestamp type: ${value.runtimeType}');
}

