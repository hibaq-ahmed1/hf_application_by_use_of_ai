import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/house.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../common/change_password_screen.dart';
import 'add_edit_house_screen.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          OwnerDashboardScreen(),
          OwnerListingsScreen(),
          OwnerInquiriesScreen(),
          OwnerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(LucideIcons.building2), label: 'Listings'),
          NavigationDestination(icon: Icon(LucideIcons.messageSquare), label: 'Inquiries'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditHouseScreen()),
              ),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add house'),
            )
          : null,
    );
  }
}

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final mine = houses.listingsForOwner(auth.currentUser!.id);
    final available = mine.where((h) => h.isAvailable).length;
    final rented = mine.where((h) => h.availability == HouseAvailability.rented).length;
    final inquiries = houses.inquiriesForOwner(auth.currentUser!.id).length;

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
                    'Owner workspace',
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
                    'Manage listings, photos, and tenant inquiries.',
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
              childAspectRatio: 1.15,
              children: [
                StatCard(
                  label: 'My listings',
                  value: '${mine.length}',
                  icon: LucideIcons.building2,
                  color: AppColors.primary,
                ),
                StatCard(
                  label: 'Available',
                  value: '$available',
                  icon: LucideIcons.checkCircle2,
                  color: AppColors.success,
                ),
                StatCard(
                  label: 'Rented',
                  value: '$rented',
                  icon: LucideIcons.keyRound,
                  color: AppColors.warning,
                ),
                StatCard(
                  label: 'Inquiries',
                  value: '$inquiries',
                  icon: LucideIcons.messageSquare,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditHouseScreen()),
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Add new house listing'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerListingsScreen extends StatelessWidget {
  const OwnerListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final mine = houses.listingsForOwner(auth.currentUser!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      body: mine.isEmpty
          ? EmptyState(
              icon: LucideIcons.building,
              title: 'No listings yet',
              message: 'Add your first house to reach seekers on House Finder.',
              action: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditHouseScreen()),
                ),
                child: const Text('Add house'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mine.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final h = mine[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: h.images.first,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(h.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${formatKes(h.price)} · ${h.location}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditHouseScreen(house: h),
                                ),
                              );
                            } else if (v == 'available') {
                              houses.setAvailability(h.id, HouseAvailability.available);
                            } else if (v == 'rented') {
                              houses.setAvailability(h.id, HouseAvailability.rented);
                            } else if (v == 'delete') {
                              houses.deleteHouse(h.id);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'available', child: Text('Mark available')),
                            PopupMenuItem(value: 'rented', child: Text('Mark rented')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            Chip(
                              label: Text(h.availabilityLabel),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${h.bedrooms} bed · ${h.bathrooms} bath',
                              style: const TextStyle(
                                color: AppColors.inkMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class OwnerInquiriesScreen extends StatelessWidget {
  const OwnerInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final houses = context.watch<HouseProvider>();
    final items = houses.inquiriesForOwner(auth.currentUser!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Inquiries')),
      body: items.isEmpty
          ? const EmptyState(
              icon: LucideIcons.inbox,
              title: 'No inquiries yet',
              message: 'When seekers contact you, messages show up here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = items[i];
                final house = houses.byId(item.houseId);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.seekerName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(house?.title ?? 'House', style: const TextStyle(color: AppColors.inkMuted)),
                      const SizedBox(height: 8),
                      Text(item.message),
                      if (item.ownerReply != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Your reply: ${item.ownerReply}'),
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              final controller = TextEditingController();
                              final reply = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Respond to seeker'),
                                  content: TextField(
                                    controller: controller,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Write your reply…',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                      child: const Text('Send'),
                                    ),
                                  ],
                                ),
                              );
                              if (reply != null && reply.isNotEmpty) {
                                houses.replyToInquiry(item.id, reply);
                              }
                            },
                            icon: const Icon(LucideIcons.reply, size: 16),
                            label: const Text('Respond'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class OwnerProfileTab extends StatelessWidget {
  const OwnerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(user.email, style: const TextStyle(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          Text(user.roleLabel),
          const SizedBox(height: 24),
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
