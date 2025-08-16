import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/FirstConfigurationComponents/AISkillValidationStep.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/User.dart';
import 'FirstConfigurationComponents/WelcomeMessage.dart';
import 'FirstConfigurationComponents/WalletStep.dart';
import 'FirstConfigurationComponents/CVUploadStep.dart';
import 'FirstConfigurationComponents/CompletionStep.dart';
import 'FirstConfigurationComponents/ExperienceEditStep.dart';
import 'FirstConfigurationComponents/CertificateEditStep.dart';
import 'FirstConfigurationComponents/SkillsEditStep.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/models/Skill.dart';

class FirstConfiguration extends StatefulWidget {
  const FirstConfiguration({super.key});

  @override
  State<FirstConfiguration> createState() => _FirstConfigurationState();
}

class _FirstConfigurationState extends State<FirstConfiguration>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  
  int _currentStep = 0;
  final int _totalSteps = 7; // Increased from 6 to 7
  late Future<User> _user;
  final UserBll _userBll = UserBll();

  // Configuration data
  bool? _hasWallet;
  String? _walletAddress;
  String? _uploadedCVPath;
  Map<String, dynamic>? _extractedData;
  
  // Add these to store the final edited data
  List<Map<String, dynamic>>? _finalExperiences;
  List<Map<String, dynamic>>? _finalCertificates;
  List<Map<String, dynamic>>? _finalSkills;
  List<Map<String, dynamic>>? _validatedSkills; // New field for validated skills
  
  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);

  @override
  void initState() {
    super.initState();
    _checkWalletStatus();
    _user = _userBll.getCurrentUser();
  }

  // Check if user already has a wallet and skip the wallet step if they do
  void _checkWalletStatus() async {
    // TODO: Replace this with actual wallet check logic
    // You might want to check SharedPreferences, secure storage, or call your BLL
    bool userHasWallet = await _checkIfUserHasWallet();
    
    if (userHasWallet) {
      // Skip wallet step by setting it as completed
      setState(() {
        _hasWallet = true;
        _walletAddress = "existing_wallet_address"; // Get the actual address
      });
    }
  }

  // TODO: Implement this method to check if user has a wallet
  Future<bool> _checkIfUserHasWallet() async {
    var user = await _userBll.getCurrentUser();
    return user.ethereumAddress != null;
  }

  void _nextStep() {
    print('DEBUG: _nextStep called, current step: $_currentStep, total steps: $_totalSteps');
    
    setState(() {
      _currentStep++;
      
      // Skip wallet step if user already has a wallet
      if (_currentStep == 1 && _hasWallet == true) {
        _currentStep = 2; // Skip directly to CV upload
      }
    });
    
    print('DEBUG: After _nextStep, current step: $_currentStep');
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onWalletStepComplete(bool hasWallet, String? walletAddress) {
    setState(() {
      _hasWallet = hasWallet;
      _walletAddress = walletAddress;
    });
    _nextStep();
  }

  void _onCVUploadComplete(String? cvPath, Map<String, dynamic>? extractedData) {
    setState(() {
      _uploadedCVPath = cvPath;
      _extractedData = extractedData;
    });
    _nextStep();
  }

  void _completeConfiguration() {
    // Here you can access all the final data:
    // _hasWallet, _walletAddress
    // _uploadedCVPath
    // _finalExperiences, _finalCertificates, _finalSkills
    
    // Save configuration data to your backend or local storage
    print('Configuration completed with:');
    print('Wallet: $_hasWallet, Address: $_walletAddress');
    print('CV Path: $_uploadedCVPath');
    print('Experiences: ${_finalExperiences?.length ?? 0}');
    print('Certificates: ${_finalCertificates?.length ?? 0}');
    print('Skills: ${_finalSkills?.length ?? 0}');
    
    // Navigate to main app
    Navigator.pushNamed(context, '/loggedin/home');
  }

  void _onExperienceEditComplete(List<ManualExperience> experiences) {
    setState(() {
      // Convert ManualExperience objects to Map format if needed for storage
      _finalExperiences = experiences.map((exp) => {
        'title': exp.title,
        'company': exp.company,
        'startDate': exp.startDateAsTimestamp,
        'endDate': exp.endDateAsTimestamp,
        'description': exp.description,
        'promotions': exp.promotions,
      }).toList();
      
      _extractedData = _extractedData ?? {};
      _extractedData!['experiences'] = _finalExperiences;
    });
    _nextStep();
  }

  void _onCertificateEditComplete(List<Certificate> certificates) {
    setState(() {
      // Convert ManualCertificate objects to Map format if needed for storage
      _finalCertificates = certificates.map((cert) => {
        'title': cert.title,
        'teachingInstitutionName': cert.teachingInstitutionName,
        'publicationDate': cert.publicationDate,
        'description': cert.description,
      }).toList();
      
      _extractedData = _extractedData ?? {};
      _extractedData!['certificates'] = _finalCertificates;
    });
    _nextStep();
  }

  void _onSkillsEditComplete(List<Skill> skills) {
    _userBll.setFirstConfigurationDone();
    setState(() {
      // Convert ManualSkill objects to Map format if needed for storage
      _finalSkills = skills.map((skill) => {
        'name': skill.name,
        'id': skill.id,
        'isValidated': false, // Add validation status
      }).toList();
      
      _extractedData = _extractedData ?? {};
      _extractedData!['skills'] = _finalSkills;
    });
    _nextStep();
  }

  // New method for skill validation completion
  void _onSkillValidationComplete(List<Map<String, dynamic>> validatedSkills) {
    print('DEBUG: _onSkillValidationComplete called');
    print('DEBUG: Current step before: $_currentStep');
    
    setState(() {
      _validatedSkills = validatedSkills;
      _extractedData = _extractedData ?? {};
      _extractedData!['validatedSkills'] = _validatedSkills;
    });
    
    print('DEBUG: About to call _nextStep()');
    _nextStep();
    
    print('DEBUG: Current step after _nextStep(): $_currentStep');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: Text(
          'Account Setup',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentStep + 1}/$_totalSteps',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientStart.withOpacity(0.1), _gradientEnd.withOpacity(0.05)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Progress indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                minHeight: 4,
              ),
            ),
            
            // Chat interface
            Expanded(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 600,
                ),
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 32),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      WelcomeMessage(
                        onStartSetup: () {
                          _nextStep();
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Dynamic steps - Only show wallet step if user doesn't have one
                      if (_currentStep >= 1 && _hasWallet != true) ...[
                        WalletStep(
                          onComplete: _onWalletStepComplete,
                          isActive: _currentStep == 1,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Show a message if wallet step was skipped
                      if (_currentStep >= 1 && _hasWallet == true && _currentStep == 1) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wallet Already Connected',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Your blockchain wallet is already set up. Proceeding to CV upload.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep >= 2) ...[
                        CVUploadStep(
                          onComplete: _onCVUploadComplete,
                          onSkip: () => _onCVUploadComplete(null, null),
                          isActive: _currentStep == 2,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep >= 3 && _extractedData != null) ...[
                        ExperienceEditStep(
                          onComplete: _onExperienceEditComplete,
                          isActive: _currentStep == 3,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep >= 4 && _extractedData != null) ...[
                        CertificateEditStep(
                          onComplete: _onCertificateEditComplete,
                          isActive: _currentStep == 4,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep >= 5 && _extractedData != null) ...[
                        SkillsEditStep(
                          onComplete: _onSkillsEditComplete,
                          isActive: _currentStep == 5,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // AI Skill Validation Step
                      if (_currentStep == 6 && _finalSkills != null && _finalSkills!.isNotEmpty) ...[
                        AISkillValidationStep(
                          skills: _finalSkills!,
                          onComplete: _onSkillValidationComplete,
                          isActive: _currentStep == 6,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Completion step - Changed condition to be more explicit
                      if (_currentStep == 7) ...[  // Changed from >= _totalSteps to == 7
                        CompletionStep(
                          hasWallet: _hasWallet,
                          walletAddress: _walletAddress,
                          hasCVUploaded: _uploadedCVPath != null,
                          onComplete: _completeConfiguration,
                          isActive: _currentStep == 7,  // Changed from >= _totalSteps
                        ),
                      ],
                      
                      const SizedBox(height: 100), // Extra space for scrolling
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentStep == 0
          ? FloatingActionButton.extended(
              onPressed: _nextStep,
              backgroundColor: _primaryColor,
              icon: const Icon(Icons.chat, color: Colors.white),
              label: Text(
                'Start Setup',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}