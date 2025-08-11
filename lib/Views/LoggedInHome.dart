import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

class LoggedInHome extends StatefulWidget {
  const LoggedInHome({super.key});

  @override
  State<LoggedInHome> createState() => _LoggedInHomeState();
}

class _LoggedInHomeState extends State<LoggedInHome> {
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  final TextEditingController _walletAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final IUserBLL _userBll = UserBll();
  late Future<User> _currentUserFuture;
  Wallet? _createdWallet;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);
  final Color _borderColor = Colors.deepPurple.shade100;
  final Color _shadowColor = Colors.deepPurple.shade50;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _userBll.getCurrentUser();
  }

  Future<void> _handleConnectWallet() async {
    final address = _walletAddressController.text.trim();
    if (address.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a wallet address.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting wallet...')),
    );

    var success = await _blockchainWalletBll.saveWalletAddressForCurrentUser(address);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet address saved successfully!')),
        );
        setState(() {
          _currentUserFuture = _userBll.getCurrentUser();
          _walletAddressController.clear();
          _createdWallet = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save wallet address. The address might be invalid or already in use.'),
          ),
        );
      }
    }
  }

  Future<void> _handleCreateWallet() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password to encrypt your private key.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating wallet...')),
    );

    final wallet = await _blockchainWalletBll.createANewWalletAddressForCurrentUser(password);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New wallet created and address saved!')),
      );
      setState(() {
        _createdWallet = wallet;
        _currentUserFuture = _userBll.getCurrentUser();
        _passwordController.clear();
      });
        }
  }

  InputDecoration _textFieldDecoration(String label, {IconData? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: label.contains("Address") || label.contains("Adresse") ? "0x..." : null,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _primaryColor) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: GoogleFonts.inter(color: Colors.black87),
      hintStyle: GoogleFonts.inter(color: Colors.black26),
    );
  }

  ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        elevation: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Theme(
      data: Theme.of(context).copyWith(elevatedButtonTheme: _buttonTheme()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Home',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: _primaryColor,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            FutureBuilder<bool>(
              future: _userBll.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin/dashboard');
                    },
                    child: const Text(
                      'Admin Area',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        bottomNavigationBar: const MainBottomNavigationBar(),
        body: FutureBuilder<User>(
          future: _currentUserFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("User not found."));
            }

            final user = snapshot.data!;
            final bool hasWalletConnected = user.ethereumAddress != null && user.ethereumAddress!.isNotEmpty;

            if (hasWalletConnected && _createdWallet == null) {
              return _buildWalletConnectedView(user, isMobile);
            } else {
              return _buildWalletSetupView(isMobile);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWalletConnectedView(User user, bool isMobile) {
    Widget contentColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, color: _primaryColor, size: isMobile ? 60 : 80),
        const SizedBox(height: 24),
        Text(
          'Your Base Blockchain Wallet',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
          child: Text(
            "Your wallet is connected and ready to use. You can start using the app's features.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
        ),
        const SizedBox(height: 32),
        
        // Wallet Address Section
        LayoutBuilder(
          builder: (context, constraints) {
            double boxTargetWidth;
            double maxBoxWidthOnDesktop = 550.0;

            if (isMobile) {
              boxTargetWidth = constraints.maxWidth;
            } else {
              boxTargetWidth = constraints.maxWidth < maxBoxWidthOnDesktop
                  ? constraints.maxWidth
                  : maxBoxWidthOnDesktop;
            }
            return Container(
              width: boxTargetWidth,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _glassBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gradientStart.withOpacity(0.18), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 14,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Wallet Address:',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    user.ethereumAddress!,
                    style: GoogleFonts.robotoMono(
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: Icon(Icons.copy, size: 18, color: _primaryColor),
                    label: Text("Copy Address", style: TextStyle(color: _primaryColor)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: user.ethereumAddress!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied to clipboard!')),
                      );
                    },
                  )
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        // First Configuration Section
        LayoutBuilder(
          builder: (context, constraints) {
            double boxTargetWidth;
            double maxBoxWidthOnDesktop = 550.0;

            if (isMobile) {
              boxTargetWidth = constraints.maxWidth;
            } else {
              boxTargetWidth = constraints.maxWidth < maxBoxWidthOnDesktop
                  ? constraints.maxWidth
                  : maxBoxWidthOnDesktop;
            }
            return Container(
              width: boxTargetWidth,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.orange.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade300, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.psychology, color: Colors.white, size: isMobile ? 24 : 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Complete Your Profile Setup',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our smart assistant will guide you through setting up your profile, uploading your CV, and optimizing your account for the best experience.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/user/first-configuration');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16 : 18,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.auto_fix_high, size: 20),
                      label: const Text('Start Setup Assistant'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.orange.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Takes just 3 minutes',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        // Job Opportunities Section
        LayoutBuilder(
          builder: (context, constraints) {
            double boxTargetWidth;
            double maxBoxWidthOnDesktop = 550.0;

            if (isMobile) {
              boxTargetWidth = constraints.maxWidth;
            } else {
              boxTargetWidth = constraints.maxWidth < maxBoxWidthOnDesktop
                  ? constraints.maxWidth
                  : maxBoxWidthOnDesktop;
            }
            return Container(
              width: boxTargetWidth,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientStart.withOpacity(0.08), _gradientEnd.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _primaryColor.withOpacity(0.2), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_gradientStart, _gradientEnd],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.work_outline, color: Colors.white, size: isMobile ? 24 : 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find Job Opportunities',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover amazing job opportunities from companies. Apply directly and showcase your blockchain-verified credentials and your AI tested skills.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/jobs');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16 : 18,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text('Browse Job Offers'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 16, color: _primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Blockchain-verified applications',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            padding: const EdgeInsets.all(24.0),
            alignment: Alignment.center,
            child: contentColumn,
          ),
        );
      },
    );
  }

  Widget _buildWalletSetupView(bool isMobile) {
    if (_createdWallet != null) {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 40.0, vertical: 24.0),
        child: _buildWalletCreationResult(_createdWallet!, isMobile),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 40.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionCard(
            title: 'Connect an Existing Wallet',
            description: "If you already have an Base Blochchain wallet, enter its public address to link it to your SolidCV account.",
            icon: Icons.link,
            formFields: [
              TextField(
                controller: _walletAddressController,
                decoration: _textFieldDecoration("Base Blochchain Address", prefixIcon: Icons.account_balance_wallet_outlined),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleConnectWallet,
                child: const Text('Connect Wallet'),
              ),
            ],
            isMobile: isMobile,
          ),
          const SizedBox(height: 32),
          _buildSectionCard(
            title: 'Create a New Wallet',
            description: "SolidCV can generate a new secure Base Blochchain wallet for you. Choose a strong password to protect your private key.",
            icon: Icons.add_circle_outline,
            formFields: [
              TextField(
                controller: _passwordController,
                decoration: _textFieldDecoration(
                  "Password (to encrypt the private key, make sure to remember it, there is no way to recover it)",
                  prefixIcon: Icons.lock_outline,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              const Text(
                "This password will encrypt your private key. Keep it safe, it is unrecoverable.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleCreateWallet,
                child: const Text('Create a New Wallet'),
              ),
            ],
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String description,
    required IconData icon,
    required List<Widget> formFields,
    required bool isMobile,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: _glassBackground,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: _gradientStart.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_gradientStart, _gradientEnd],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white, size: isMobile ? 22 : 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 22),
          ...formFields,
        ],
      ),
    );
  }

  Widget _buildWalletCreationResult(Wallet wallet, bool isMobile) {
    String privateKeyHex = bytesToHex(wallet.privateKey.privateKey);
    String publicKeyHex = wallet.privateKey.address.hex;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _glassBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _primaryColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet created successfully!',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildKeyInfo("Public Key:", publicKeyHex, isMobile, isAddress: true),
          const SizedBox(height: 12),
          _buildKeyInfo("Private Key:", "0x$privateKeyHex", isMobile),
          const SizedBox(height: 16),
          const Text(
            'Make sure to save the private key in a safe place, it will not be shown again and you can\'t recover it.',
            style: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentUserFuture = _userBll.getCurrentUser();
                  _walletAddressController.clear();
                  _createdWallet = null;
                });
              },
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfo(String label, String value, bool isMobile, {bool isAddress = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: _primaryColor,
            fontSize: isMobile ? 13 : 15,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                value,
                style: GoogleFonts.robotoMono(fontSize: isMobile ? 13 : 14, color: Colors.black87),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, size: 18, color: _primaryColor),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${label.replaceAll(":", "")} value copied!')),
                );
              },
              tooltip: "Copy value",
            )
          ],
        ),
      ],
    );
  }
}