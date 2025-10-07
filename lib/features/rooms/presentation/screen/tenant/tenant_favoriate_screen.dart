import 'package:flutter/material.dart';
import 'package:mvproomrentandbook/features/rooms/presentation/provider/room_provider.dart';
import 'package:mvproomrentandbook/shared/widgets/common_widgets.dart';
import 'package:mvproomrentandbook/shared/widgets/room_card.dart';
import 'package:provider/provider.dart';

class TenantFavoriteScreen extends StatelessWidget {
  const TenantFavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Text(
                'Favorite Rooms',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Consumer<RoomProvider>(
                builder: (context, roomProvider, child) {
                  if (roomProvider.favoriteRooms.isEmpty) {
                    return CustomeEmptyStateWidget(
                      title: 'No Favorites Yet',
                      subtitle:
                          'Start adding rooms to your favorites by tapping the heart icon',
                      icon: Icons.favorite_outline,
                      action: CustomButton(
                        text: 'Browse Rooms',
                        onPressed: () {
                          // Navigate back to home and switch to rooms tab
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: roomProvider.favoriteRooms.length,
                    itemBuilder: (context, index) {
                      final room = roomProvider.favoriteRooms[index];
                      return RoomCard(
                        room: room,
                        isFavorite: true,
                        onTap: () {
                          //TODO: Implement room details navigation
                          // Navigator.push(
                          //   context,
                          // MaterialPageRoute(
                          //   builder: (context) => RoomDetailsScreen(room: room),
                          // ),
                          // );
                        },
                        onFavoriteToggle: () =>
                            roomProvider.toggleFavorite(room),
                        showOwnerInfo: false,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
