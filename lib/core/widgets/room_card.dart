import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/cloudinary_service.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../../features/rooms/domain/room.dart';
import 'shimmer.dart';

/// v2 room card: image-forward (Airbnb/Zillow style), cached + Cloudinary
/// optimized images, hero transition into detail, tappable favorite with
/// haptic feedback, and price/rating/availability surfaced at a glance.
///
/// Replaces v1's text-only card that never showed the actual room photo.
class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.isOwnListing = false,
    this.heroPrefix = 'room',
  });

  final Room room;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool isOwnListing;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final text = context.text;
    final image = room.imageUrls.isNotEmpty
      ? room.imageUrls.first
      : _defaultImageForRoom(room.id);

    return Semantics(
      button: true,
      label: '${room.title}, ${room.location}, '
          'Rs ${room.price.toStringAsFixed(0)} per month',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: '$heroPrefix-${room.id}',
                      child: image == null
                          ? _Placeholder(scheme: scheme)
                          : CachedNetworkImage(
                              imageUrl:
                                  CloudinaryService.optimized(image, width: 800),
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  const Shimmer(child: SkeletonBox(height: 220)),
                              errorWidget: (_, __, ___) =>
                                  _Placeholder(scheme: scheme),
                            ),
                    ),
                    // Legibility scrim for the chips.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.28),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.18),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: _Chip(
                        label: room.type,
                        bg: Colors.white.withValues(alpha: 0.92),
                        fg: scheme.onSurface,
                      ),
                    ),
                    if (isOwnListing)
                      Positioned(
                        top: AppSpacing.md,
                        right: AppSpacing.md,
                        child: _Chip(
                          label: 'Your listing',
                          bg: scheme.primary,
                          fg: scheme.onPrimary,
                        ),
                      )
                    else if (onFavoriteToggle != null)
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: _FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onFavoriteToggle!();
                          },
                        ),
                      ),
                    if (!room.isAvailable)
                      Positioned(
                        bottom: AppSpacing.md,
                        left: AppSpacing.md,
                        child: _Chip(
                          label: 'Unavailable',
                          bg: scheme.error,
                          fg: scheme.onError,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(room.title,
                              style: text.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (room.rating != null && room.rating! > 0) ...[
                          Icon(Icons.star_rounded,
                              size: AppIconSize.sm, color: context.colors.rating),
                          const SizedBox(width: 2),
                          Text(room.rating!.toStringAsFixed(1),
                              style: text.labelMedium),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: AppIconSize.sm,
                            color: scheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(room.location,
                              style: text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('Rs ${_grouped(room.price)}',
                            style: text.titleLarge
                                ?.copyWith(color: scheme.primary)),
                        Text('  / month',
                            style: text.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _grouped(double v) {
    final s = v.toStringAsFixed(0);
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.scheme});
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.apartment_rounded,
            size: AppIconSize.xl, color: scheme.onSurfaceVariant),
      );
}

// A small deterministic set of pleasant room photos to use as a fallback
// when a listing doesn't have an uploaded image. We pick one using the
// room id hash so the same room gets the same fallback each time.
const List<String> _kDefaultRoomImages = [
  'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
  'https://images.unsplash.com/photo-1505692794400-4a3a8a2f0d1b',
  'https://images.unsplash.com/photo-1508057198894-247b23fe5ade',
  'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
  'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
];

String _defaultImageForRoom(String id) {
  if (id.isEmpty) return _kDefaultRoomImages.first;
  final idx = id.hashCode.abs() % _kDefaultRoomImages.length;
  return '${_kDefaultRoomImages[idx]}?auto=format&fit=crop&w=1200&q=80';
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: fg, fontWeight: FontWeight.w700)),
      );
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});
  final bool isFavorite;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onTap,
          icon: AnimatedSwitcher(
            duration: AppDurations.fast,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : Colors.black87,
            ),
          ),
        ),
      );
}

/// Skeleton shown while a list of rooms loads.
class RoomCardSkeleton extends StatelessWidget {
  const RoomCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AspectRatio(aspectRatio: 16 / 10, child: SkeletonBox(radius: 0)),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 18, width: 180),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonBox(height: 12, width: 120),
                    SizedBox(height: AppSpacing.md),
                    SkeletonBox(height: 20, width: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}