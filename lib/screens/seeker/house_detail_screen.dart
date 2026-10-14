import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/house.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/geo_utils.dart';
import '../../widgets/ai_explanation_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/house_card.dart';
import '../../widgets/house_map_view.dart';

class HouseDetailScreen extends StatefulWidget {
  final String houseId;

  const HouseDetailScreen({super.key, required this.houseId});

  @override
  State<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<HouseProvider>().recordView(
            widget.houseId,
            userId: auth.currentUser?.id,
          );
    });
  }

  Future<void> _whatsApp(House house, String? userId) async {
    final phone = house.ownerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final text = Uri.encodeComponent(
      'Hi ${house.ownerName}, I am interested in ${house.title} (${formatKes(house.price)}).',
    );
    final uri = Uri.parse('https://wa.me/${phone.replaceFirst('+', '')}?text=$text');
    if (userId != null) {
      context.read<HouseProvider>().recordContact(userId, house.id, 'whatsapp');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final houses = context.watch<HouseProvider>();
    final auth = context.watch<AuthProvider>();
    final house = houses.byId(widget.houseId);

    if (house == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: LucideIcons.home,
          title: 'House not found',
          message: 'This listing may have been removed.',
        ),
      );
    }

    final distance = houses.distanceTo(house);
    final match = houses.matchResult(house, auth.preferences);
    final similar = houses.similarTo(house);
    final fav = houses.isFavorite(house.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. House images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: house.images.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: house.images[i],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        house.images.length,
                        (i) => Container(
                          width: _page == i ? 18 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _page == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: fav ? 'Remove favorite' : 'Save favorite',
                onPressed: () => houses.toggleFavorite(
                  house.id,
                  userId: auth.currentUser?.id,
                ),
                icon: Icon(
                  LucideIcons.heart,
                  color: fav ? AppColors.accent : AppColors.ink,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title
                  Text(
                    house.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // 3. Price
                  Text(
                    formatKes(house.price),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // 4. Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.mapPin, size: 16, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${house.fullLocationLabel}\n${house.address}\n${GeoUtils.formatDistance(distance)}',
                          style: const TextStyle(color: AppColors.inkMuted, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // 5. AI Match
                  MatchBadge(percent: match.percent),
                  const SizedBox(height: 12),
                  AiExplanationCard(match: match),
                  const SizedBox(height: 18),
                  // 6. Bedrooms / Bathrooms
                  Row(
                    children: [
                      _Feature(icon: LucideIcons.bedDouble, label: '${house.bedrooms} Beds'),
                      _Feature(icon: LucideIcons.bath, label: '${house.bathrooms} Baths'),
                      _Feature(icon: LucideIcons.building2, label: house.houseType),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Feature(
                        icon: LucideIcons.car,
                        label: house.parking ? 'Parking' : 'No parking',
                      ),
                      _Feature(icon: LucideIcons.shield, label: house.security),
                      _Feature(
                        icon: LucideIcons.sofa,
                        label: house.furnished ? 'Furnished' : 'Unfurnished',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // 7. Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    house.description,
                    style: const TextStyle(height: 1.5, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 22),
                  // 8. Amenities
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...house.facilities.activeLabels.map((a) => Chip(label: Text(a))),
                      ...house.amenities.map(
                        (a) => Chip(
                          avatar: const Icon(LucideIcons.check, size: 14),
                          label: Text(a),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // 9. Map
                  Text(
                    'Map',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: HouseMapView(
                      houses: [house],
                      userLat: houses.userLat,
                      userLng: houses.userLng,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // 10. Owner information + actions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Owner / agent', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(house.ownerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(house.ownerPhone),
                        Text(house.ownerEmail, style: const TextStyle(color: AppColors.inkMuted)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final user = auth.currentUser;
                                  if (user != null) {
                                    houses.recordContact(user.id, house.id, 'call');
                                  }
                                  final uri = Uri(scheme: 'tel', path: house.ownerPhone);
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                                icon: const Icon(LucideIcons.phoneCall, size: 16),
                                label: const Text('Call'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                ),
                                onPressed: () => _whatsApp(house, auth.currentUser?.id),
                                icon: const Icon(LucideIcons.messageCircle, size: 16),
                                label: const Text('WhatsApp'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final user = auth.currentUser;
                              if (user == null) return;
                              houses.addInquiry(
                                houseId: house.id,
                                seekerId: user.id,
                                seekerName: user.fullName,
                                message:
                                    'Hi, I am interested in ${house.title}. Please contact me.',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inquiry sent to the owner')),
                              );
                            },
                            icon: const Icon(LucideIcons.send, size: 16),
                            label: const Text('Send Inquiry'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => houses.toggleFavorite(
                              house.id,
                              userId: auth.currentUser?.id,
                            ),
                            icon: Icon(
                              LucideIcons.heart,
                              size: 16,
                              color: fav ? AppColors.accent : AppColors.primary,
                            ),
                            label: Text(fav ? 'Remove Favorite' : 'Favorite'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (similar.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Similar Houses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Same area, type, similar price & bedrooms',
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ...similar.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HouseCard(
                          house: h,
                          matchPercent: houses.matchFor(h, auth.preferences),
                          distanceKm: houses.distanceTo(h),
                          isFavorite: houses.isFavorite(h.id),
                          onFavorite: () => houses.toggleFavorite(
                            h.id,
                            userId: auth.currentUser?.id,
                          ),
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HouseDetailScreen(houseId: h.id),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
