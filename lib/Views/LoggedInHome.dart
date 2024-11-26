import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class LoggedInHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: Center(
        child: Text('Welcome to the Logged In Home Page!'),
      ),
    );
  }
}