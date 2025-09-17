import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/Views/widgets/LanguageSelector.dart';
import 'package:solid_cv/providers/LanguageProvider.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  bool _obscurePassword = true;
  final IUserBLL _userBll = UserBll();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isCheckingAuth = true;
  bool _userAlreadyConnected = false;
  final LanguageProvider _languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
    _languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      // Rebuild when language changes
    });
  }

  void _changeLanguage(Locale locale) {
    _languageProvider.setLocale(locale);
  }

  Future<void> _checkUserAuthentication() async {
    try {
      // const storage = FlutterSecureStorage();
      // final token = await storage.read(key: 'jwt');
      // final currentRoute = ModalRoute.of(context)?.settings.name;
      
      // if (token != null && token.isNotEmpty && currentRoute == '/') {
      //   // Try to get current user with the stored token
      //   final user = await _userBll.getCurrentUser();
      //   if (user != null) {
      //     // User is authenticated, redirect to logged-in home
      //     setState(() {
      //       _userAlreadyConnected = true;
      //     });
          
      //     // Use addPostFrameCallback to ensure navigation happens after build
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       Navigator.pushReplacementNamed(context, '/loggedin/home');
      //     });
      //     return;
      //   }
      // }
    } catch (e) {
      // Token is invalid or user is not authenticated
      // Clear the invalid token
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'jwt');
    }
    
    setState(() {
      _isCheckingAuth = false;
    });
  }

  Future<void> _handleLogin() async {
    final localizations = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseFillAllFields)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.signingIn)),
    );

    try {
      var user = User();
      user.email = email;
      user.password = password;

      user = await _userBll.login(user);

      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: user.token);

      Navigator.pushReplacementNamed(context, '/loggedin/home');
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('email not verified')) {
        Navigator.pushReplacementNamed(context, '/sent-verification-email',
            arguments: email);
        return;
      }
      if (errorMessage.contains('invalid credentials')) {
        errorMessage = localizations.incorrectEmailOrPassword;
      } else if (errorMessage.contains('missing credentials')) {
        errorMessage = localizations.accountDoesNotExist;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking authentication
    if (_isCheckingAuth) {
      final localizations = AppLocalizations.of(context)!;
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF7B3FE4),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.checkingAuthentication,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading indicator while redirecting authenticated user
    if (_userAlreadyConnected) {
      final localizations = AppLocalizations.of(context)!;
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF7B3FE4),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.redirectingToHome,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    height: isMobile ? null : (screenHeight < 700 ? 700 : screenHeight),
                  width: double.infinity,
                  child: isMobile
                      ? _buildMobileLayout(screenWidth, screenHeight)
                      : _buildDesktopOrTabletLayout(
                          screenWidth, screenHeight, isTablet),
                ),
                const AIFeaturesSection(), // New AI Features section
                const AboutUsSection(),
                const TargetAudienceSection(),
                //const PricingSection(),
                const ContactUsSection(),
              ],
            ),
          ),
          // Language selector positioned in top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: LanguageSelector(
                onLanguageChanged: _changeLanguage,
                currentLocale: _languageProvider.locale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
  return Column(
    children: [
      // Image section - fixed height
      SizedBox(
        height: screenHeight * 0.35, // Fixed 35% of screen height for image
        width: double.infinity,
        child: Image.asset(
          'lib/assets/hero_image.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      // Form section - flexible height based on content
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: _LoginForm(
          isMobile: true,
          obscurePassword: _obscurePassword,
          onTogglePassword: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          emailController: _emailController,
          passwordController: _passwordController,
          emailFocusNode: _emailFocusNode,
          passwordFocusNode: _passwordFocusNode,
          onLoginPressed: _handleLogin,
        ),
      ),
    ],
  );
}

  Widget _buildDesktopOrTabletLayout(
      double screenWidth, double screenHeight, bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: isTablet ? 5 : 2,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 400 : 420,
                maxHeight: screenHeight * 0.8,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: 20,
                ),
                child: _LoginForm(
                  isMobile: false,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocusNode: _emailFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  onLoginPressed: _handleLogin,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: isTablet ? 5 : 3,
          child: Container(
            height: double.infinity,
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

class _LoginForm extends StatelessWidget {
  final bool isMobile;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  const _LoginForm({
    required this.isMobile,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
    required this.emailFocusNode,
    required this.passwordFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: isMobile ? 22 : 30, // Slightly smaller on mobile
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final subtitleStyle = TextStyle(
      fontSize: isMobile ? 13 : 16, // Smaller on mobile
      color: Colors.black54,
      height: 1.3, // Tighter line height
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.welcomeToSolidCV,
            style: titleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        SizedBox(height: isMobile ? 4 : 8), // Reduced spacing
        Text(AppLocalizations.of(context)!.signInToUnlock,
            style: subtitleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        SizedBox(height: isMobile ? 20 : 32), // Reduced spacing
        TextField(
          controller: emailController,
          focusNode: emailFocusNode,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passwordFocusNode),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.emailAddress,
            hintText: AppLocalizations.of(context)!.emailPlaceholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 10 : 16, // Reduced mobile padding
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: isMobile ? 10 : 16), // Reduced spacing
        TextField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          onSubmitted: (_) => onLoginPressed(),
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.password,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 10 : 16, // Reduced mobile padding
            ),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 12), // Reduced spacing
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: Text(AppLocalizations.of(context)!.forgotPassword,
                style: const TextStyle(color: Color(0xFF7B3FE4), fontSize: 13)), // Smaller text
          ),
        ),
        SizedBox(height: isMobile ? 12 : 24), // Reduced spacing
        ElevatedButton(
          onPressed: onLoginPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B3FE4),
            minimumSize: Size(double.infinity, isMobile ? 44 : 50), // Slightly smaller mobile button
            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 16), // Reduced mobile padding
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: Text(AppLocalizations.of(context)!.signIn, style: const TextStyle(color: Colors.white)),
        ),
        SizedBox(height: isMobile ? 12 : 24), // Reduced spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.dontHaveAccount,
                style: const TextStyle(fontSize: 13, color: Colors.black54)), // Smaller text
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(
                AppLocalizations.of(context)!.register,
                style: const TextStyle(
                  color: Color(0xFF7B3FE4),
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // Smaller text
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 20), // Increased spacing for new button
        // Job Offers Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/jobs');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7B3FE4),
              side: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
              minimumSize: Size(double.infinity, isMobile ? 44 : 50),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            icon: const Icon(Icons.work_outline),
            label: Text(AppLocalizations.of(context)!.browseJobOpportunities),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 10), // Reduced spacing
        const _PrivacyPolicyLink(),
      ],
    );
  }
}

