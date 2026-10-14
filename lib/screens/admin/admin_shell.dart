import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/house.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../common/change_password_screen.dart';
import '../owner/add_edit_house_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          AdminAnalyticsScreen(),
          AdminHousesScreen(),
          AdminUsersScreen(),
          AdminReportsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.barChart3), label: 'Analytics'),
          NavigationDestination(icon: Icon(LucideIcons.building2), label: 'Houses'),
          NavigationDestination(icon: Icon(LucideIcons.users), label: 'Users'),
          NavigationDestination(icon: Icon(LucideIcons.shieldAlert), label: 'Reports'),
        ],
      ),
    );
  }
}

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final byTown = houses.listingsByTown.entries.toList();
    final trend = houses.priceTrendSample;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 20,
                20,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System control',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'House Finder',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Smart analytics across listings, users, and demand.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  label: 'Total users',
                  value: '${auth.allUsers.length}',
                  icon: LucideIcons.users,
                  color: AppColors.chartBlue,
                ),
                StatCard(
                  label: 'Total houses',
                  value: '${houses.totalListings}',
                  icon: LucideIcons.home,
                  color: AppColors.primary,
                ),
                StatCard(
                  label: 'Available',
                  value: '${houses.availableCount}',
                  icon: LucideIcons.checkCircle2,
                  color: AppColors.success,
                ),
                StatCard(
                  label: 'Rented',
                  value: '${houses.rentedCount}',
                  icon: LucideIcons.keyRound,
                  color: AppColors.chartAmber,
                ),
                StatCard(
                  label: 'Inquiries',
                  value: '${houses.inquiryCount}',
                  icon: LucideIcons.messageSquare,
                  color: AppColors.accent,
                ),
                StatCard(
                  label: 'Reported',
                  value: '${houses.reportedCount}',
                  icon: LucideIcons.flag,
                  color: AppColors.danger,
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  if (houses.mostViewedHouse != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.eye, color: AppColors.primary),
                      title: const Text('Most viewed'),
                      subtitle: Text(houses.mostViewedHouse!.title),
                      trailing: Text('${houses.mostViewedHouse!.viewCount}'),
                    ),
                  if (houses.mostFavoritedHouse != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.heart, color: AppColors.danger),
                      title: const Text('Most favorited'),
                      subtitle: Text(houses.mostFavoritedHouse!.title),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Most searched locations',
                subtitle: 'Town demand monitor',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: houses.mostSearchedLocations.entries.take(6).map((e) {
                  return Chip(
                    avatar: const Icon(LucideIcons.mapPin, size: 14),
                    label: Text('${e.key} · ${e.value}'),
                  );
                }).toList(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Popular houses',
                subtitle: 'Highest view counts',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverList.separated(
              itemCount: houses.popularHouses.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final h = houses.popularHouses[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  tileColor: AppColors.surfaceElevated,
                  title: Text(h.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${h.location} · ${h.viewCount} views'),
                  trailing: Text(formatKes(h.price)),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Weekly interest',
                subtitle: 'Seeker activity trend',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 200,
                padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: AppColors.inkMuted),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final i = v.toInt();
                            if (i < 0 || i >= days.length) return const SizedBox.shrink();
                            return Text(days[i], style: const TextStyle(fontSize: 11));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < trend.length; i++)
                            FlSpot(i.toDouble(), trend[i]),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Listings by town',
                subtitle: 'Geographic distribution',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= byTown.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                byTown[i].key.substring(0, 3),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < byTown.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: byTown[i].value.toDouble(),
                              width: 16,
                              borderRadius: BorderRadius.circular(6),
                              color: [
                                AppColors.primary,
                                AppColors.chartBlue,
                                AppColors.accent,
                                AppColors.chartAmber,
                                AppColors.success,
                                AppColors.primaryLight,
                              ][i % 6],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminHousesScreen extends StatelessWidget {
  const AdminHousesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final houses = context.watch<HouseProvider>();
    final list = houses.houses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage houses'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditHouseScreen()),
            ),
            icon: const Icon(LucideIcons.plus),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final h = list[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: h.images.first,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(h.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${formatKes(h.price)} · ${h.location} · ${h.availabilityLabel}'
                '${h.approved ? '' : ' · Unapproved'}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddEditHouseScreen(house: h)),
                      );
                    case 'approve':
                      houses.setApproved(h.id, true);
                    case 'remove_approval':
                      houses.setApproved(h.id, false);
                    case 'available':
                      houses.setAvailability(h.id, HouseAvailability.available);
                    case 'rented':
                      houses.setAvailability(h.id, HouseAvailability.rented);
                    case 'delete':
                      houses.deleteHouse(h.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!h.approved)
                    const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  if (h.approved)
                    const PopupMenuItem(
                      value: 'remove_approval',
                      child: Text('Unpublish'),
                    ),
                  const PopupMenuItem(value: 'available', child: Text('Mark available')),
                  const PopupMenuItem(value: 'rented', child: Text('Mark rented')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final users = auth.allUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage users')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final u = users[i];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            tileColor: AppColors.surfaceElevated,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                u.fullName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(u.fullName),
            subtitle: Text('${u.email}\n${u.roleLabel}'),
            isThreeLine: true,
            trailing: u.role == UserRole.admin
                ? const Chip(label: Text('Admin'))
                : IconButton(
                    icon: const Icon(LucideIcons.trash2, color: AppColors.danger, size: 18),
                    onPressed: () => auth.deleteUser(u.id),
                  ),
          );
        },
      ),
    );
  }
}

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _categoryCtrl = TextEditingController();

  @override
  void dispose() {
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final reported = houses.reportedHouses;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & categories')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Reported listings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          if (reported.isEmpty)
            const Text('No reported properties.', style: TextStyle(color: AppColors.inkMuted))
          else
            ...reported.map((h) {
              return Card(
                child: ListTile(
                  title: Text(h.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(h.reportReason ?? 'Reported'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'clear') houses.clearReport(h.id);
                      if (v == 'delete') houses.deleteHouse(h.id);
                      if (v == 'reject') houses.setApproved(h.id, false);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'clear', child: Text('Clear report')),
                      PopupMenuItem(value: 'reject', child: Text('Unpublish')),
                      PopupMenuItem(value: 'delete', child: Text('Delete listing')),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 22),
          const Text('Manage categories', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(hintText: 'New category name'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  houses.addCategory(_categoryCtrl.text);
                  _categoryCtrl.clear();
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: houses.categories
                .map(
                  (c) => InputChip(
                    label: Text(c),
                    onDeleted: () => houses.removeCategory(c),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.lock, color: AppColors.primary),
            title: const Text('Change password'),
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.moon, color: AppColors.primary),
            title: const Text('Dark theme'),
            value: context.watch<ThemeProvider>().mode == ThemeMode.dark,
            onChanged: (v) => context.read<ThemeProvider>().toggleDark(v),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.logOut, color: AppColors.danger),
            title: const Text('Log out', style: TextStyle(color: AppColors.danger)),
            onTap: () async {
              Navigator.of(context).popUntil((r) => r.isFirst);
              await auth.logout();
            },
          ),
        ],
      ),
    );
  }
}
