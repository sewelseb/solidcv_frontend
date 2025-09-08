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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final Color _accentColor = const Color(0xFF00D4AA);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _userBll.getCurrentUser();
    _checkFirstConfiguration();
  }

  Future<void> _checkFirstConfiguration() async {
    try {
      final user = await _userBll.getCurrentUser();
      if (user.isFirstConfigurationDone == false || user.isFirstConfigurationDone == null) {
        // Navigate to first configuration and replace current route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/user/first-configuration');
        });
      }
    } catch (e) {
      // Handle error - user might not be logged in properly
      print('Error checking first configuration: $e');
    }
  }

  Future<void> _handleConnectWallet() async {
    final localizations = AppLocalizations.of(context)!;
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
          SnackBar(content: Text(localizations.walletAddressSavedSuccessfully)),
        );
        setState(() {
          _currentUserFuture = _userBll.getCurrentUser();
          _walletAddressController.clear();
          _createdWallet = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.failedToSaveWalletAddress),
          ),
        );
      }
    }
  }

  Future<void> _handleCreateWallet() async {
    final localizations = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    if (password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseEnterPassword),
        ),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.creatingWallet)),
    );

    final wallet = await _blockchainWalletBll.createANewWalletAddressForCurrentUser(password);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.newWalletCreatedAndSaved)),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: GoogleFonts.inter(color: Colors.black54),
      hintStyle: GoogleFonts.inter(color: Colors.black26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return _gradientEnd;
          }
          return _primaryColor;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Theme(
      data: Theme.of(context).copyWith(elevatedButtonTheme: _buttonTheme()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            'Home',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: _primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradientStart, _gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
                    child: Text(
                      localizations.adminArea,
                      style: const TextStyle(color: Colors.white),
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
              return Center(child: Text('${localizations.error}: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text(localizations.userNotFound));
            }

            final user = snapshot.data!;
            
            // Check if first configuration is done
            if (user.isFirstConfigurationDone == false) {
              // Show loading while navigating
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(localizations.redirectingToSetup),
                  ],
                ),
              );
            }

            final bool hasWalletConnected = user.ethereumAddress != null && user.ethereumAddress!.isNotEmpty;

            if (hasWalletConnected && _createdWallet == null) {
              return _buildWalletConnectedView(user, isMobile, localizations);
            } else {
              return _buildWalletSetupView(isMobile, user, localizations); // Pass user to show config button
            }
          },
        ),
      ),
    );
  }

  Widget _buildWalletConnectedView(User user, bool isMobile, AppLocalizations localizations) {
    Widget contentColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Welcome Header with Animation
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_successColor.withOpacity(0.1), _successColor.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _successColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: _successColor,
                  size: isMobile ? 60 : 80,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Animated Welcome Text
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Column(
                  children: [
                    Text(
                      localizations.welcomeBack,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 28 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.walletConnected,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
          child: Text(
            localizations.walletReadyDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 40),
        
        // Enhanced Wallet Address Section
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
                color: _cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _gradientStart.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 10,
                    spreadRadius: -5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_gradientStart, _gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.yourWalletAddress,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        SelectableText(
                          user.ethereumAddress!,
                          style: GoogleFonts.robotoMono(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_accentColor.withOpacity(0.1), _accentColor.withOpacity(0.2)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: user.ethereumAddress!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(localizations.addressCopied),
                                      ],
                                    ),
                                    backgroundColor: _successColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.copy, size: 18, color: _accentColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.copyAddress,
                                      style: GoogleFonts.inter(
                                        color: _accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 40),

        // Three sections layout - responsive grid
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isLargeScreen = screenWidth >= 1200;
            
            if (isLargeScreen) {
              // Side by side layout for large screens
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Opportunities Section
                  Expanded(
                    child: _buildJobOpportunitiesSection(isMobile, localizations),
                  ),
                  const SizedBox(width: 24),
                  // AI Career Advisor Section
                  Expanded(
                    child: _buildAICareerAdvisorSection(isMobile, localizations),
                  ),
                  const SizedBox(width: 24),
                  // Weekly Recommendations Section
                  Expanded(
                    child: _buildWeeklyRecommendationsSection(isMobile, localizations),
                  ),
                  const SizedBox(width: 24),
                  // Quick Actions Section
                  Expanded(
                    child: _buildQuickActionsSection(isMobile, localizations),
                  ),
                ],
              );
            } else {
              // Stacked layout for smaller screens
              return Column(
                children: [
                  _buildJobOpportunitiesSection(isMobile, localizations),
                  const SizedBox(height: 40),
                  _buildAICareerAdvisorSection(isMobile, localizations),
                  const SizedBox(height: 40),
                  _buildWeeklyRecommendationsSection(isMobile, localizations),
                  const SizedBox(height: 40),
                  _buildQuickActionsSection(isMobile, localizations),
                ],
              );
            }
          },
        ),
        

        

        const SizedBox(height: 20),
        
        // NEW: Three sections responsive layout (commented out old sections above)
        // LayoutBuilder(
        //   builder: (context, constraints) {
        //     final screenWidth = constraints.maxWidth;
        //     final isLargeScreen = screenWidth >= 1200;
            
        //     if (isLargeScreen) {
        //       // Side by side layout for large screens
        //       return Row(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           // Job Opportunities Section
        //           Expanded(
        //             child: _buildJobOpportunitiesSection(isMobile),
        //           ),
        //           const SizedBox(width: 24),
        //           // AI Career Advisor Section
        //           Expanded(
        //             child: _buildAICareerAdvisorSection(isMobile),
        //           ),
        //           const SizedBox(width: 24),
        //           // Quick Actions Section
        //           Expanded(
        //             child: _buildQuickActionsSection(isMobile),
        //           ),
        //         ],
        //       );
        //     } else {
        //       // Stacked layout for smaller screens
        //       return Column(
        //         children: [
        //           _buildJobOpportunitiesSection(isMobile),
        //           const SizedBox(height: 40),
        //           _buildAICareerAdvisorSection(isMobile),
        //           const SizedBox(height: 40),
        //           _buildQuickActionsSection(isMobile),
        //         ],
        //       );
        //     }
        //   },
        // ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8FAFF),
                Colors.white,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20.0 : 40.0,
                vertical: 32.0,
              ),
              alignment: Alignment.center,
              child: contentColumn,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalletSetupView(bool isMobile, User user, AppLocalizations localizations) {
    if (_createdWallet != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFF),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20.0 : 40.0,
            vertical: 32.0,
          ),
          child: _buildWalletCreationResult(_createdWallet!, isMobile, localizations),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFF),
            Colors.white,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20.0 : 40.0,
          vertical: 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First Configuration Section - Always show
            _buildFirstConfigurationSection(isMobile, localizations),
            const SizedBox(height: 40),
            
            _buildSectionCard(
              title: localizations.connectExistingWallet,
              description: localizations.connectExistingWalletDescription,
              icon: Icons.link,
              formFields: [
                TextField(
                  controller: _walletAddressController,
                  decoration: _textFieldDecoration(localizations.baseBlockchainAddress, prefixIcon: Icons.account_balance_wallet_outlined),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleConnectWallet,
                  child: Text(localizations.connectWallet),
                ),
              ],
              isMobile: isMobile,
            ),
            const SizedBox(height: 40),
            _buildSectionCard(
              title: localizations.createNewWalletTitle,
              description: localizations.createNewWalletDescription,
              icon: Icons.add_circle_outline,
              formFields: [
                TextField(
                  controller: _passwordController,
                  decoration: _textFieldDecoration(
                    localizations.passwordToEncryptKey,
                    prefixIcon: Icons.lock_outline,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _warningColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: _warningColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.passwordEncryptionWarning,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _warningColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleCreateWallet,
                  child: Text(localizations.createNewWallet),
                ),
              ],
              isMobile: isMobile,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Enhanced first configuration section
  Widget _buildFirstConfigurationSection(bool isMobile, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced icon with animation
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.settings_suggest,
                color: Colors.white,
                size: isMobile ? 32 : 36,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            localizations.completeProfileSetup,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            localizations.profileSetupDescription,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          
          // Enhanced button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pushNamed(context, '/user/first-configuration');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 18 : 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade500, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.startSetupAssistant,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.shade600.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 6),
                Text(
                  'Takes just 3 minutes • No wallet required to start',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _gradientStart.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_gradientStart, _gradientEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isMobile ? 24 : 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            ...formFields,
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCreationResult(Wallet wallet, bool isMobile, AppLocalizations localizations) {
    String privateKeyHex = bytesToHex(wallet.privateKey.privateKey);
    String publicKeyHex = wallet.privateKey.address.hex;

    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: _successColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _successColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: _successColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.walletCreatedSuccessfully,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.newWalletReady,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          _buildEnhancedKeyInfo(localizations.publicAddress, publicKeyHex, isMobile, localizations, isAddress: true),
          const SizedBox(height: 20),
          _buildEnhancedKeyInfo(localizations.privateKey, "0x$privateKeyHex", isMobile, localizations),
          
          const SizedBox(height: 24),
          
          // Warning message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _warningColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.savePrivateKeyWarning,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _warningColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Enhanced OK button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _successColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _currentUserFuture = _userBll.getCurrentUser();
                    _walletAddressController.clear();
                    _createdWallet = null;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 16 : 18,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: _successColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.continueButton,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedKeyInfo(String label, String value, bool isMobile, AppLocalizations localizations, {bool isAddress = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isAddress ? Icons.account_balance_wallet : Icons.vpn_key,
                  size: 18,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: SelectableText(
              value,
              style: GoogleFonts.robotoMono(
                fontSize: isMobile ? 12 : 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentColor.withOpacity(0.1), _accentColor.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('$label copied to clipboard!'),
                        ],
                      ),
                      backgroundColor: _successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy, size: 18, color: _accentColor),
                      const SizedBox(width: 8),
                      Text(
                        localizations.copy(label),
                        style: GoogleFonts.inter(
                          color: _accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Job Opportunities Section
  Widget _buildJobOpportunitiesSection(bool isMobile, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _cardBackground,
              _gradientStart.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _primaryColor.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animated background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_gradientStart, _gradientEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.work_outline,
                color: Colors.white,
                size: isMobile ? 32 : 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.findJobOpportunities,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 22 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.jobOpportunitiesDescription,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Enhanced Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, '/jobs');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 18 : 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_gradientStart, _gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.exploreJobOffers,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Feature badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 16, color: _primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'Blockchain-verified applications',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for AI Career Advisor Section
  Widget _buildAICareerAdvisorSection(bool isMobile, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade50,
              Colors.orange.shade100.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.orange.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced AI Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: isMobile ? 32 : 36,
                ),
                // AI spark effect
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade300,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade300.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.aiCareerAdvisor,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 22 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AI',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              localizations.aiCareerAdvisorDescription,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Enhanced Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, '/career-advice');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 18 : 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade500, Colors.orange.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.getCareerGuidance,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Feature badges
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.shade600.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'AI-powered',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.shade600.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    localizations.personalized,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.shade600.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    localizations.free,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.orange.shade600,
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

  // Helper method for Weekly Recommendations Section
  Widget _buildWeeklyRecommendationsSection(bool isMobile, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _accentColor.withOpacity(0.1),
              _accentColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Weekly Calendar Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_accentColor, _accentColor.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.calendar_view_week,
                  color: Colors.white,
                  size: isMobile ? 32 : 36,
                ),
                // Week indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade300,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade300.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.weeklyRecommendations,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEW',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              localizations.weeklyRecommendationsDescription,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Enhanced Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, '/weekly-recommendations');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 18 : 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentColor, _accentColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_view_week,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.viewRecommendations,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Feature badges
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '5 Courses',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '2 Events',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Weekly',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _accentColor,
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

  // Helper method for Quick Actions Section (third column)
  Widget _buildQuickActionsSection(bool isMobile, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.green.shade100.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.green.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.dashboard,
                color: Colors.white,
                size: isMobile ? 32 : 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.quickActions,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 22 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.quickActionsDescription,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, '/my-cv');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 18 : 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.description,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.viewMyCv,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.shade600.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Text(
                    localizations.quickAccessProfile,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}