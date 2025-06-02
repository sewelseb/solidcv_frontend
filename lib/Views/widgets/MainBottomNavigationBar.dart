import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  State<MainBottomNavigationBar> createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushNamed(context, '/loggedin/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/my-cv');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/my-organisation');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/verify-a-cv');
    } else if (index == 4) {
      await _logout();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    if (route == '/loggedin/home') _selectedIndex = 0;
    else if (route == '/my-cv') _selectedIndex = 1;
    else if (route == '/my-organisation') _selectedIndex = 2;
    else if (route == '/verify-a-cv') _selectedIndex = 3;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x337B3FE4),
                blurRadius: 14,
                offset: Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: isMobile ? 4 : 10,
            bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : (isMobile ? 4 : 10),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            iconSize: isMobile ? 26 : 30,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.badge_outlined),
                label: 'My CV',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                label: 'Organisation',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_outlined),
                label: 'Verify CV',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout_outlined),
                label: 'Logout',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Log out'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'jwt');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