// NEW AI FEATURES SECTION
class AIFeaturesSection extends StatelessWidget {
  const AIFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B3FE4).withOpacity(0.05),
            const Color(0xFF9D50BB).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 48 : 64,
        horizontal: isMobile ? 16 : 24,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FE4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7B3FE4).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFF7B3FE4),
                  size: isMobile ? 18 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.aiPoweredFeatures,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7B3FE4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            AppLocalizations.of(context)!.superchargeYourCareer,
            style: TextStyle(
              fontSize: isMobile ? 26 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
            child: Text(
              AppLocalizations.of(context)!.leverageCuttingEdgeAI,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 40 : 56),
          
          // AI Features Grid
          isMobile 
            ? Column(
                mainAxisSize: MainAxisSize.min, // Add this
                children: [
                  _AIFeatureCard(
                    icon: Icons.verified_user,
                    title: AppLocalizations.of(context)!.aiSkillValidation,
                    description: AppLocalizations.of(context)!.aiSkillValidationDescription,
                    color: Colors.blue,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),
                  _AIFeatureCard(
                    icon: Icons.psychology,
                    title: AppLocalizations.of(context)!.aiCareerAdvisor,
                    description: AppLocalizations.of(context)!.aiCareerAdvisorDescription,
                    color: Colors.orange,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),
                  _AIFeatureCard(
                    icon: Icons.analytics,
                    title: AppLocalizations.of(context)!.aiJobMatching,
                    description: AppLocalizations.of(context)!.aiJobMatchingDescription,
                    color: Colors.green,
                    isMobile: isMobile,
                  ),
                ],
              )
            : Wrap(
                spacing: 24,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  _AIFeatureCard(
                    icon: Icons.verified_user,
                    title: AppLocalizations.of(context)!.aiSkillValidation,
                    description: AppLocalizations.of(context)!.aiSkillValidationDescription,
                    color: Colors.blue,
                    isMobile: isMobile,
                  ),
                  _AIFeatureCard(
                    icon: Icons.psychology,
                    title: AppLocalizations.of(context)!.aiCareerAdvisor,
                    description: AppLocalizations.of(context)!.aiCareerAdvisorDescription,
                    color: Colors.orange,
                    isMobile: isMobile,
                  ),
                  _AIFeatureCard(
                    icon: Icons.analytics,
                    title: AppLocalizations.of(context)!.aiJobMatching,
                    description: AppLocalizations.of(context)!.aiJobMatchingDescription,
                    color: Colors.green,
                    isMobile: isMobile,
                  ),
                ],
              ),
          
          SizedBox(height: isMobile ? 40 : 56),
          
          // CTA Section
          Container(
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B3FE4), Color(0xFF9D50BB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B3FE4).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: isMobile ? 40 : 48,
                ),
                SizedBox(height: isMobile ? 16 : 20),
                Text(
                  "Ready to Transform Your Career?",
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  "Join thousands of professionals who are already using AI to accelerate their career growth.",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 24 : 32),
                isMobile
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF7B3FE4),
                              minimumSize: const Size(double.infinity, 50),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(Icons.person_add),
                            label: const Text("Get Started Free"),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/jobs');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              minimumSize: const Size(double.infinity, 50),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(Icons.explore),
                            label: const Text("Explore Job Opportunities"),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7B3FE4),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.person_add),
                          label: const Text("Get Started Free"),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/jobs');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.explore),
                          label: const Text("Explore Jobs"),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          
          SizedBox(height: isMobile ? 48 : 64),
          const _SectionDivider(),
        ],
      ),
    );
  }
}

