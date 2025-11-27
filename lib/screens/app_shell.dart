import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(),
      FavoritesScreen(),
      NotificationsScreen(),
      ProfileScreen(onNavigateToFavorites: () => _navigateToTab(1)),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
      ),
    );
  }
}
