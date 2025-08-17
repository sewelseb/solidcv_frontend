import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';

class WalletStep extends StatefulWidget {
  final Function(bool hasWallet, String? walletAddress) onComplete;
  final bool isActive;

  const WalletStep({
    super.key,
    required this.onComplete,
    required this.isActive,
  });

  @override
  State<WalletStep> createState() => _WalletStepState();
}

class _WalletStepState extends State<WalletStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();

  bool? _hasWallet;
  final TextEditingController _walletController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isCreatingWallet = false;
  bool _isValidatingWallet = false;
  bool _showPasswordForm = false;
  String? _walletError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showWalletKeys = false;
  String? _privateKey;
  bool _keysAcknowledged = false;
  bool _continueBtnClicked = false; // Add this state variable with the other declarations

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.isActive) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _animationController.forward();
      });
    }
  }

  void _handleWalletChoice(bool hasWallet) {
    setState(() {
      _hasWallet = hasWallet;
      _walletError = null;
      _showPasswordForm = false;
      _showWalletKeys = false;
      _keysAcknowledged = false;
      _privateKey = null;
      _continueBtnClicked = false; // Reset the button state
    });
  }

  void _showPasswordSetup() {
    setState(() {
      _showPasswordForm = true;
      _passwordError = null;
    });
  }

  bool _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _passwordError = 'Please enter and confirm your password.';
      });
      return false;
    }
    
    if (password.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters long.';
      });
      return false;
    }
    
    if (password != confirmPassword) {
      setState(() {
        _passwordError = 'Passwords do not match.';
      });
      return false;
    }
    
    setState(() {
      _passwordError = null;
    });
    return true;
  }

  Future<void> _createWallet() async {
    if (!_validatePasswords()) {
      return;
    }

    setState(() {
      _isCreatingWallet = true;
      _walletError = null;
    });
    
    try {
      final password = _passwordController.text;
      final walletData = await _blockchainWalletBll.createANewWalletAddressForCurrentUser(password);

      String privateKeyHex = bytesToHex(walletData.privateKey.privateKey);
      String publicKeyHex = walletData.privateKey.address.hex;
      
      if (mounted) {
        setState(() {
          _isCreatingWallet = false;
          _walletController.text = publicKeyHex; // Assuming the BLL returns both address and private key
          _privateKey = privateKeyHex; // Store private key
          _showPasswordForm = false;
          _showWalletKeys = true; // New state to show keys
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingWallet = false;
          _walletError = 'Failed to create wallet: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _validateAndSubmitWallet() async {
    final walletAddress = _walletController.text.trim();
    
    if (walletAddress.isEmpty) {
      setState(() {
        _walletError = 'Please enter a wallet address';
      });
      return;
    }

    // Basic Ethereum address validation
    if (!_isValidEthereumAddress(walletAddress)) {
      setState(() {
        _walletError = 'Invalid Ethereum address format. Address should start with 0x and be 42 characters long.';
      });
      return;
    }

    setState(() {
      _isValidatingWallet = true;
      _walletError = null;
      _continueBtnClicked = true; // Hide the button immediately
    });

    try {
      await _blockchainWalletBll.saveWalletAddressForCurrentUser(walletAddress);
      
      if (mounted) {
        setState(() {
          _isValidatingWallet = false;
        });
        widget.onComplete(true, walletAddress); // Make sure this is called
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingWallet = false;
          _walletError = 'Failed to save wallet address: ${e.toString().replaceAll('Exception: ', '')}';
          _continueBtnClicked = false; // Show button again if there's an error
        });
      }
    }
  }

  Future<void> _submitCreatedWallet() async {
    // Set the button as clicked immediately to hide it
    setState(() {
      _continueBtnClicked = true;
      _walletError = null; // Clear any previous errors
    });
    
    final walletAddress = _walletController.text.trim();
    
    try {
      await _blockchainWalletBll.saveWalletAddressForCurrentUser(walletAddress);

      if (mounted) {
        // Successfully saved, call the completion callback
        widget.onComplete(true, walletAddress); // Pass true for hasWallet and the address
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _walletError = 'Failed to save wallet: ${e.toString().replaceAll('Exception: ', '')}';
          _continueBtnClicked = false; // Reset button state so user can try again
        });
      }
    }
  }

  // Add this helper method to validate Ethereum addresses
  bool _isValidEthereumAddress(String address) {
    // Check if address starts with 0x and has exactly 42 characters
    if (!address.startsWith('0x') || address.length != 42) {
      return false;
    }
    
    // Check if the remaining characters are valid hexadecimal
    final hexPart = address.substring(2);
    return RegExp(r'^[a-fA-F0-9]+$').hasMatch(hexPart);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bot message
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bot avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Message bubble
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blockchain Wallet Setup',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Reassuring explanation section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'What is this for?',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your wallet serves only as a secure digital identifier to ensure the traceability and authenticity of your experiences, certificates, and diplomas. No cryptocurrencies are involved, and this is not a financial tool. Think of it as a secure digital signature that proves your achievements are genuine.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showPasswordForm 
                              ? 'Please set a secure password to encrypt your wallet:'
                              : 'Do you already have a blockchain wallet address?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Error messages
                        if (_walletError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _walletError!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        if (_passwordError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _passwordError!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Wallet choice buttons
                        if (_hasWallet == null && !_showPasswordForm) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleWalletChoice(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Yes, I have one'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleWalletChoice(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Create new'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        // Password setup form
                        if (_showPasswordForm && !_isCreatingWallet) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.security, color: Colors.blue.shade600, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Wallet Security Setup',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your wallet will be encrypted with this password. Make sure to remember it!',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Password field
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onChanged: (value) {
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter a secure password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Confirm password field
                                TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  onChanged: (value) {
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    hintText: 'Confirm your password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Password requirements
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '• Password must be at least 8 characters long\n• Make sure both passwords match\n• Remember this password - you\'ll need it to access your wallet',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _showPasswordForm = false;
                                            _hasWallet = null;
                                            _passwordController.clear();
                                            _confirmPasswordController.clear();
                                            _passwordError = null;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade600,
                                          side: BorderSide(color: Colors.grey.shade300),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Back'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _createWallet,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF7B3FE4),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Create Wallet'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Wallet input for existing wallet
                        if (_hasWallet == true) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Please enter your wallet address:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Update the wallet input TextField to trigger rebuilds
                          TextField(
                            controller: _walletController,
                            onChanged: (value) {
                              setState(() {
                                if (_walletError != null) {
                                  _walletError = null;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '0xd8b897360A5483477d1544EC48590bA25eb26cFb',
                              helperText: 'Enter your 42-character Ethereum address starting with 0x',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _walletError != null ? Colors.red : Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _walletError != null ? Colors.red : Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _walletError != null ? Colors.red : const Color(0xFF7B3FE4),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.account_balance_wallet),
                            ),
                            maxLines: 1,
                            style: GoogleFonts.robotoMono(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          if (!_continueBtnClicked)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (_walletController.text.trim().isNotEmpty && 
                                            !_isValidatingWallet && 
                                            _isValidEthereumAddress(_walletController.text.trim())) 
                                    ? _validateAndSubmitWallet 
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7B3FE4),
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isValidatingWallet
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Continue', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                        ],
                        
                        // Wallet creation flow
                        if (_hasWallet == false) ...[
                          const SizedBox(height: 16),
                          if (!_isCreatingWallet && _walletController.text.isEmpty && !_showPasswordForm) ...[
                            Text(
                              'I\'ll create a new secure wallet for you:',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _showPasswordSetup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7B3FE4),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                                label: const Text('Generate Wallet', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                          
                          if (_isCreatingWallet) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Creating your secure blockchain wallet...',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          if (_walletController.text.isNotEmpty && !_isCreatingWallet && !_showPasswordForm) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Wallet Created Successfully!',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Address: ${_walletController.text}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.yellow.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.security, size: 14, color: Colors.yellow.shade700),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Your wallet is encrypted and secure. Remember your password!',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.yellow.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Add this section after the wallet creation loading state and before the existing success message
        if (_showWalletKeys && _walletController.text.isNotEmpty && _privateKey != null) ...[
          const SizedBox(height: 20),
          
          // Add the same container structure as the chat bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bot avatar (matching other sections)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Message bubble with wallet keys (matching width of other chat bubbles)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade50, Colors.orange.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: Colors.red.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '⚠️ IMPORTANT: Save Your Wallet Keys',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CRITICAL SECURITY NOTICE:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• We DO NOT store your private key on our servers\n'
                              '• You are the ONLY person responsible for keeping these keys safe\n'
                              '• If you lose your private key, you will permanently lose access to your wallet\n'
                              '• Never share your private key with anyone\n'
                              '• Store these keys in a secure location (password manager, secure note, etc.)',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Public Address (Wallet Address)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: Colors.blue.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Public Address (Share this to receive funds)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SelectableText(
                                _walletController.text,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _walletController.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Public address copied to clipboard!'),
                                      backgroundColor: Colors.green.shade600,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copy Public Address'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue.shade600,
                                  side: BorderSide(color: Colors.blue.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Private Key
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.key, color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Private Key (NEVER SHARE THIS!)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: SelectableText(
                                _privateKey!,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _privateKey!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Private key copied to clipboard! Store it safely!'),
                                      backgroundColor: Colors.orange.shade600,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copy Private Key'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  side: BorderSide(color: Colors.red.shade400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Acknowledgment checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _keysAcknowledged,
                            onChanged: (value) {
                              setState(() {
                                _keysAcknowledged = value ?? false;
                              });
                            },
                            activeColor: Colors.green.shade600,
                          ),
                          Expanded(
                            child: Text(
                              'I understand that I am solely responsible for keeping my private key safe and that SolidCV does not store it.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Continue button - only show if not clicked yet
                      if (!_continueBtnClicked) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _keysAcknowledged ? _submitCreatedWallet : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _keysAcknowledged ? Colors.green.shade600 : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: Text(
                              'I\'ve Saved My Keys - Continue',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Show a processing message instead
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Saving wallet configuration...',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],

        // Remove or comment out the old success message section
        // if (_walletController.text.isNotEmpty && !_isCreatingWallet && !_showPasswordForm) ...
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _walletController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}