class _AIFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isMobile;

  const _AIFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : 320,
      constraints: BoxConstraints(
        maxWidth: isMobile ? MediaQuery.of(context).size.width - 32 : 320,
        minHeight: isMobile ? 200 : 240,
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Add this to prevent unbounded height
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 28 : 32,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Flexible( // Wrap Text with Flexible instead of using Spacer
            child: Text(
              description,
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20), // Fixed spacing instead of Spacer
        ],
      ),
    );
  }
}

// --- EXISTING SECTIONS (keeping the same) ---

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Container(
      color: const Color(0xFFF9F6FC),
      padding:
          EdgeInsets.symmetric(
            vertical: isMobile ? 48 : 64, 
            horizontal: isMobile ? 16 : 24
          ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.discoverSolidCV,
            style: TextStyle(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 48),
          _AboutUsBlock(
            imagePath: 'lib/assets/section1.png',
            title: AppLocalizations.of(context)!.reinventingTrustRecruitment,
            description: AppLocalizations.of(context)!.reinventingTrustDescription,
            reverse: false,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 48 : 64),
          const _SectionDivider(),
          SizedBox(height: isMobile ? 48 : 64),
          _AboutUsBlock(
            imagePath: 'lib/assets/section2.png',
            title: AppLocalizations.of(context)!.blockchainRevolutionDiplomas,
            description: AppLocalizations.of(context)!.blockchainRevolutionDescription,
            reverse: true,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 48 : 64),
          const _SectionDivider(),
          SizedBox(height: isMobile ? 48 : 64),
          _AboutUsBlock(
            imagePath: 'lib/assets/section3.png',
            title: AppLocalizations.of(context)!.virtuousEcosystemStakeholders,
            description: AppLocalizations.of(context)!.virtuousEcosystemDescription,
            reverse: false,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }
}

class _AboutUsBlock extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool reverse;
  final bool isMobile;

  const _AboutUsBlock({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.reverse,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double imageMaxWidth = min(320, screenWidth * 0.45);
    if (screenWidth >= 1200) {
      imageMaxWidth = 320;
    } else if (screenWidth >= 900) {
      imageMaxWidth = 280;
    } else {
      imageMaxWidth = screenWidth * 0.6;
    }

    Widget imageWidget = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: imageMaxWidth,
        maxHeight: 300,
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );

    Widget textWidget = Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? screenWidth * 0.95 : 500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              height: 1.6,
              color: Colors.black54,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
        ],
      ),
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            imageWidget,
            const SizedBox(height: 24),
            textWidget,
          ],
        ),
      );
    } else {
      final children = reverse
          ? [textWidget, const SizedBox(width: 40), imageWidget]
          : [imageWidget, const SizedBox(width: 40), textWidget];

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children.map((child) {
              return Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: child,
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final double horizontal =
            constraints.maxWidth > 800 ? constraints.maxWidth * 0.15 : 24;
        return Divider(
          thickness: 1,
          color: Colors.deepPurple.shade100,
          indent: horizontal,
          endIndent: horizontal,
        );
      },
    );
  }
}

