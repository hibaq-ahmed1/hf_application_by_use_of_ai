import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/house.dart';
import '../theme/app_colors.dart';
import '../utils/geo_utils.dart';
import 'common_widgets.dart';

class MatchBadge extends StatelessWidget {
  final int percent;
  final bool compact;

  const MatchBadge({super.key, required this.percent, this.compact = false});

  Color get _color {
    if (percent >= 80) return AppColors.matchHigh;
    if (percent >= 60) return AppColors.matchMid;
    return AppColors.matchLow;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: compact ? 12 : 14, color: _color),
          const SizedBox(width: 4),
          Text(
            '$percent% match',
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class HouseCard extends StatelessWidget {
  final House house;
  final int? matchPercent;
  final double? distanceKm;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const HouseCard({
    super.key,
    required this.house,
    this.matchPercent,
    this.distanceKm,
    this.isFavorite = false,
    required this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: CachedNetworkImage(
                      imageUrl: house.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.border),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.border,
                        child: const Icon(LucideIcons.home),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: house.isAvailable
                          ? AppColors.success
                          : AppColors.inkMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      house.availabilityLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      onPressed: onFavorite,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.92),
                      ),
                      icon: Icon(
                        LucideIcons.heart,
                        color: isFavorite ? AppColors.accent : AppColors.inkMuted,
                        size: 18,
                      ),
                    ),
                  ),
                if (matchPercent != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: MatchBadge(percent: matchPercent!, compact: true),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatKes(house.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    house.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: AppColors.inkMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          distanceKm != null
                              ? '${house.location} · ${GeoUtils.formatDistance(distanceKm!)}'
                              : house.location,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.inkMuted,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Meta(icon: LucideIcons.bedDouble, label: '${house.bedrooms}'),
                      const SizedBox(width: 12),
                      _Meta(icon: LucideIcons.bath, label: '${house.bathrooms}'),
                      const SizedBox(width: 12),
                      _Meta(icon: LucideIcons.building2, label: house.houseType),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.inkMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
