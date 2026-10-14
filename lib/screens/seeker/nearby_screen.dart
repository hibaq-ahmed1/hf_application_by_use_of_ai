import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/features.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/geo_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/house_card.dart';
import 'house_detail_screen.dart';
import 'search_screen.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  bool _locating = false;
  bool _hasLocated = false;
  String _status = 'Press “Find Houses Near Me” to use your GPS location';
  double _radiusKm = 10;

  Future<void> _findNearMe() async {
    setState(() {
      _locating = true;
      _status = 'Requesting location permission…';
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = 'Location services are off — using demo pin near Kitengela';
          _hasLocated = true;
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _status = 'Permission denied — using demo pin near Kitengela';
          _hasLocated = true;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      context.read<HouseProvider>().setUserLocation(pos.latitude, pos.longitude);
      setState(() {
        _hasLocated = true;
        _status =
            'Your location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      });
    } catch (_) {
      setState(() {
        _status = 'Could not fetch GPS — using demo pin near Kitengela';
        _hasLocated = true;
      });
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final results = _hasLocated ? houses.nearby(maxKm: _radiusKm) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby houses'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen(focusTowns: true)),
            ),
            child: const Text('Search town'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current location mode',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Find Houses Near Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                        ),
                        onPressed: _locating ? null : _findNearMe,
                        icon: _locating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(LucideIcons.navigation, size: 18),
                        label: Text(_hasLocated ? 'Refresh my location' : 'Find Houses Near Me'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Search radius', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kNearbyRadiiKm.map((r) {
                    final selected = _radiusKm == r;
                    return ChoiceChip(
                      label: Text('${r.toStringAsFixed(0)} km'),
                      selected: selected,
                      onSelected: (_) => setState(() => _radiusKm = r),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: !_hasLocated
                ? const EmptyState(
                    icon: LucideIcons.locateFixed,
                    title: 'Share your location',
                    message:
                        'Tap Find Houses Near Me so Flutter can read your latitude & longitude and compare them with house coordinates.',
                  )
                : results.isEmpty
                    ? EmptyState(
                        icon: LucideIcons.mapPinOff,
                        title: 'Nothing within ${_radiusKm.toStringAsFixed(0)} km',
                        message: 'Try a larger radius, or search Kajiado / Nairobi manually.',
                        action: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(focusTowns: true),
                            ),
                          ),
                          child: const Text('Manual location search'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) {
                          final h = results[i];
                          final km = houses.distanceTo(h);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 4),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.navigation, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      GeoUtils.formatDistance(km),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    Text(
                                      ' · ${h.town}',
                                      style: const TextStyle(color: AppColors.inkMuted),
                                    ),
                                  ],
                                ),
                              ),
                              HouseCard(
                                house: h,
                                matchPercent: houses.matchFor(h, auth.preferences),
                                distanceKm: km,
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
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
