import 'package:flutter/material.dart';
import '../../features/rooms/domain/room.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/utils.dart' as app_utils;

class RoomCard extends StatelessWidget {
  final Room room;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showOwnerInfo;
  final String? currentUserId;

  const RoomCard({
    super.key,
    required this.room,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.showOwnerInfo = true,
    this.currentUserId,
  });

  bool get isOwnListing =>
      currentUserId != null && room.ownerId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and favorite button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.title,
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onFavoriteToggle != null)
                    IconButton(
                      onPressed: onFavoriteToggle,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppColors.errorColor
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingS),

              // Location and type
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: AppSizes.iconS,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.paddingXS),
                  Expanded(
                    child: Text(
                      room.location,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColorLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      room.type,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingS),

              // Description
              Text(
                app_utils.StringUtils.truncate(room.description, 100),
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.paddingS),

              // Features
              if (room.features.isNotEmpty) ...[
                Wrap(
                  spacing: AppSizes.paddingXS,
                  runSpacing: AppSizes.paddingXS,
                  children: room.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: AppSizes.paddingXS / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColorLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        feature,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.paddingS),
              ],

              // Bottom row with price and availability
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app_utils.PriceUtils.formatPriceWithCommas(room.price),
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text('per month', style: AppTextStyles.caption),
                    ],
                  ),
                  Row(
                    children: [
                      if (room.rating != null && room.rating! > 0) ...[
                        Icon(
                          Icons.star,
                          size: AppSizes.iconS,
                          color: AppColors.ratingColor,
                        ),
                        const SizedBox(width: AppSizes.paddingXS / 2),
                        Text(
                          room.rating!.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingS,
                          vertical: AppSizes.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: room.isAvailable
                              ? AppColors.successColor.withOpacity(0.1)
                              : AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Text(
                          room.isAvailable ? 'Available' : 'Unavailable',
                          style: AppTextStyles.caption.copyWith(
                            color: room.isAvailable
                                ? AppColors.successColor
                                : AppColors.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Owner info (for landlord view)
              if (showOwnerInfo && room.ownerName.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: AppSizes.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.paddingXS),
                    Text(
                      'Posted by ${room.ownerName}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              if (isOwnListing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Your Listing',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
}
