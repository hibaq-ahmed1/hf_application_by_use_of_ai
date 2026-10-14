import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../common/change_password_screen.dart';
import 'favorites_screen.dart';
import 'preferences_screen.dart';
import 'search_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  String? _avatarUrl;

  static const avatars = [
    'https://i.pravatar.cc/150?u=house1',
    'https://i.pravatar.cc/150?u=house2',
    'https://i.pravatar.cc/150?u=house3',
    'https://i.pravatar.cc/150?u=house4',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _name = TextEditingController(text: user.fullName);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phone ?? '');
    _avatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final prefs = auth.preferences;

    return Scaffold(
      appBar: AppBar(title: const Text('House Seeker profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: _avatarUrl != null
                      ? CachedNetworkImageProvider(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null
                      ? Text(
                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(user.roleLabel, style: const TextStyle(color: AppColors.inkMuted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Profile picture', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: avatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final url = avatars[i];
                final selected = _avatarUrl == url;
                return GestureDetector(
                  onTap: () => setState(() => _avatarUrl = url),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: CachedNetworkImageProvider(url),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(LucideIcons.user, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(LucideIcons.mail, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(LucideIcons.phone, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              auth.updateProfile(
                fullName: _name.text,
                email: _email.text.trim().toLowerCase(),
                phone: _phone.text,
                avatarUrl: _avatarUrl,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save profile'),
          ),
          if (prefs != null) ...[
            const SizedBox(height: 22),
            const Text('Preference summary', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (prefs.preferredLocation != null)
                  Chip(label: Text(prefs.preferredLocation!)),
                if (prefs.minimumBudget != null || prefs.maximumBudget != null)
                  Chip(
                    label: Text(
                      'KSh ${prefs.minimumBudget?.toStringAsFixed(0) ?? '0'}–${prefs.maximumBudget?.toStringAsFixed(0) ?? '∞'}',
                    ),
                  ),
                if (prefs.houseType != null) Chip(label: Text(prefs.houseType!)),
                if (prefs.bedrooms != null) Chip(label: Text('${prefs.bedrooms} beds')),
                if (prefs.bathrooms != null) Chip(label: Text('${prefs.bathrooms}+ baths')),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _Tile(
            icon: LucideIcons.slidersHorizontal,
            title: 'House preferences',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreferencesScreen()),
            ),
          ),
          _Tile(
            icon: LucideIcons.heart,
            title: 'Saved favorites',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          _Tile(
            icon: LucideIcons.clock,
            title: 'Recently viewed',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecentlyViewedScreen()),
            ),
          ),
          _Tile(
            icon: LucideIcons.history,
            title: 'Search history',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchHistoryScreen()),
            ),
          ),
          _Tile(
            icon: LucideIcons.lock,
            title: 'Change password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.moon, color: AppColors.primary),
            title: const Text('Dark theme', style: TextStyle(fontWeight: FontWeight.w600)),
            value: context.watch<ThemeProvider>().mode == ThemeMode.dark,
            onChanged: (v) => context.read<ThemeProvider>().toggleDark(v),
          ),
          _Tile(
            icon: LucideIcons.logOut,
            title: 'Log out',
            danger: true,
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: danger ? AppColors.danger : AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: danger ? AppColors.danger : AppColors.ink,
        ),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }
}
