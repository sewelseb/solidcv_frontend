import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  const ResetPasswordPage({required this.token, super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _pwController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  Future<void> _resetPassword() async {
    if (_pwController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match.")));
      return;
    }
    setState(() => _loading = true);
    try {
      await UserBll().resetPassword(widget.token, _pwController.text.trim());
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Password Changed"),
          content: const Text("Your password has been updated. You can now log in."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset password")),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set your new password."),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New password"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm password"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _resetPassword,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Reset password"),
            ),
          ],
        ),
      ),
    );
  }
}
