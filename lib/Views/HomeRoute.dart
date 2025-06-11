import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';

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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signing in...')),
    );

    try {
      var user = User();
      user.email = email;
      user.password = password;

      user = await _userBll.login(user);

      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: user.token);

      Navigator.pushNamed(context, '/loggedin/home');
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('email not verified')) {
        Navigator.pushReplacementNamed(context, '/verify-email',
            arguments: email);
        return;
      }
      if (errorMessage.contains('invalid credentials')) {
        errorMessage = 'Incorrect email or password.';
      } else if (errorMessage.contains('missing credentials')) {
        errorMessage = 'Account does not exist.';
      }
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
            const AboutUsSection(),
            const TargetAudienceSection(),
            const PricingSection(),
            const ContactUsSection(),
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
            child: _LoginForm(
              isMobile: true,
              obscurePassword: _obscurePassword,
              onTogglePassword: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              emailController: _emailController,
              passwordController: _passwordController,
              onLoginPressed: _handleLogin,
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
                child: _LoginForm(
                  isMobile: false,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onLoginPressed: _handleLogin,
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

class _LoginForm extends StatelessWidget {
  final bool isMobile;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;

  const _LoginForm({
    required this.isMobile,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
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
        Text("Welcome to SolidCV",
            style: titleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 8),
        Text("Sign in to manage your verified credentials.",
            style: subtitleStyle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 32),
        TextField(
          controller: emailController,
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
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
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
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: const Text("Forgot password?",
                style: TextStyle(color: Color(0xFF7B3FE4), fontSize: 14)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onLoginPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B3FE4),
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          child: const Text("Sign in", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                "Register",
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

// --- SECTION TRANSLATIONS ---

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Container(
      color: const Color(0xFFF9F6FC),
      padding:
          EdgeInsets.symmetric(vertical: 64, horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          const Text(
            "Discover SolidCV",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _AboutUsBlock(
            imagePath: 'lib/assets/section1.png',
            title: 'Reinventing Trust in Recruitment',
            description:
                "In a market where one in five CVs may contain inaccuracies and keeping them updated is a hassle, SolidCV positions itself as a pioneer. We are shaping the future of recruitment with a platform where every qualification is strictly verifiable and every professional journey is highlighted with absolute integrity. Leave uncertainty behind and embrace a new era of transparency and reliability.",
            reverse: false,
            isMobile: isMobile,
          ),
          const SizedBox(height: 64),
          const _SectionDivider(),
          const SizedBox(height: 64),
          _AboutUsBlock(
            imagePath: 'lib/assets/section2.png',
            title: 'The Blockchain Revolution Serving Your Diplomas',
            description:
                "SolidCV is based on the robustness of blockchain technology. Every diploma, certificate, and experience becomes a unique, tamper-proof NFT, secured in your personal digital wallet. Issuing institutions validate your achievements directly on the blockchain, providing recruiters with instant access to undeniable proof of your skills. Your career, authenticated and valued.",
            reverse: true,
            isMobile: isMobile,
          ),
          const SizedBox(height: 64),
          const _SectionDivider(),
          const SizedBox(height: 64),
          _AboutUsBlock(
            imagePath: 'lib/assets/section3.png',
            title: 'A Virtuous Ecosystem for All Stakeholders',
            description:
                "SolidCV weaves a network of mutual benefits: users retain full control over their professional identity and are rewarded for their active participation. Companies and educational institutions streamline their verification processes and contribute to a high standard of trust. Our innovative validation mechanism even allows you to integrate and validate your past experiences, ensuring a smooth transition to the CV of tomorrow.",
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

    Widget imageWidget = Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: imageMaxWidth,
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

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children.map((child) {
                return Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: child,
                );
              }).toList(),
            );
          },
        ),
      );
    }
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({super.key});

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
          EdgeInsets.symmetric(vertical: 64, horizontal: isMobile ? 16 : 32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Who is SolidCV for?",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _TargetCard(
                title: "For All Professionals",
                description:
                    "Whether you are a student, recent graduate, or experienced professional, SolidCV gives you the tools to showcase your skills in a verifiable way.",
                imagePath: 'lib/assets/user.png',
              ),
              _TargetCard(
                title: "For Companies",
                description:
                    "Recruit more efficiently with verified CVs, reducing time and verification costs.",
                imagePath: 'lib/assets/company.png',
              ),
              _TargetCard(
                title: "For Educational Institutions",
                description:
                    "Offer your students tamper-proof, shareable digital certifications.",
                imagePath: 'lib/assets/institution.png',
              ),
            ],
          ),
          SizedBox(height: 64),
          _SectionDivider(),
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
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Image.asset(imagePath, height: 160),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center),
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
        vertical: 34,
        horizontal: isMobile ? 16 : 32,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Our Flexible Offers",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 32,
              children: [
                _UnifiedPricingCard(
                  title: "User",
                  freeFeatures: ["Create and share your CV"],
                  paidFeatures: [
                    "Statistics on your CV views and attention points",
                    "Premium CV templates",
                  ],
                  price: "4,99€",
                ),
                _UnifiedPricingCard(
                  title: "Institution",
                  freeFeatures: ["Issue credentials to users"],
                  paidFeatures: [
                    "Advanced statistics on certification usage",
                  ],
                  price: "4,99€",
                ),
                _UnifiedPricingCard(
                  title: "Company",
                  freeFeatures: [
                    "Issue credentials to users",
                    "Verify CVs",
                  ],
                  paidFeatures: [],
                  price: "4,99€ / 49,99€",
                ),
              ],
            ),
          ),
          SizedBox(height: 64),
          _SectionDivider(),
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

    return SizedBox(
      width: isMobile ? double.infinity : 340,
      height: 540,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        alignment: Alignment.topCenter,
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
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            const Text("Included for free",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...freeFeatures.map((f) => _featureRow(f, isFree: true)),
            const SizedBox(height: 16),
            if (!isCompany)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Premium features – $price",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...paidFeatures.map((f) => _featureRow(f, isFree: false)),
                ],
              ),
            if (isCompany)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Premium features – 4,99€",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _featureRow("Advanced statistics on credential usage",
                      isFree: false),
                  const SizedBox(height: 16),
                  const Text("Premium features – 49,99€",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _featureRow("AI-generated feedback on employee profiles",
                      isFree: false),
                ],
              ),
            const Spacer(),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: const Color(0xFF7B3FE4),
            //       foregroundColor: Colors.white,
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: const Text("Choose this offer",
            //         style: TextStyle(fontSize: 15)),
            //   ),
            // ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _featureRow(String text, {required bool isFree}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isFree ? Icons.check_circle_outline : Icons.star_border,
            size: 20,
            color: isFree ? Colors.green : const Color(0xFF7B3FE4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14,
                  color: isFree ? Colors.black87 : Colors.black54),
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
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.all(32),
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
                        Image.asset('lib/assets/contact.png', height: 180),
                        const SizedBox(height: 24),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Contact Us",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Text(
          "sebastien.debeauffort@outlook.com",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 24),

        // _buildTextField(label: "Full Name"),
        // const SizedBox(height: 16),
        // _buildTextField(label: "Email Address"),
        // const SizedBox(height: 16),
        // _buildTextField(label: "Message", maxLines: 4),
        // const SizedBox(height: 24),

        // Align(
        //   alignment: Alignment.centerRight,
        //    child: ElevatedButton(
        //     onPressed: () {},
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: const Color(0xFF7B3FE4),
        //        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //     child: const Text(
        //        "Send",
        //        style: TextStyle(fontSize: 16, color: Colors.white),
        //     ),
        //    ),
        // ),
      ],
    );
  }

  // Widget _buildTextField({required String label, int maxLines = 1}) {
  //   return TextField(
  //     maxLines: maxLines,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       filled: true,
  //       fillColor: Colors.grey.shade100,
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //       focusedBorder: OutlineInputBorder(
  //         borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //   );
  // }
}

class _BottomAngleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 40);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
