import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/house_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/geo_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/house_map_view.dart';
import '../../models/house.dart';
import 'house_detail_screen.dart';

class MapScreen extends StatelessWidget {
  final List<House> houses;
  final bool embedded;

  const MapScreen({super.key, required this.houses, this.embedded = false});

  void _showPreview(BuildContext context, House h) {
    final provider = context.read<HouseProvider>();
    final km = provider.distanceTo(h);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${h.bedrooms} Bedroom ${h.houseType}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(h.town, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Text(
                formatKes(h.price),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                GeoUtils.formatDistance(km),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HouseDetailScreen(houseId: h.id),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HouseProvider>();
    final list = houses.isEmpty ? provider.availableHouses : houses;

    final canvas = list.isEmpty
        ? const EmptyState(
            icon: LucideIcons.map,
            title: 'No houses to show',
            message: 'Try a broader search first.',
          )
        : HouseMapView(
            houses: list,
            userLat: provider.userLat,
            userLng: provider.userLng,
            followUser: provider.liveLocationActive,
            onTap: embedded ? null : (h) => _showPreview(context, h),
          );

    if (embedded) return canvas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live map'),
        actions: [
          IconButton(
            tooltip: 'Refresh GPS',
            onPressed: () => provider.startLiveLocation(),
            icon: const Icon(LucideIcons.locateFixed),
          ),
        ],
      ),
      body: list.isEmpty
          ? canvas
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.locationStatus ??
                          'Realtime OpenStreetMap — tap a house marker for preview',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: canvas,
                  ),
                ),
              ],
            ),
    );
  }
}
