import 'package:cloud_firestore/cloud_firestore.dart'; // <--- add this


class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String activeRole;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.activeRole,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? activeRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      activeRole: activeRole ?? this.activeRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'activeRole': activeRole,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      activeRole: map['activeRole'] ?? 'Find Room',
    createdAt: parseTimestamp(map['createdAt']),
    updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, activeRole: $activeRole)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.phoneNumber == phoneNumber &&
        other.activeRole == activeRole;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        (photoUrl?.hashCode ?? 0) ^
        (phoneNumber?.hashCode ?? 0) ^
        activeRole.hashCode;
  }
}

DateTime parseTimestamp(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is Timestamp) return value.toDate();
  throw Exception('Invalid timestamp type: ${value.runtimeType}');
}
