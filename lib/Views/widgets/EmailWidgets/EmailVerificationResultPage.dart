import 'package:flutter/material.dart';

import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class EmailVerificationResultPage extends StatefulWidget {
    final String token;

  const EmailVerificationResultPage({super.key, required this.token});

  @override
  State<EmailVerificationResultPage> createState() =>
      _EmailVerificationResultPageState();
}

class _EmailVerificationResultPageState
    extends State<EmailVerificationResultPage> {
  String? message;
  bool? success;
 final IUserBLL _userBLL = UserBll();
 

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    if (widget.token.isEmpty) {
      setState(() {
        message = "Missing verification token in URL.";
        success = false;
      });
      return;
    }

    final result = await _userBLL.verifyEmail(widget.token);
    setState(() {
      message = result['message'];
      success = result['success'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email verification")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: message == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      success == true
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: success == true ? Colors.green : Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      message!,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Text("Go to login"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
