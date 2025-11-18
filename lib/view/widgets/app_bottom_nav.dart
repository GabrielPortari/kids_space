import 'package:flutter/material.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/home_screen.dart';
import 'package:kids_space/view/screens/users_screen.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const UsersScreen(),
    const SettingsScreen(),
  ];

  List<BottomNavigationBarItem> get _items => <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: translate('app_bottom_nav.home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: translate('app_bottom_nav.users'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: translate('app_bottom_nav.reports'),
        ),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Em desenvolvimento'));
  }
}
