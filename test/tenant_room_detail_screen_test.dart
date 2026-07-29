import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kothakhoj/features/rooms/domain/room.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/tenant/tenant_room_detail_screen.dart';

void main() {
  testWidgets('shows a clear booking action on the room detail screen', (
    tester,
  ) async {
    final room = Room(
      id: 'room-1',
      title: 'Cozy Studio',
      description: 'Bright and spacious studio near the market.',
      type: 'Studio',
      location: 'Kathmandu',
      address: 'Boudha',
      price: 18000,
      features: const ['Wi-Fi', 'Furnished'],
      imageUrls: const [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3',
      ],
      ownerId: 'owner-1',
      ownerName: 'Asha',
      isAvailable: true,
      rating: 4.8,
      reviewCount: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TenantRoomDetailScreen(room: room)),
      ),
    );

    expect(find.text('Cozy Studio'), findsOneWidget);
    expect(find.text('Book now'), findsOneWidget);
  });
}
