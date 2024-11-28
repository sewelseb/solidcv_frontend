import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class VerifyACvRoute extends StatefulWidget {
  const VerifyACvRoute({super.key});

  @override
  _VerifyACvRouteState createState() => _VerifyACvRouteState();
}

class _VerifyACvRouteState extends State<VerifyACvRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify a CV'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: const Center(
        child: Text('Verify a CV Content'),
      ),
    );
  }
}