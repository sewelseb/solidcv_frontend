import 'package:flutter/material.dart';

class MainBottomNavigationBar extends StatefulWidget {
  @override
  _MainBottomNavigationBarState createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.grey),
          activeIcon: Icon(Icons.home, color: Colors.amber),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.grey),
          activeIcon: Icon(Icons.person, color: Colors.amber),
          label: 'My CV',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business, color: Colors.grey),
          activeIcon: Icon(Icons.business, color: Colors.amber),
          label: 'My Organisation',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified, color: Colors.grey),
          activeIcon: Icon(Icons.verified, color: Colors.amber),
          label: 'Verify a CV',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }
}