import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/room.dart';

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
    final images = room.imageUrls.isNotEmpty
        ? room.imageUrls
        : [
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3',
          ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
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
                    itemBuilder: (context, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (c, _) => const ColoredBox(
                        color: Colors.black12,
                      ),
                      errorWidget: (c, _, __) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(_currentIndex == i ? 1 : 0.6),
                              borderRadius: BorderRadius.circular(3),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Rs ${room.price.toStringAsFixed(0)} / month', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
                  Text(room.description),
                  const SizedBox(height: 16),
                  if (room.features.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: room.features.map((f) => Chip(label: Text(f))).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
