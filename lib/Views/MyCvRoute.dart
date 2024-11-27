import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class MyCvRoute extends StatefulWidget {
  @override
  State<MyCvRoute> createState() => _MyCvRouteState();
}

class _MyCvRouteState extends State<MyCvRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My CV'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: Center(
        child: Text('Welcome to My CV Page!'),
      ),
    );
  }
}