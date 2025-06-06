import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionValidatorTokenPage extends StatefulWidget {
  const SessionValidatorTokenPage({super.key});

  @override
  State<SessionValidatorTokenPage> createState() => _SessionValidatorTokenPageState();
}

class _SessionValidatorTokenPageState extends State<SessionValidatorTokenPage> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await storage.read(key: 'jwt');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/loggedin/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
