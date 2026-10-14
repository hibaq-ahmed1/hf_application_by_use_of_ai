import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/house_card.dart';
import 'house_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final favs = houses.favoriteHouses;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favs.isEmpty
          ? const EmptyState(
              icon: LucideIcons.heart,
              title: 'No favorites yet',
              message: 'Tap the heart on any house to save it here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final h = favs[i];
                return HouseCard(
                  house: h,
                  matchPercent: houses.matchFor(h, auth.preferences),
                  distanceKm: houses.distanceTo(h),
                  isFavorite: true,
                  onFavorite: () => houses.toggleFavorite(
                    h.id,
                    userId: auth.currentUser?.id,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HouseDetailScreen(houseId: h.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class RecentlyViewedScreen extends StatelessWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final recent = houses.recentlyViewedHouses;

    return Scaffold(
      appBar: AppBar(title: const Text('Recently viewed')),
      body: recent.isEmpty
          ? const EmptyState(
              icon: LucideIcons.history,
              title: 'Nothing viewed yet',
              message: 'Houses you open will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final h = recent[i];
                return HouseCard(
                  house: h,
                  matchPercent: houses.matchFor(h, auth.preferences),
                  distanceKm: houses.distanceTo(h),
                  isFavorite: houses.isFavorite(h.id),
                  onFavorite: () => houses.toggleFavorite(
                    h.id,
                    userId: auth.currentUser?.id,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HouseDetailScreen(houseId: h.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
