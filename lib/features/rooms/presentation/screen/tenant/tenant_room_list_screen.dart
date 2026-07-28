import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../core/widgets/room_card.dart';
import '../../../../auth/presentation/auth_provider.dart';
import '../../../domain/room.dart';
import '../../provider/room_provider.dart';

/// v2 discovery: search + quick filter chips, responsive grid, skeleton loads,
/// pull-to-refresh, and cohesive empty/error states. Replaces v1's two bare
/// dropdowns and text-only list.
class TenantRoomListScreen extends StatefulWidget {
  const TenantRoomListScreen({super.key});
  @override
  State<TenantRoomListScreen> createState() => _TenantRoomListScreenState();
}

class _TenantRoomListScreenState extends State<TenantRoomListScreen> {
  final _searchCtrl = TextEditingController();
  String? _location;
  String? _type;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RoomProvider>().loadRooms(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() => context
      .read<RoomProvider>()
      .searchRooms(location: _location, type: _type);

  List<Room> _filterByQuery(List<Room> rooms) {
    if (_query.trim().isEmpty) return rooms;
    final q = _query.toLowerCase();
    return rooms
        .where((r) =>
            r.title.toLowerCase().contains(q) ||
            r.location.toLowerCase().contains(q) ||
            r.address.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<RoomProvider, AuthProvider>(
          builder: (context, roomProvider, auth, _) {
            return RefreshIndicator(
              onRefresh: roomProvider.loadRooms,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header(context)),
                  ..._buildBody(roomProvider, auth),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.x2l)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore rooms', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          SearchBar(
            controller: _searchCtrl,
            hintText: 'Search by area, title, address…',
            leading: const Icon(Icons.search_rounded),
            trailing: [
              if (_query.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterRow(
            location: _location,
            type: _type,
            onLocation: (v) {
              setState(() => _location = v);
              _applyFilters();
            },
            onType: (v) {
              setState(() => _type = v);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(RoomProvider provider, AuthProvider auth) {
    switch (provider.state) {
      case RoomState.loading:
      case RoomState.initial:
        return [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList.separated(
              itemCount: 4,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (_, __) => const RoomCardSkeleton(),
            ),
          ),
        ];
      case RoomState.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorView(
              message: provider.errorMessage ?? 'Failed to load rooms',
              onRetry: provider.loadRooms,
            ),
          ),
        ];
      case RoomState.loaded:
        final rooms = _filterByQuery(provider.rooms);
        if (rooms.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyView(
                icon: Icons.search_off_rounded,
                title: 'No rooms found',
                message: 'Try a different area, type, or search term.',
                actionLabel: 'Reset filters',
                onAction: () {
                  setState(() {
                    _location = null;
                    _type = null;
                    _query = '';
                    _searchCtrl.clear();
                  });
                  provider.loadRooms();
                },
              ),
            ),
          ];
        }
        final width = MediaQuery.sizeOf(context).width;
        // final columns = width >= AppBreakpoints.desktop
        //     ? 3
        //     : width >= AppBreakpoints.tablet
        //         ? 2
        //         : 1;
        final columns = 1;
        final myId = auth.user?.id;

        if (columns == 1) {
          return [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList.separated(
                itemCount: rooms.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (_, i) => _card(rooms[i], provider, myId),
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisExtent: 340,
              ),
              itemCount: rooms.length,
              itemBuilder: (_, i) => _card(rooms[i], provider, myId),
            ),
          ),
        ];
    }
  }

  Widget _card(Room room, RoomProvider provider, String? myId) => RoomCard(
        room: room,
        isFavorite: provider.isFavorite(room.id),
        isOwnListing: myId != null && myId == room.ownerId,
        onFavoriteToggle: () => provider.toggleFavorite(room),
        onTap: () =>
            context.push('${AppRoutes.roomDetail}/${room.id}', extra: room),
      );
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.location,
    required this.type,
    required this.onLocation,
    required this.onType,
  });
  final String? location;
  final String? type;
  final ValueChanged<String?> onLocation;
  final ValueChanged<String?> onType;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DropdownChip(
            label: location ?? 'Location',
            selected: location != null,
            items: AppConstants.kathmanduLocations,
            onSelected: onLocation,
          ),
          const SizedBox(width: AppSpacing.sm),
          _DropdownChip(
            label: type ?? 'Type',
            selected: type != null,
            items: AppConstants.roomTypes,
            onSelected: onType,
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.label,
    required this.selected,
    required this.items,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final List<String> items;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All')),
        for (final item in items) PopupMenuItem(value: item, child: Text(item)),
      ],
      child: Chip(
        label: Text(label),
        avatar: Icon(
          selected ? Icons.check_circle_rounded : Icons.expand_more_rounded,
          size: 18,
          color: selected ? context.scheme.primary : null,
        ),
        backgroundColor:
            selected ? context.scheme.primaryContainer : null,
      ),
    );
  }
}