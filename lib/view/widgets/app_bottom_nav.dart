import 'package:flutter/material.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
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
    const ChildrensScreen(),
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
          icon: const Icon(Icons.child_friendly),
          label: translate('Crianças'),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
