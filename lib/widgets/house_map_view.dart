import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/house.dart';
import '../theme/app_colors.dart';

/// Live OpenStreetMap canvas with house markers + user GPS pin.
class HouseMapView extends StatefulWidget {
  final List<House> houses;
  final double userLat;
  final double userLng;
  final ValueChanged<House>? onTap;
  final String? selectedId;
  final bool followUser;

  const HouseMapView({
    super.key,
    required this.houses,
    required this.userLat,
    required this.userLng,
    this.onTap,
    this.selectedId,
    this.followUser = false,
  });

  @override
  State<HouseMapView> createState() => _HouseMapViewState();
}

class _HouseMapViewState extends State<HouseMapView> {
  final _controller = MapController();
  bool _didFit = false;

  @override
  void didUpdateWidget(covariant HouseMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.followUser &&
        (oldWidget.userLat != widget.userLat ||
            oldWidget.userLng != widget.userLng)) {
      _controller.move(LatLng(widget.userLat, widget.userLng), _controller.camera.zoom);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fitBounds() {
    if (_didFit || !mounted) return;
    _didFit = true;
    final points = <LatLng>[
      LatLng(widget.userLat, widget.userLng),
      ...widget.houses.map((h) => LatLng(h.latitude, h.longitude)),
    ];
    if (points.length < 2) {
      _controller.move(points.first, 13);
      return;
    }
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }
    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
    _controller.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.houses.isEmpty) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text('No map points'),
      );
    }

    final center = LatLng(widget.userLat, widget.userLng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12.5,
              onMapReady: _fitBounds,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.housefinder.hf_application_by_use_of_ai',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.chartBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(blurRadius: 8, color: Colors.black26),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.navigation, color: Colors.white, size: 18),
                    ),
                  ),
                  ...widget.houses.map((h) {
                    final selected = h.id == widget.selectedId;
                    return Marker(
                      point: LatLng(h.latitude, h.longitude),
                      width: selected ? 48 : 40,
                      height: selected ? 48 : 40,
                      child: GestureDetector(
                        onTap: widget.onTap == null ? null : () => widget.onTap!(h),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(blurRadius: 6, color: Colors.black26),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.home, color: Colors.white, size: 16),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'map_me',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    _controller.move(LatLng(widget.userLat, widget.userLng), 14);
                  },
                  child: const Icon(LucideIcons.locateFixed, size: 18),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_fit',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    _didFit = false;
                    _fitBounds();
                  },
                  child: const Icon(LucideIcons.scan, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
