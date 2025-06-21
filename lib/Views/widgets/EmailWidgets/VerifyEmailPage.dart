import 'package:flutter/material.dart';
import 'package:solid_cv/Views/utils/RateLimitHelper.dart';
import 'package:solid_cv/Views/widgets/EmailWidgets/WidgetDesignElement/StyledDialog.dart';
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
  late final CooldownController _cooldown =
      CooldownController(maxTries: 2, cooldownSeconds: 60);
  final IUserBLL _userBLL = UserBll();

  @override
  void dispose() {
    _cooldown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 500;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B3FE4),
        elevation: 1,
        title: const Text("Verify email",
            style: TextStyle(fontWeight: FontWeight.w600)),
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
                child: AnimatedBuilder(
                  animation: _cooldown,
                  builder: (context, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 66, color: Color(0xFF7B3FE4)),
                      const SizedBox(height: 26),
                      Text(
                        "An email has been sent to:",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B3FE4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Click the link in the email to verify your account.",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15.3,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: (_isLoading || !_cooldown.canTry)
                              ? null
                              : _resendEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B3FE4),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.refresh, size: 22),
                          label: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _isLoading
                                ? const Text("Sending...")
                                : (_cooldown.isCooldown
                                    ? Text("Wait ${_cooldown.remaining}s")
                                    : const Text("Resend verification email")),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7B3FE4),
                            side: const BorderSide(
                                color: Color(0xFF7B3FE4), width: 1.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15.5),
                          ),
                          icon: const Icon(Icons.login, size: 20),
                          label: const Text("Back to login"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);

    try {
      final message = await _userBLL.resendEmailVerification(widget.email);

      if (!mounted) return;

      _cooldown.registerTry();

      showDialog(
        context: context,
        builder: (_) => StyledDialog(
          title: "Verify Email",
          content: message,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => StyledDialog(
          title: "Error",
          content: "Impossible to send email : $e",
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
