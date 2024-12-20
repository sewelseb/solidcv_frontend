import 'package:flutter/material.dart';

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  _MainBottomNavigationBarState createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if(index == 0) {
      Navigator.pushNamed(context, '/loggedin/home');
    } else if(index == 1) {
      Navigator.pushNamed(context, '/my-cv');
    } else if(index == 2) {
      Navigator.pushNamed(context, '/my-organisation');
    } else if(index == 3) {
      Navigator.pushNamed(context, '/verify-a-cv');
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //select the right _selectedIndex based on the current route
    if(ModalRoute.of(context)!.settings.name == '/loggedin/home') {
      _selectedIndex = 0;
    } else if(ModalRoute.of(context)!.settings.name == '/my-cv') {
      _selectedIndex = 1;
    } else if(ModalRoute.of(context)!.settings.name == '/my-organisation') {
      _selectedIndex = 2;
    } else if(ModalRoute.of(context)!.settings.name == '/verify-a-cv') {
      _selectedIndex = 3;
    }

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