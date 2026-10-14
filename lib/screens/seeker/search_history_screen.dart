import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/house_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'search_screen.dart';

class SearchHistoryScreen extends StatelessWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final houses = context.watch<HouseProvider>();
    final history = houses.searchHistory;
    final fmt = DateFormat('MMM d · HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search history'),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: houses.clearSearchHistory,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: history.isEmpty
          ? const EmptyState(
              icon: LucideIcons.history,
              title: 'No searches yet',
              message: 'Town taps and keyword searches will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final e = history[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  tileColor: AppColors.surfaceElevated,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accentSoft,
                    child: Icon(LucideIcons.search, size: 16, color: AppColors.accent),
                  ),
                  title: Text(e.query, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    [
                      if (e.location != null) e.location!,
                      fmt.format(e.createdAt),
                    ].join(' · '),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  onTap: () {
                    houses.setSearchQuery(e.query);
                    if (e.location != null) {
                      houses.setFilter(houses.filter.copyWith(location: e.location));
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                );
              },
            ),
    );
  }
}
