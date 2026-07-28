import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/services/cloudinary_service.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../auth/presentation/auth_provider.dart';
import '../../../../bookings/domain/booking.dart';
import '../../../../bookings/presentation/provider/booking_provider.dart';
import '../../../domain/room.dart';
import '../../provider/room_provider.dart';
import 'booking_sheet.dart';

/// v2 detail screen. Accepts a [room] (fast path from the list) OR a [roomId]
/// (deep-link path; fetches on open). Fixes v1's hardcoded owner block and fake
/// Unsplash image, adds an image carousel with indicators, real tap-to-call,
/// and a sticky, state-aware booking bar.
class TenantRoomDetailScreen extends StatefulWidget {
  const TenantRoomDetailScreen({super.key, this.room, this.roomId})
      : assert(room != null || roomId != null,
            'Provide either a room or a roomId');

  final Room? room;
  final String? roomId;

  @override
  State<TenantRoomDetailScreen> createState() => _TenantRoomDetailScreenState();
}

class _TenantRoomDetailScreenState extends State<TenantRoomDetailScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  Room? _room;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<BookingProvider>().loadTenantBookings(auth.user!.id);
      }
      if (_room == null && widget.roomId != null) {
        setState(() => _loading = true);
        final fetched =
            await context.read<RoomProvider>().getRoomById(widget.roomId!);
        if (mounted) setState(() { _room = fetched; _loading = false; });
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final room = _room;
    if (room == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Room not found')),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _appBar(room),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titlePrice(room),
                  const SizedBox(height: AppSpacing.lg),
                  _location(room),
                  if (room.features.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text('Amenities', style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    _amenities(room),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text('About this place', style: context.text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(room.description,
                      style: context.text.bodyMedium?.copyWith(
                          color: context.scheme.onSurfaceVariant, height: 1.6)),
                  const SizedBox(height: AppSpacing.xl),
                  _owner(room),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bookingBar(room),
    );
  }

  Widget _appBar(Room room) {
    final images = room.imageUrls;
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      leading: const _CircleBackButton(),
      actions: [
        Consumer<RoomProvider>(
          builder: (context, provider, _) {
            final fav = provider.isFavorite(room.id);
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _CircleIcon(
                icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: fav ? Colors.red : Colors.white,
                onTap: () => provider.toggleFavorite(room),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: images.isEmpty
            ? Hero(
                tag: 'room-${room.id}',
                child: ColoredBox(
                  color: context.scheme.surfaceContainerHighest,
                  child: Icon(Icons.apartment_rounded,
                      size: 72, color: context.scheme.onSurfaceVariant),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: images.length,
                    itemBuilder: (_, i) {
                      final img = CachedNetworkImage(
                        imageUrl:
                            CloudinaryService.optimized(images[i], width: 1200),
                        fit: BoxFit.cover,
                      );
                      return i == 0
                          ? Hero(tag: 'room-${room.id}', child: img)
                          : img;
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: AppSpacing.lg,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < images.length; i++)
                            AnimatedContainer(
                              duration: AppDurations.fast,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _page ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: i == _page ? 1 : 0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _titlePrice(Room room) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(room.title, style: context.text.headlineSmall)),
              Chip(label: Text(room.type)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: context.text.headlineSmall
                  ?.copyWith(color: context.scheme.primary),
              children: [
                TextSpan(text: 'Rs ${room.price.toStringAsFixed(0)}'),
                TextSpan(
                  text: '  / month',
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _location(Room room) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, color: context.scheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.location, style: context.text.titleSmall),
                  if (room.address.isNotEmpty)
                    Text(room.address,
                        style: context.text.bodySmall?.copyWith(
                            color: context.scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _amenities(Room room) => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final a in room.features)
            Chip(
              avatar: Icon(_amenityIcon(a), size: 16),
              label: Text(a),
            ),
        ],
      );

  Widget _owner(Room room) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.scheme.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: context.scheme.primaryContainer,
              child: Text(
                room.ownerName.isNotEmpty
                    ? room.ownerName.characters.first.toUpperCase()
                    : '?',
                style: context.text.titleMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.ownerName.isNotEmpty ? room.ownerName : 'Room owner',
                    style: context.text.titleSmall,
                  ),
                  Text('Listed this room',
                      style: context.text.bodySmall?.copyWith(
                          color: context.scheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (room.ownerPhone != null && room.ownerPhone!.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _call(room.ownerPhone!),
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: const Text('Call'),
              ),
          ],
        ),
      );

  Widget _bookingBar(Room room) {
    return Consumer2<AuthProvider, BookingProvider>(
      builder: (context, auth, bookings, _) {
        final user = auth.user;
        final isOwn = user != null && user.id == room.ownerId;
        final existing = user != null
            ? bookings.getUserBookingForRoom(user.id, room.id)
            : null;

        return Container(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
              AppSpacing.lg, AppSpacing.md + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: context.scheme.surface,
            border: Border(
                top: BorderSide(color: context.scheme.outlineVariant)),
          ),
          child: isOwn
              ? _banner(Icons.info_rounded, 'This is your own listing',
                  context.colors.info)
              : existing != null
                  ? _banner(
                      Icons.check_circle_rounded,
                      'Booking ${existing.status.name} — request already sent',
                      context.colors.success,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rs ${room.price.toStringAsFixed(0)}',
                                  style: context.text.titleLarge),
                              Text('per month',
                                  style: context.text.bodySmall?.copyWith(
                                      color: context.scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: AppButton(
                            label: 'Request to book',
                            onPressed: () => _openBookingSheet(room),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _banner(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: Text(text,
                  style: context.text.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600))),
        ],
      );

  void _openBookingSheet(Room room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BookingSheet(room: room),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  IconData _amenityIcon(String a) => switch (a.toLowerCase()) {
        'wifi' => Icons.wifi_rounded,
        'parking' => Icons.local_parking_rounded,
        'furnished' => Icons.chair_rounded,
        'kitchen access' || 'kitchen' => Icons.kitchen_rounded,
        'air conditioning' => Icons.ac_unit_rounded,
        'heater' => Icons.whatshot_rounded,
        'laundry' => Icons.local_laundry_service_rounded,
        'private bathroom' => Icons.bathtub_rounded,
        'security' => Icons.security_rounded,
        'water 24/7' => Icons.water_drop_rounded,
        'electricity backup' => Icons.bolt_rounded,
        _ => Icons.check_circle_outline_rounded,
      };
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();
  @override
  Widget build(BuildContext context) =>
      _CircleIcon(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context));
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap, this.color = Colors.white});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Material(
          color: Colors.black.withValues(alpha: 0.4),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
      );
}