import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';

class RegisterRoute extends StatefulWidget {
  const RegisterRoute({super.key});

  @override
  State<RegisterRoute> createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordRequirements = false;
  bool _agreeToTerms = false;

  final IUserBLL _userBll = UserBll();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordConfirmationFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmationFocusNode.dispose();
    super.dispose();
  }

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
      margin: const EdgeInsets.only(top: 8),
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

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmationController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions to continue')),
      );
      return;
    }

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
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registering...')),
    );

    try {
      var user = User();
      user.email = email;
      user.password = password;

      user = await _userBll.createUser(user);
      Navigator.pushReplacementNamed(
        context,
        '/sent-verification-email',
        arguments: user.email ?? '',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight < 700 ? 700 : screenHeight,
              width: double.infinity,
              child: isMobile
                  ? _buildMobileLayout(screenWidth, screenHeight)
                  : _buildDesktopOrTabletLayout(
                      screenWidth, screenHeight, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/hero_image.png',
            width: double.infinity,
            height: screenHeight * (screenWidth < 400 ? 0.40 : 0.45),
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: _RegisterForm(
              isMobile: true,
              emailFocusNode: _emailFocusNode,
              passwordFocusNode: _passwordFocusNode,
              passwordConfirmationFocusNode: _passwordConfirmationFocusNode,
              obscurePassword: _obscurePassword,
              obscureConfirmPassword: _obscureConfirmPassword,
              onTogglePassword: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              onToggleConfirmPassword: () {
                setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
              emailController: _emailController,
              passwordController: _passwordController,
              passwordConfirmationController: _passwordConfirmationController,
              onRegisterPressed: _handleRegister,
              onPasswordChanged: (value) {
                setState(() {
                  _showPasswordRequirements = value.isNotEmpty;
                });
              },
              agreeToTerms: _agreeToTerms,
              onToggleTerms: () {
                setState(() => _agreeToTerms = !_agreeToTerms);
              },
              passwordRequirementsWidget: _showPasswordRequirements 
                ? _buildPasswordRequirements(_passwordController.text)
                : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopOrTabletLayout(
      double screenWidth, double screenHeight, bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: isTablet ? 5 : 2,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.03,
                0,
                screenWidth > 1200 ? 80 : 40,
                0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 400 : 420),
                child: _RegisterForm(
                  isMobile: false,
                  emailFocusNode: _emailFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  passwordConfirmationFocusNode: _passwordConfirmationFocusNode,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onToggleConfirmPassword: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  emailController: _emailController,
                  passwordController: _passwordController,
                  passwordConfirmationController:
                      _passwordConfirmationController,
                  onRegisterPressed: _handleRegister,
                  onPasswordChanged: (value) {
                    setState(() {
                      _showPasswordRequirements = value.isNotEmpty;
                    });
                  },
                  agreeToTerms: _agreeToTerms,
                  onToggleTerms: () {
                    setState(() => _agreeToTerms = !_agreeToTerms);
                  },
                  passwordRequirementsWidget: _showPasswordRequirements 
                    ? _buildPasswordRequirements(_passwordController.text)
                    : null,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: isTablet ? 5 : 3,
          child: Container(
            height: screenHeight,
            alignment: Alignment.center,
            color: Colors.white,
            child: Image.asset(
              'lib/assets/hero_image.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final bool isMobile;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final VoidCallback onRegisterPressed;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode passwordConfirmationFocusNode;
  final Function(String) onPasswordChanged;
  final Widget? passwordRequirementsWidget;
  final bool agreeToTerms;
  final VoidCallback onToggleTerms;

  const _RegisterForm({
    required this.isMobile,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.onRegisterPressed,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.passwordConfirmationFocusNode,
    required this.onPasswordChanged,
    required this.agreeToTerms,
    required this.onToggleTerms,
    this.passwordRequirementsWidget,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: isMobile ? 26 : 30,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final subtitleStyle = TextStyle(
      fontSize: isMobile ? 15 : 16,
      color: Colors.black54,
      height: 1.5,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text("Create a SolidCV Account",
            style: titleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 8),
        Text("Sign up to manage your verified credentials.",
            style: subtitleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 32),
        TextField(
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passwordFocusNode),
          decoration: InputDecoration(
            labelText: "Email address",
            hintText: "example@domain.com",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          focusNode: passwordFocusNode,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => FocusScope.of(context)
              .requestFocus(passwordConfirmationFocusNode),
          decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: onTogglePassword,
            ),
          ),
        ),
        if (passwordRequirementsWidget != null) passwordRequirementsWidget!,
        const SizedBox(height: 16),
        TextField(
          controller: passwordConfirmationController,
          obscureText: obscureConfirmPassword,
          focusNode: passwordConfirmationFocusNode,
          onSubmitted: (_) => onRegisterPressed(),
          decoration: InputDecoration(
            labelText: "Confirm password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscureConfirmPassword
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: onToggleConfirmPassword,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Terms and Conditions Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: agreeToTerms,
                onChanged: (_) => onToggleTerms(),
                activeColor: const Color(0xFF7B3FE4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: const TextStyle(
                        color: Color(0xFF7B3FE4),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Terms and Conditions page
                          Navigator.pushNamed(context, '/terms-and-conditions');
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: Color(0xFF7B3FE4),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Privacy Policy page
                          Navigator.pushNamed(context, '/privacy-policy');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: agreeToTerms ? onRegisterPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B3FE4),
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: const Text("Sign up", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account?",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Sign in",
                style: TextStyle(
                  color: Color(0xFF7B3FE4),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
