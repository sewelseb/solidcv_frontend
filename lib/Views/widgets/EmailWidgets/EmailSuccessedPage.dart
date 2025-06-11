import 'package:flutter/material.dart';

class EmailVerifiedSuccessPage extends StatelessWidget {
  const EmailVerifiedSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email verified")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              "Your email has been verified!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text("Go to login"),
            ),
          ],
        ),
      ),
    );
  }
}
