import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/services/cloudinary_service.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../domain/room.dart';
import 'booking_sheet.dart';

class TenantRoomDetailScreen extends StatefulWidget {
  final Room room;
  const TenantRoomDetailScreen({super.key, required this.room});

  @override
  State<TenantRoomDetailScreen> createState() => _TenantRoomDetailScreenState();
}

class _TenantRoomDetailScreenState extends State<TenantRoomDetailScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final scheme = context.scheme;
    final text = context.text;
    final images = room.imageUrls.isNotEmpty
        ? room.imageUrls
        : const [
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3',
          ];
    final features = room.features.isNotEmpty
        ? room.features
        : const ['Wi-Fi', 'Parking', 'Furnished'];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        itemCount: images.length,
                        itemBuilder: (context, i) => Hero(
                          tag: 'room-${room.id}',
                          child: CachedNetworkImage(
                            imageUrl: CloudinaryService.optimized(images[i], width: 1200),
                            fit: BoxFit.cover,
                            placeholder: (c, _) => ColoredBox(
                              color: scheme.surfaceContainerHighest,
                            ),
                            errorWidget: (c, _, __) => ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.12),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.28),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: AppSpacing.lg,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentIndex == i ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: _currentIndex == i ? 1 : 0.6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 112),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(room.title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: AppIconSize.sm, color: scheme.onSurfaceVariant),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(room.location, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(room.type, style: text.labelMedium?.copyWith(color: scheme.onPrimaryContainer)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Monthly rent', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text('Rs ${room.price.toStringAsFixed(0)}', style: text.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: room.isAvailable ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                room.isAvailable ? 'Available now' : 'Unavailable',
                                style: text.labelMedium?.copyWith(color: room.isAvailable ? scheme.onSecondaryContainer : scheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('About this place', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(room.description, style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.5)),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Address', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(room.address.isNotEmpty ? room.address : room.location, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.lg),
                      Text('What’s included', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: features
                            .map(
                              (feature) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(feature, style: text.labelMedium),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (room.ownerName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: scheme.primaryContainer,
                                child: Icon(Icons.person_outline_rounded, color: scheme.onPrimaryContainer),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Listed by ${room.ownerName}', style: text.titleSmall),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text('Tap below to send a booking request', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: AppButton(
                  label: room.isAvailable ? 'Book now' : 'Unavailable',
                  icon: Icons.calendar_month_rounded,
                  onPressed: room.isAvailable ? _openBookingSheet : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBookingSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BookingSheet(room: widget.room),
    );
  }
}
