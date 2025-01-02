import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class LoggedInHome extends StatelessWidget {
  const LoggedInHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: const Center(
        child: Text('Welcome to the Logged In Home Page!'),
      ),
    );
  }
}