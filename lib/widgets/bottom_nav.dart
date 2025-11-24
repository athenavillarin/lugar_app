import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({Key? key, required this.currentIndex, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_nav/home_inactive.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          activeIcon: Image.asset(
            'assets/icons/bottom_nav/home_active.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_nav/favorites_inactive.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          activeIcon: Image.asset(
            'assets/icons/bottom_nav/favorites_active.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_nav/notifications_inactive.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          activeIcon: Image.asset(
            'assets/icons/bottom_nav/notifications_active.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_nav/profile_inactive.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          activeIcon: Image.asset(
            'assets/icons/bottom_nav/profile_active.png',
            width: 78,
            height: 57,
            filterQuality: FilterQuality.none,
          ),
          label: '',
        ),
      ],
    );
  }
}
