import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class VerifyACvRoute extends StatefulWidget {
  @override
  _VerifyACvRouteState createState() => _VerifyACvRouteState();
}

class _VerifyACvRouteState extends State<VerifyACvRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify a CV'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: Center(
        child: Text('Verify a CV Content'),
      ),
    );
  }
}