import 'package:flutter/material.dart';

class AdminBottomNavigationBar extends StatefulWidget {
  const AdminBottomNavigationBar({super.key});

  @override
  State<AdminBottomNavigationBar> createState() =>
      _AdminBottomNavigationBarState();
}

class _AdminBottomNavigationBarState extends State<AdminBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/loggedin/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/admin/dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/admin/users');
        break;
      case 3:
        Navigator.pushNamed(context, '/admin/companies');
        break;
      case 4:
        Navigator.pushNamed(context, '/admin/institutions');
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == '/loggedin/home') {
      _selectedIndex = 0;
    } else if (currentRoute == '/admin/dashboard') {
      _selectedIndex = 1;
    } else if (currentRoute == '/admin/users') {
      _selectedIndex = 2;
    } else if (currentRoute == '/admin/companies') {
      _selectedIndex = 3;
    } else if (currentRoute == '/admin/institutions') {
      _selectedIndex = 4;
    }

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.grey),
          activeIcon: Icon(Icons.home, color: Colors.amber),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, color: Colors.grey),
          activeIcon: Icon(Icons.dashboard, color: Colors.amber),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people, color: Colors.grey),
          activeIcon: Icon(Icons.people, color: Colors.amber),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business, color: Colors.grey),
          activeIcon: Icon(Icons.business, color: Colors.amber),
          label: 'Companies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school, color: Colors.grey),
          activeIcon: Icon(Icons.school, color: Colors.amber),
          label: 'Institutions',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }
}
