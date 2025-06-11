import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({required this.email, super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isLoading = false;
  final IUserBLL _userBLL = UserBll();

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);

    try {
      final message = await _userBLL.resendEmailVerification(widget.email);

      if (!mounted) return; 

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Verify Email"),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Impossible to send email : $e", textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify email")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                "An email has been sent to:",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                "Click the link in the email to verify your account.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _isLoading ? null : _resendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Resend verification email"),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.deepPurple,
                ),
                child: const Text("Back to login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
