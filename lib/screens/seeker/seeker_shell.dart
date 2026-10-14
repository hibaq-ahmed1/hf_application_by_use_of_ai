import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/house_provider.dart';
import 'favorites_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'seeker_home_screen.dart';

class SeekerShell extends StatefulWidget {
  const SeekerShell({super.key});

  @override
  State<SeekerShell> createState() => _SeekerShellState();
}

class _SeekerShellState extends State<SeekerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final houses = context.watch<HouseProvider>().availableHouses;

    final pages = [
      const SeekerHomeScreen(),
      const SearchScreen(),
      MapScreen(houses: houses),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
          NavigationDestination(icon: Icon(LucideIcons.search), label: 'Search'),
          NavigationDestination(icon: Icon(LucideIcons.map), label: 'Map'),
          NavigationDestination(icon: Icon(LucideIcons.heart), label: 'Favorites'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
