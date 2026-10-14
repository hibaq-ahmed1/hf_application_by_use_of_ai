import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/features.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/house_card.dart';
import 'house_detail_screen.dart';
import 'map_screen.dart';
import 'nearby_screen.dart';
import 'search_history_screen.dart';
import 'smart_search_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool focusTowns;

  const SearchScreen({super.key, this.focusTowns = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _query;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: context.read<HouseProvider>().searchQuery);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final results = houses.filtered(prefs: auth.preferences);
    final filter = houses.filter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search houses'),
        actions: [
          IconButton(
            tooltip: 'AI Smart Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SmartSearchScreen()),
            ),
            icon: const Icon(LucideIcons.sparkles),
          ),
          IconButton(
            tooltip: 'Find near me',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyScreen()),
            ),
            icon: const Icon(LucideIcons.navigation),
          ),
          IconButton(
            tooltip: 'Map view',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MapScreen(houses: results)),
            ),
            icon: const Icon(LucideIcons.map),
          ),
          IconButton(
            tooltip: 'Search history',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchHistoryScreen()),
            ),
            icon: const Icon(LucideIcons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    textInputAction: TextInputAction.search,
                    onChanged: houses.setSearchQuery,
                    onSubmitted: (v) => houses.setSearchQuery(v, record: true),
                    decoration: const InputDecoration(
                      hintText: 'Manual search: town, address, type…',
                      prefixIcon: Icon(LucideIcons.search, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => FilterSheet(
                        initial: houses.filter,
                        onApply: houses.setFilter,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.slidersHorizontal, size: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Manual location',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<HouseSort>(
                    value: houses.sort,
                    items: HouseSort.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (s) {
                      if (s != null) houses.setSort(s);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const Text('By location', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kSearchTowns.map((town) {
                    final selected = filter.location == town;
                    return ChoiceChip(
                      label: Text(town),
                      selected: selected,
                      onSelected: (_) {
                        houses.setFilter(
                          selected
                              ? filter.copyWith(clearLocation: true)
                              : filter.copyWith(location: town),
                        );
                        houses.recordSearch(town, location: town);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('By price', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kPriceRanges.map((r) {
                    final selected = filter.minPrice == r.min && filter.maxPrice == r.max;
                    return ChoiceChip(
                      label: Text(r.label),
                      selected: selected,
                      onSelected: (_) {
                        houses.setFilter(
                          selected
                              ? filter.copyWith(clearPrice: true)
                              : filter.copyWith(minPrice: r.min, maxPrice: r.max),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('By bedrooms', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3, 4].map((n) {
                    final selected = filter.bedrooms == n;
                    return ChoiceChip(
                      label: Text(n == 4 ? '4+' : '$n'),
                      selected: selected,
                      onSelected: (_) {
                        houses.setFilter(
                          selected
                              ? filter.copyWith(clearBedrooms: true)
                              : filter.copyWith(bedrooms: n),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('By house type', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kHouseTypes.map((t) {
                    final selected = filter.houseType == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: selected,
                      onSelected: (_) {
                        houses.setFilter(
                          selected
                              ? filter.copyWith(clearHouseType: true)
                              : filter.copyWith(houseType: t),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${results.length} houses',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (filter.hasActiveFilters)
                      TextButton(
                        onPressed: houses.clearFilter,
                        child: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: EmptyState(
                      icon: LucideIcons.searchX,
                      title: 'No houses found',
                      message: 'Try another town (e.g. Kajiado) or a different price range.',
                    ),
                  )
                else
                  ...results.map((h) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: HouseCard(
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
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
