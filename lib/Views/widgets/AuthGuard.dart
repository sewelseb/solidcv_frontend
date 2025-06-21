import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({required this.child, super.key});

  Future<bool> _isLoggedIn() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return child;
        } else {
          Future.microtask(() {
            Navigator.of(context).pushReplacementNamed('/');
          });
          return const Scaffold(); 
        }
      },
    );
  }
}
