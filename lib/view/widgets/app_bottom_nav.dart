import 'package:flutter/material.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
import 'package:kids_space/view/screens/home_screen.dart';
import 'package:kids_space/view/screens/parents_screen.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const HomeScreen(),
    const ParentsScreen(),
    const ChildrensScreen(onlyActive: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFEEF1F7), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          height: 64,
          animationDuration: const Duration(milliseconds: 200),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: translate('app_bottom_nav.home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded),
              selectedIcon: const Icon(Icons.people_rounded),
              label: translate('app_bottom_nav.parents'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.child_care_outlined),
              selectedIcon: const Icon(Icons.child_care_rounded),
              label: translate('Crianças'),
            ),
          ],
        ),
      ),
    );
  }
}