class TargetAudienceSection extends StatelessWidget {
  const TargetAudienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: Colors.white,
      padding:
          EdgeInsets.symmetric(
            vertical: isMobile ? 48 : 64, 
            horizontal: isMobile ? 16 : 32
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.whoIsSolidCVFor,
            style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 48),
          isMobile 
            ? Column(
                children: [
                  _TargetCard(
                    title: AppLocalizations.of(context)!.forAllProfessionals,
                    description: AppLocalizations.of(context)!.forAllProfessionalsDescription,
                    imagePath: 'lib/assets/user.png',
                  ),
                  const SizedBox(height: 32),
                  _TargetCard(
                    title: AppLocalizations.of(context)!.forCompanies,
                    description: AppLocalizations.of(context)!.forCompaniesDescription,
                    imagePath: 'lib/assets/company.png',
                  ),
                  const SizedBox(height: 32),
                  _TargetCard(
                    title: AppLocalizations.of(context)!.forEducationalInstitutions,
                    description: AppLocalizations.of(context)!.forEducationalInstitutionsDescription,
                    imagePath: 'lib/assets/institution.png',
                  ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 32,
                children: [
                  _TargetCard(
                    title: AppLocalizations.of(context)!.forAllProfessionals,
                    description: AppLocalizations.of(context)!.forAllProfessionalsDescription,
                    imagePath: 'lib/assets/user.png',
                  ),
                  _TargetCard(
                    title: AppLocalizations.of(context)!.forCompanies,
                    description: AppLocalizations.of(context)!.forCompaniesDescription,
                    imagePath: 'lib/assets/company.png',
                  ),
                  _TargetCard(
                    title: AppLocalizations.of(context)!.forEducationalInstitutions,
                    description: AppLocalizations.of(context)!.forEducationalInstitutionsDescription,
                    imagePath: 'lib/assets/institution.png',
                  ),
                ],
              ),
          SizedBox(height: isMobile ? 48 : 64),
          const _SectionDivider(),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const _TargetCard({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isEducationCard = title.contains("Educational Institutions");
    final isCompanyCard = title.contains("For Companies");
    
    return Container(
      width: isMobile ? double.infinity : 280,
      constraints: BoxConstraints(
        maxWidth: isMobile ? MediaQuery.of(context).size.width - 32 : 280,
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: isMobile ? 140 : 160),
          SizedBox(height: isMobile ? 12 : 16),
          Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isMobile ? 16 : 18
              ),
              textAlign: TextAlign.center),
          SizedBox(height: isMobile ? 8 : 12),
          Text(description,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14, 
                color: Colors.black54,
                height: 1.4
              ),
              textAlign: TextAlign.center),
          if (isEducationCard) ...[
            SizedBox(height: isMobile ? 16 : 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/education-institutions');
                },
                icon: const Icon(Icons.school, size: 16),
                label: const Text('Learn More'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7B3FE4),
                  side: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (isCompanyCard) ...[
            SizedBox(height: isMobile ? 16 : 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/companies');
                },
                icon: const Icon(Icons.business, size: 16),
                label: const Text('Explore Solutions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7B3FE4),
                  side: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 24 : 34,
        horizontal: isMobile ? 16 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Our Flexible Offers",
            style: TextStyle(
              fontSize: isMobile ? 24 : 28, 
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Center(
            child: isMobile 
              ? const Column(
                  children: [
                    _UnifiedPricingCard(
                      title: "User",
                      freeFeatures: ["Create and share your CV", "AI Career Advisor", "Basic job matching"],
                      paidFeatures: [
                        "Advanced AI skill validation",
                        "Premium CV analytics and insights",
                        "Priority AI career advice",
                        "Premium CV templates",
                      ],
                      price: "4,99€",
                    ),
                    SizedBox(height: 24),
                    _UnifiedPricingCard(
                      title: "Institution",
                      freeFeatures: ["Issue credentials to users", "Basic verification tools"],
                      paidFeatures: [
                        "AI-powered credential verification",
                        "Advanced statistics on certification usage",
                        "Bulk credential management",
                      ],
                      price: "4,99€",
                    ),
                    SizedBox(height: 24),
                    _UnifiedPricingCard(
                      title: "Company",
                      freeFeatures: [
                        "Issue credentials to users",
                        "Verify CVs",
                        "Basic candidate matching",
                      ],
                      paidFeatures: ["AI-enhanced recruitment analytics", "Advanced candidate compatibility scoring"],
                      price: "4,99€ / 49,99€",
                    ),
                  ],
                )
              : const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 32,
                  children: [
                    _UnifiedPricingCard(
                      title: "User",
                      freeFeatures: ["Create and share your CV", "AI Career Advisor", "Basic job matching"],
                      paidFeatures: [
                        "Advanced AI skill validation",
                        "Premium CV analytics and insights",
                        "Priority AI career advice",
                        "Premium CV templates",
                      ],
                      price: "4,99€",
                    ),
                    _UnifiedPricingCard(
                      title: "Institution",
                      freeFeatures: ["Issue credentials to users", "Basic verification tools"],
                      paidFeatures: [
                        "AI-powered credential verification",
                        "Advanced statistics on certification usage",
                        "Bulk credential management",
                      ],
                      price: "4,99€",
                    ),
                    _UnifiedPricingCard(
                      title: "Company",
                      freeFeatures: [
                        "Issue credentials to users",
                        "Verify CVs",
                        "Basic candidate matching",
                      ],
                      paidFeatures: ["AI-enhanced recruitment analytics", "Advanced candidate compatibility scoring"],
                      price: "4,99€ / 49,99€",
                    ),
                  ],
                ),
          ),
          SizedBox(height: isMobile ? 48 : 64),
          const _SectionDivider(),
        ],
      ),
    );
  }
}

class _UnifiedPricingCard extends StatelessWidget {
  final String title;
  final List<String> freeFeatures;
  final List<String> paidFeatures;
  final String price;

