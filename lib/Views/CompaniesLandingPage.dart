import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CompaniesLandingPage extends StatefulWidget {
  const CompaniesLandingPage({super.key});

  @override
  State<CompaniesLandingPage> createState() => _CompaniesLandingPageState();
}

class _CompaniesLandingPageState extends State<CompaniesLandingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDemoRequestDialog() {
    const String demoEmail = 'sebastien@solidcv.com';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 40,
            vertical: isMobile ? 24 : 60,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: screenHeight * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7B3FE4),
                  Color(0xFFB57AED),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section
                  Container(
                    padding: EdgeInsets.all(isMobile ? 24 : 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.video_call,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Request a Demo',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ready to revolutionize your hiring process? Get in touch with our team!',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Email section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Contact our sales specialist',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF7B3FE4).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: const Color(0xFF7B3FE4),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  demoEmail,
                                  style: GoogleFonts.inter(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    const ClipboardData(text: demoEmail),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Email copied to clipboard!',
                                                style: GoogleFonts.inter(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF4CAF50),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Copy email',
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B3FE4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 12 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                const ClipboardData(text: demoEmail),
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Email copied! Contact us for your demo.',
                                            style: GoogleFonts.inter(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF4CAF50),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF7B3FE4),
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 12 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(Icons.copy, size: isMobile ? 16 : 18),
                            label: Text(
                              'Copy Email',
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isMobile),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(isMobile, isTablet, screenWidth),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF7B3FE4),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'SolidCV',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7B3FE4),
              fontSize: isMobile ? 20 : 24,
            ),
          ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Sign Up'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B3FE4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Login'),
          ),
          const SizedBox(width: 16),
        ] else ...[
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'home':
                  Navigator.pushNamed(context, '/');
                  break;
                case 'signup':
                  Navigator.pushNamed(context, '/register');
                  break;
                case 'login':
                  Navigator.pushNamed(context, '/');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'home', child: Text('Home')),
              const PopupMenuItem(value: 'signup', child: Text('Sign Up')),
              const PopupMenuItem(value: 'login', child: Text('Login')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBody(bool isMobile, bool isTablet, double screenWidth) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          _buildHeroSection(isMobile, isTablet, screenWidth),
          _buildFeaturesSection(isMobile, isTablet),
          //_buildTalentPoolSection(isMobile, isTablet),
          _buildBenefitsSection(isMobile, isTablet),
          //_buildTestimonialsSection(isMobile, isTablet),
          _buildCTASection(isMobile, isTablet),
          _buildFooter(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile, bool isTablet, double screenWidth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7B3FE4),
            Color(0xFFB57AED),
          ],
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: isMobile
            ? _buildMobileHeroLayout()
            : _buildDesktopHeroLayout(isTablet),
      ),
    );
  }

  Widget _buildMobileHeroLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          _buildHeroContent(isMobile: true),
          const SizedBox(height: 40),
          _buildHeroImage(isMobile: true),
        ],
      ),
    );
  }

  Widget _buildDesktopHeroLayout(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 60 : 80),
      child: Row(
        children: [
          Expanded(
            flex: isTablet ? 5 : 6,
            child: _buildHeroContent(isMobile: false),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: isTablet ? 5 : 4,
            child: _buildHeroImage(isMobile: false),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Speedup your Hiring Process',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 20),
        Text(
          'Access verified professionals with blockchain-authenticated skills and experience. Make confident hiring decisions with AI-powered candidate matching.',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 20,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7B3FE4),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 16 : 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.rocket_launch),
              label: Text(
                'Start Hiring',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showDemoRequestDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 16 : 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.video_call),
              label: Text(
                'Request Demo',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage({required bool isMobile}) {
    return Container(
      height: isMobile ? 300 : 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.people,
              size: 120,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: 20,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Powerful Tools for Modern Recruitment',
              'Everything you need to find and hire the best talent efficiently',
              isMobile,
            ),
            const SizedBox(height: 60),
            _buildFeatureGrid(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(bool isMobile, bool isTablet) {
    final features = [
      FeatureData(
        icon: Icons.verified_user,
        title: 'Verified Credentials',
        description:
            'Access candidates with blockchain-verified certificates and work experience that cannot be faked.',
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
      ),
      FeatureData(
        icon: Icons.psychology,
        title: 'AI-Powered Matching',
        description:
            'Find the perfect candidates using AI that analyzes skills, experience, and career trajectories.',
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
      ),
      FeatureData(
        icon: Icons.speed,
        title: 'Instant Verification',
        description:
            'Verify candidate credentials instantly without waiting for manual verification processes.',
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        ),
      ),
      
    ];

    if (isMobile) {
      return Column(
        children: features
            .map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildFeatureCard(feature, true),
                ))
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 3,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => _buildFeatureCard(features[index], false),
    );
  }

  Widget _buildFeatureCard(FeatureData feature, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: feature.gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.icon,
              size: isMobile ? 32 : 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            feature.title,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            feature.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTalentPoolSection(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F9FA),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: 20,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: isMobile
            ? _buildMobileTalentPoolLayout()
            : _buildDesktopTalentPoolLayout(isTablet),
      ),
    );
  }

  Widget _buildMobileTalentPoolLayout() {
    return Column(
      children: [
        _buildTalentPoolContent(isMobile: true),
        const SizedBox(height: 40),
        _buildTalentPoolVisual(isMobile: true),
      ],
    );
  }

  Widget _buildDesktopTalentPoolLayout(bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildTalentPoolVisual(isMobile: false),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 5,
          child: _buildTalentPoolContent(isMobile: false),
        ),
      ],
    );
  }

  Widget _buildTalentPoolContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Access Verified Talent Worldwide',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 20),
        Text(
          'Connect with pre-verified professionals from top institutions and companies. Every credential is blockchain-authenticated for your confidence.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.6,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 30),
        _buildTalentPoolStats(isMobile),
      ],
    );
  }

  Widget _buildTalentPoolStats(bool isMobile) {
    final stats = [
      {'number': '50K+', 'label': 'Verified Professionals'},
      {'number': '500+', 'label': 'Partner Institutions'},
      {'number': '99.9%', 'label': 'Credential Accuracy'},
      {'number': '85%', 'label': 'Faster Hiring Process'},
    ];

    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: stats
          .map((stat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisSize:
                      isMobile ? MainAxisSize.min : MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['number']!,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7B3FE4),
                          ),
                        ),
                        Text(
                          stat['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTalentPoolVisual({required bool isMobile}) {
    return Container(
      height: isMobile ? 250 : 350,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B3FE4).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.people_alt,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: 20,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Why Companies Choose SolidCV',
              'Transform your hiring process with next-generation recruitment tools',
              isMobile,
            ),
            const SizedBox(height: 60),
            _buildBenefitsGrid(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid(bool isMobile, bool isTablet) {
    final benefits = [
      BenefitData(
        title: 'Reduce Hiring Time',
        description: 'Cut recruitment time by up to 75%',
        icon: Icons.timer,
        color: const Color(0xFF4CAF50),
      ),
      BenefitData(
        title: 'Eliminate CV Fraud',
        description: 'Zero tolerance for fake credentials',
        icon: Icons.shield,
        color: const Color(0xFF2196F3),
      ),
      BenefitData(
        title: 'Better Matches',
        description: 'AI finds the perfect cultural fit',
        icon: Icons.psychology,
        color: const Color(0xFFFF9800),
      ),
      BenefitData(
        title: 'Global Reach',
        description: 'Access talent from anywhere',
        icon: Icons.public,
        color: const Color(0xFF9C27B0),
      ),
    ];

    if (isMobile) {
      return Column(
        children: benefits
            .map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildBenefitCard(benefit, true),
                ))
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 4,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 1.0,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) => _buildBenefitCard(benefits[index], false),
    );
  }

  Widget _buildBenefitCard(BenefitData benefit, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: benefit.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: benefit.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Icon(
            benefit.icon,
            size: isMobile ? 40 : 50,
            color: benefit.color,
          ),
          const SizedBox(height: 20),
          Text(
            benefit.title,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            benefit.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F9FA),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: 20,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader(
              'Trusted by Leading Companies',
              'See how top companies are transforming their hiring with SolidCV',
              isMobile,
            ),
            const SizedBox(height: 60),
            _buildTestimonialCards(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCards(bool isMobile, bool isTablet) {
    final testimonials = [
      TestimonialData(
        quote:
            'SolidCV revolutionized our hiring process. We reduced time-to-hire by 70% and eliminated CV fraud completely.',
        author: 'Sarah Johnson',
        position: 'Head of Talent Acquisition',
        company: 'TechCorp Inc.',
      ),
      TestimonialData(
        quote:
            'The blockchain verification gives us complete confidence in candidate credentials. No more surprises during background checks.',
        author: 'Michael Chen',
        position: 'HR Director',
        company: 'Global Solutions Ltd.',
      ),
      TestimonialData(
        quote:
            'AI-powered matching helped us find perfect cultural fits. Our employee retention increased by 40% since using SolidCV.',
        author: 'Emma Williams',
        position: 'Chief People Officer',
        company: 'Innovation Labs',
      ),
    ];

    if (isMobile) {
      return Column(
        children: testimonials
            .map((testimonial) => Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: _buildTestimonialCard(testimonial),
                ))
            .toList(),
      );
    }

    return Row(
      children: testimonials
          .map((testimonial) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _buildTestimonialCard(testimonial),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTestimonialCard(TestimonialData testimonial) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            size: 40,
            color: const Color(0xFF7B3FE4).withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            testimonial.quote,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Text(
            testimonial.author,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            testimonial.position,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF7B3FE4),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            testimonial.company,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 80,
        horizontal: 20,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Text(
              'Ready to Transform Your Hiring?',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Join thousands of companies already using SolidCV to find verified talent faster and more efficiently than ever before.',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 16 : 18,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7B3FE4),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 32 : 40,
                      vertical: isMobile ? 16 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.rocket_launch),
                  label: Text(
                    'Start Hiring',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showDemoRequestDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 32 : 40,
                      vertical: isMobile ? 16 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.video_call),
                  label: Text(
                    'Request Demo',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2C3E50),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: 20,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'SolidCV',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Empowering companies with blockchain-verified talent and AI-powered recruitment solutions.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 20),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 20),
            Text(
              '© 2025 SolidCV. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool isMobile) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 18,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class BenefitData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  BenefitData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TestimonialData {
  final String quote;
  final String author;
  final String position;
  final String company;

  TestimonialData({
    required this.quote,
    required this.author,
    required this.position,
    required this.company,
  });
}
