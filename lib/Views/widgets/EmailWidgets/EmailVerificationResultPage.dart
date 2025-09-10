import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B3FE4),
        elevation: 1,
        title: Text(AppLocalizations.of(context)!.emailVerification,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: Colors.white,
              elevation: 7,
              margin: EdgeInsets.symmetric(
                  horizontal: isWide ? 0 : 18, vertical: 22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
                child: message == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            success == true
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: success == true
                                ? Colors.green
                                : const Color(0xFFB00020),
                            size: 64,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            success == true
                                ? AppLocalizations.of(context)!.emailVerified
                                : AppLocalizations.of(context)!.verificationFailed,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: success == true
                                  ? Colors.green.shade700
                                  : const Color(0xFFB00020),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              icon: const Icon(Icons.login, size: 21),
                              label: Text(
                                AppLocalizations.of(context)!.goToLogin,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B3FE4),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyEmail() async {
    if (widget.token.isEmpty) {
      setState(() {
        message = AppLocalizations.of(context)!.missingVerificationToken;
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
}
