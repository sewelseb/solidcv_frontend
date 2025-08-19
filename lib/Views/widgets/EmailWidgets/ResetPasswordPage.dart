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
  bool _obscure = true;
  bool _showPasswordRequirements = false;

  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one capital letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    
    return null; // Password is valid
  }

  Widget _buildPasswordRequirements(String currentPassword) {
    final hasLength = currentPassword.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(currentPassword);
    final hasNumber = RegExp(r'[0-9]').hasMatch(currentPassword);
    final hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(currentPassword);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          _buildRequirementItem('At least 8 characters', hasLength),
          _buildRequirementItem('One capital letter', hasUppercase),
          _buildRequirementItem('One number', hasNumber),
          _buildRequirementItem('One special character', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("Reset password",
            style: TextStyle(fontWeight: FontWeight.w600)),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 46, color: Color(0xFF7B3FE4)),
                    const SizedBox(height: 14),
                    const Text(
                      "Set a new password",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Choose a strong password you haven't used before.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _pwController,
                      obscureText: _obscure,
                      onChanged: (value) {
                        setState(() {
                          _showPasswordRequirements = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "New password",
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
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF7B3FE4)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.deepPurple.shade200,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                    if (_showPasswordRequirements) 
                      _buildPasswordRequirements(_pwController.text),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: "Confirm password",
                        labelStyle: const TextStyle(color: Color(0xFF7B3FE4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF7B3FE4), width: 2),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF7B3FE4)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _resetPassword,
                        icon: _loading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline, size: 22),
                        label: const Text(
                          "Reset password",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
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

  Future<void> _resetPassword() async {
    final password = _pwController.text;
    final confirmPassword = _confirmController.text;

    // Validate password requirements
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    if (password != confirmPassword) {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text("Password Changed",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              "Your password has been updated. You can now log in.",
              textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("OK",
                  style: TextStyle(
                      color: Color(0xFF7B3FE4), fontWeight: FontWeight.w600)),
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
}
