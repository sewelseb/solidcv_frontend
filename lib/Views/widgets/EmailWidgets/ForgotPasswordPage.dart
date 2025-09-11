import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/RateLimitHelper.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final IUserBLL _userBLL = UserBll();
  bool _loading = false;

  late final CooldownController _cooldown =
      CooldownController(maxTries: 2, cooldownSeconds: 60);

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
        title: Text(AppLocalizations.of(context)!.forgotPassword,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF7B3FE4),
        centerTitle: true,
        elevation: 1,
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
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 38),
                child: AnimatedBuilder(
                  animation: _cooldown,
                  builder: (context, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_reset_rounded,
                          size: 48, color: Color(0xFF7B3FE4)),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.resetYourPassword,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.enterEmailForReset,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                          labelStyle: const TextStyle(color: Color(0xFF7B3FE4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: Color(0xFF7B3FE4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF7B3FE4), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Color(0xFF7B3FE4)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: (_loading || !_cooldown.canTry)
                              ? null
                              : _sendResetRequest,
                          icon: _loading
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.2, color: Colors.white))
                              : const Icon(Icons.lock_open_rounded, size: 22),
                          label: _loading
                              ? Text(AppLocalizations.of(context)!.sending,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))
                              : (_cooldown.isCooldown)
                                  ? Text(AppLocalizations.of(context)!.waitSeconds('${_cooldown.remaining}'),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600))
                                  : Text(AppLocalizations.of(context)!.sendResetEmail,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
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
      ),
    );
  }

  Future<void> _sendResetRequest() async {
    setState(() => _loading = true);
    try {
      await _userBLL.requestPasswordReset(_emailController.text.trim());

      _cooldown.registerTry();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(AppLocalizations.of(context)!.passwordResetTitle,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            AppLocalizations.of(context)!.passwordResetMessage,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok,
                    style: const TextStyle(
                        color: Color(0xFF7B3FE4), fontWeight: FontWeight.w600)))
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.failedWithError} $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}
