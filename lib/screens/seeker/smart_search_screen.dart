import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../services/smart_search_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/house_card.dart';
import 'house_detail_screen.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final _controller = TextEditingController(
    text:
        'I need a two bedroom house in Kitengela below 30,000 with parking and good security.',
  );
  List<String> _parsed = [];
  bool _ran = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _run() {
    final filter = SmartSearchService.parse(_controller.text);
    final auth = context.read<AuthProvider>();
    final houses = context.read<HouseProvider>();
    houses.setFilter(filter);
    houses.setSearchQuery('');
    houses.recordSearch(
      _controller.text.trim(),
      location: filter.location,
      userId: auth.currentUser?.id,
    );
    setState(() {
      _parsed = SmartSearchService.explain(filter);
      _ran = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final results = _ran ? houses.filtered(prefs: auth.preferences) : [];

    return Scaffold(
      appBar: AppBar(title: const Text('AI Smart Search')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.sparkles, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Describe the house you want. AI converts your sentence into search filters.',
                    style: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Describe the house you want',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _run,
            icon: const Icon(LucideIcons.sparkles, size: 18),
            label: const Text('Convert & search'),
          ),
          if (_parsed.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('AI converted to', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ..._parsed.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(LucideIcons.check, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(line),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${results.length} matching houses',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (results.isEmpty)
              const EmptyState(
                icon: LucideIcons.searchX,
                title: 'No matches',
                message: 'Try a broader description.',
              )
            else
              ...results.map((h) {
                return Padding(
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
        ],
      ),
    );
  }
}
