import 'package:flutter/material.dart';
import 'package:kothakhoj/core/constants/app_constants.dart';
import 'package:kothakhoj/core/constants/app_theme.dart';
import 'package:kothakhoj/features/auth/presentation/auth_provider.dart';
import 'package:kothakhoj/features/rooms/domain/room.dart';
import 'package:kothakhoj/features/rooms/presentation/provider/room_provider.dart';
import 'package:kothakhoj/features/rooms/presentation/screen/tenant/tenant_room_detail_screen.dart';
import 'package:kothakhoj/shared/widgets/common_widgets.dart';
import 'package:kothakhoj/shared/widgets/room_card.dart';
import 'package:provider/provider.dart';

class TenantRoomListScreen extends StatefulWidget {
  const TenantRoomListScreen({super.key});

  @override
  State<TenantRoomListScreen> createState() => _TenantRoomListScreenState();
}

class _TenantRoomListScreenState extends State<TenantRoomListScreen> {
  String? _selectedLocation;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Filters
          _buildFilters(),

          Expanded(
            child: Consumer2<RoomProvider, AuthProvider>(
              builder: (context, roomProvider, authProvider, child) {
                switch (roomProvider.state) {
                  case RoomState.loading:
                    return const CustomLoadingWidget(
                      message: 'Loading rooms...',
                    );

                  case RoomState.error:
                    return CustomErrorWidget(
                      message:
                          roomProvider.errorMessage ?? 'Failed to load rooms',
                      onRetry: () => roomProvider.loadRooms(),
                    );

                  case RoomState.loaded:
                    if (roomProvider.rooms.isEmpty) {
                      return CustomeEmptyStateWidget(
                        title: 'No Rooms Found',
                        subtitle:
                            'Try adjusting your filters or check back later',
                        icon: Icons.home_outlined,
                        action: CustomButton(
                          text: 'Refresh',
                          onPressed: () => roomProvider.loadRooms(),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => roomProvider.loadRooms(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: roomProvider.rooms.length,
                        itemBuilder: (context, index) {
                          final room = roomProvider.rooms[index];
                          return Stack(
                            children: [
                              RoomCard(
                                room: room,
                                isFavorite: roomProvider.isFavorite(room.id),
                                onTap: () => _showRoomDetailsForTenant(room),
                                onFavoriteToggle: () =>
                                    roomProvider.toggleFavorite(room),
                                showOwnerInfo: false,
                                currentUserId: authProvider.user?.id,
                              ),

                              // Add badge for own listings
                              if (authProvider.user?.id == room.ownerId)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Your Listing',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      color: Colors.white.withOpacity(0.95),

      child: Row(
        children: [
          Flexible(
            // Changed from Expanded to Flexible
            flex: 2, // Give more space to location (longer names)
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05), // Very light fill
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),

              initialValue: _selectedLocation,
              isExpanded: true, // This prevents overflow
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Locations'),
                ),
                ...AppConstants.kathmanduLocations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(
                      location,
                      overflow: TextOverflow.ellipsis, // Handle long text
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedLocation = value);
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing
          Flexible(
            // Changed from Expanded to Flexible
            flex: 2, // Less space for room type (shorter names)
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05), // Very light fill
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),

              initialValue: _selectedType,
              isExpanded: true, // This prevents overflow
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Types'),
                ),
                ...AppConstants.roomTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      overflow: TextOverflow.ellipsis, // Handle long text
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final roomProvider = context.read<RoomProvider>();
    roomProvider.searchRooms(location: _selectedLocation, type: _selectedType);
  }

  void _showRoomDetailsForTenant(Room room) {
    //TODO: Implement room details screen navigation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantRoomDetailScreen(room: room),
      ),
    );
  }
}
