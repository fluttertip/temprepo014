import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kothakhoj/features/auth/presentation/auth_provider.dart';
import 'package:kothakhoj/features/rooms/domain/room.dart';
import 'package:kothakhoj/features/rooms/presentation/provider/room_provider.dart';
import 'package:kothakhoj/shared/widgets/common_widgets.dart';
import 'package:kothakhoj/shared/widgets/room_card.dart';
import 'package:provider/provider.dart';

class LandlordMyRoomScreen extends StatefulWidget {
  const LandlordMyRoomScreen({super.key});

  @override
  State<LandlordMyRoomScreen> createState() => _LandlordMyRoomScreenState();
}

class _LandlordMyRoomScreenState extends State<LandlordMyRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<RoomProvider>().loadMyRooms(user.id);
      }
    });
  }

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
                'My Rooms',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Consumer<RoomProvider>(
                builder: (context, roomProvider, child) {
                  switch (roomProvider.state) {
                    case RoomState.loading:
                      return const CustomLoadingWidget(
                        message: 'Loading your rooms...',
                      );

                    case RoomState.error:
                      return CustomErrorWidget(
                        message:
                            roomProvider.errorMessage ?? 'Failed to load rooms',
                        onRetry: () {
                          final user = context.read<AuthProvider>().user;
                          if (user != null) {
                            roomProvider.loadMyRooms(user.id);
                          }
                        },
                      );

                    case RoomState.loaded:
                      if (roomProvider.myRooms.isEmpty) {
                        return CustomeEmptyStateWidget(
                          title: 'No Rooms Yet',
                          subtitle: 'Start by adding your first room for rent',
                          icon: Icons.home_outlined,
                          action: CustomButton(
                            text: 'Add Room',
                            onPressed: () {
                              // Navigate to add room tab
                            },
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          final user = context.read<AuthProvider>().user;
                          if (user != null) {
                            await roomProvider.loadMyRooms(user.id);
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: roomProvider.myRooms.length,
                          itemBuilder: (context, index) {
                            final room = roomProvider.myRooms[index];
                            return RoomCard(
                              room: room,
                              onTap: () => _showRoomDetails(room),
                              showOwnerInfo: false,
                            );
                          },
                        ),
                      );

                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomDetails(Room room) {
    //TODO: Implement room details view
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LandlordRoomDetailsScreen(room: room),
    //   ),
    // );
  }
}