  const _UnifiedPricingCard({
    required this.title,
    required this.freeFeatures,
    required this.paidFeatures,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isCompany = title.toLowerCase() == "company";

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isMobile ? 400 : 540,
        maxWidth: isMobile ? double.infinity : 340,
      ),
      child: Container(
        width: isMobile ? double.infinity : 340,
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.deepPurple.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade50,
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: isMobile ? 8 : 12),
            Text("Included for free",
                style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600)),
            SizedBox(height: isMobile ? 6 : 8),
            ...freeFeatures.map((f) => _featureRow(f, isFree: true, isMobile: isMobile)),
            SizedBox(height: isMobile ? 12 : 16),
            if (!isCompany)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Premium features – $price",
                      style: TextStyle(
                          fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: isMobile ? 6 : 8),
                  ...paidFeatures.map((f) => _featureRow(f, isFree: false, isMobile: isMobile)),
                ],
              ),
            if (isCompany)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Premium features – 4,99€",
                      style:
                          TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: isMobile ? 6 : 8),
                  ...paidFeatures.map((f) => _featureRow(f, isFree: false, isMobile: isMobile)),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text("Enterprise features – 49,99€",
                      style:
                          TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: isMobile ? 6 : 8),
                  _featureRow("AI-generated feedback on employee profiles",
                      isFree: false, isMobile: isMobile),
                  _featureRow("Custom AI model training",
                      isFree: false, isMobile: isMobile),
                ],
              ),
            SizedBox(height: isMobile ? 12 : 16),
          ],
        ),
      ),
    );
  }

  static Widget _featureRow(String text, {required bool isFree, bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isFree ? Icons.check_circle_outline : Icons.star_border,
            size: isMobile ? 18 : 20,
            color: isFree ? Colors.green : const Color(0xFF7B3FE4),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: isFree ? Colors.black87 : Colors.black54,
                  height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactUsSection extends StatelessWidget {
  const ContactUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(flex: 1, child: Container(color: Colors.white)),
              Expanded(
                flex: 1,
                child: ClipPath(
                  clipper: _BottomAngleClipper(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7B3FE4), Color(0xFF9D50BB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 60 : 80, 
            horizontal: 16
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile ? MediaQuery.of(context).size.width - 32 : 1000
              ),
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      children: [
                        Image.asset('lib/assets/contact.png', height: 140),
                        const SizedBox(height: 20),
                        const _ContactForm(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/assets/contact.png',
                            height: 240,
                          ),
                        ),
                        const SizedBox(width: 48),
                        const Expanded(child: _ContactForm()),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.contactUs,
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          "sebastien@solidcv.com",
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
      ],
    );
  }
}

class _BottomAngleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 40);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PrivacyPolicyLink extends StatelessWidget {
  const _PrivacyPolicyLink();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(context, '/privacy-policy');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: const Color(0xFF7B3FE4),
                size: isMobile ? 20 : 22,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: TextStyle(
                  color: const Color(0xFF7B3FE4),
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}