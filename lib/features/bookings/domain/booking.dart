import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, accepted, rejected, cancelled }

class Booking {
  final String id;
  final String roomId;
  final String tenantId;
  final String landlordId;
  final String roomTitle;
  final String roomLocation;
  final double roomPrice;
  final String tenantName;
  final String? tenantPhone;
  final BookingStatus status;
  // final DateTime checkInDate;
  // final DateTime checkOutDate;
  final double totalAmount;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? responseDate; // Added missing field

  const Booking({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.landlordId,
    required this.roomTitle,
    required this.roomLocation,
    required this.roomPrice,
    required this.tenantName,
    this.tenantPhone,
    required this.status,
    // required this.checkInDate,
    // required this.checkOutDate,
    required this.totalAmount,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.responseDate, // Added missing field
  });

  Booking copyWith({
    String? id,
    String? roomId,
    String? tenantId,
    String? landlordId,
    String? roomTitle,
    String? roomLocation,
    double? roomPrice,
    String? tenantName,
    String? tenantPhone,
    BookingStatus? status,
    // DateTime? checkInDate,
    // DateTime? checkOutDate,
    double? totalAmount,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? responseDate, // Added missing field
  }) {
    return Booking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      roomTitle: roomTitle ?? this.roomTitle,
      roomLocation: roomLocation ?? this.roomLocation,
      roomPrice: roomPrice ?? this.roomPrice,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      status: status ?? this.status,
      // checkInDate: checkInDate ?? this.checkInDate,
      // checkOutDate: checkOutDate ?? this.checkOutDate,
      totalAmount: totalAmount ?? this.totalAmount,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      responseDate: responseDate ?? this.responseDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'roomTitle': roomTitle,
      'roomLocation': roomLocation,
      'roomPrice': roomPrice,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'status': status.name,
      // 'checkInDate': checkInDate.millisecondsSinceEpoch,
      // 'checkOutDate': checkOutDate.millisecondsSinceEpoch,
      'totalAmount': totalAmount,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'responseDate': responseDate?.millisecondsSinceEpoch,
    };
  }

factory Booking.fromMap(Map<String, dynamic> map) {
  return Booking(
    id: map['id'] ?? '',
    roomId: map['roomId'] ?? '',
    tenantId: map['tenantId'] ?? '',
    landlordId: map['landlordId'] ?? '',
    roomTitle: map['roomTitle'] ?? '',
    roomLocation: map['roomLocation'] ?? '',
    roomPrice: (map['roomPrice'] ?? 0.0).toDouble(),
    tenantName: map['tenantName'] ?? '',
    tenantPhone: map['tenantPhone'],
    status: BookingStatus.values.firstWhere(
      (e) => e.name == map['status'],
      orElse: () => BookingStatus.pending,
    ),
    totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
    message: map['message'],
    createdAt: parseTimestamp(map['createdAt']),
    updatedAt: parseTimestamp(map['updatedAt']),
    responseDate: map['responseDate'] != null ? parseTimestamp(map['responseDate']) : null,
  );
}


  @override
  String toString() {
    return 'Booking(id: $id, roomTitle: $roomTitle, status: $status, totalAmount: $totalAmount)';
    // checkInDate: $checkInDate)';
  }

  @override
  bool operator ==(covariant Booking other) {
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
