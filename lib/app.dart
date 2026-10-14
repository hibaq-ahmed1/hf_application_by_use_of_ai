import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/house_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_shell.dart';
import 'screens/seeker/seeker_shell.dart';
import 'theme/app_theme.dart';

class HouseFinderApp extends StatelessWidget {
  const HouseFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryRestoreSession()),
        ChangeNotifierProvider(create: (_) => HouseProvider()..startLiveLocation()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'House Finder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const LoginScreen();
    switch (user.role) {
      case UserRole.seeker:
        return const SeekerShell();
      case UserRole.owner:
        return const OwnerShell();
      case UserRole.admin:
        return const AdminShell();
    }
  }
}
