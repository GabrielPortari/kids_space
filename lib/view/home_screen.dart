import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	int _selectedIndex = 0;

	static const List<Widget> _pages = <Widget>[
		Center(child: Text('Página 1')),
		Center(child: Text('Página 2')),
		Center(child: Text('Página 3')),
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
				items: const <BottomNavigationBarItem>[
					BottomNavigationBarItem(
						icon: Icon(Icons.home),
						label: 'Início',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.business),
						label: 'Empresas',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.settings),
						label: 'Configurações',
					),
				],
				currentIndex: _selectedIndex,
				selectedItemColor: Colors.deepPurple,
				onTap: _onItemTapped,
			),
		);
	}
}
