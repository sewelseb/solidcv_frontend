import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  final IUserBLL _userBll = UserBll();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmationController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscription en cours...')),
    );

    try {
      var user = User();
      user.email = email;
      user.password = password;

      user = await _userBll.createUser(user);

      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: user.token);

      Navigator.pushNamed(context, '/loggedin/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'inscription : $e')),
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
        Text("Créer un compte SolidCV",
            style: titleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 8),
        Text("Inscrivez-vous pour gérer vos qualifications vérifiées.",
            style: subtitleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 32),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: "Adresse e-mail",
            hintText: "exemple@domaine.com",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: "Mot de passe",
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
        const SizedBox(height: 16),
        TextField(
          controller: passwordConfirmationController,
          obscureText: obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirmation du mot de passe",
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
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onRegisterPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B3FE4),
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: const Text("Créer mon compte",
              style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Déjà un compte ?",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Se connecter",
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
