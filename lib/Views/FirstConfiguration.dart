import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/models/Certificate.dart';
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
  final int _totalSteps = 6;
  
  // Configuration data
  bool? _hasWallet;
  String? _walletAddress;
  String? _uploadedCVPath;
  Map<String, dynamic>? _extractedData;
  
  // Add these to store the final edited data
  List<Map<String, dynamic>>? _finalExperiences;
  List<Map<String, dynamic>>? _finalCertificates;
  List<Map<String, dynamic>>? _finalSkills;
  
  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _scrollToBottom();
    }
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
    Navigator.pushReplacementNamed(context, '/loggedin/home');
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
    setState(() {
      // Convert ManualSkill objects to Map format if needed for storage
      _finalSkills = skills.map((skill) => {
        'name': skill.name,
        // Add other fields if your ManualSkill model has them
      }).toList();
      
      _extractedData = _extractedData ?? {};
      _extractedData!['skills'] = _finalSkills;
    });
    _nextStep();
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
                          _nextStep(); // This will move to the next step in your configuration flow
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Dynamic steps
                      if (_currentStep >= 1) ...[
                        WalletStep(
                          onComplete: _onWalletStepComplete,
                          isActive: _currentStep == 1,
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
                          //experiences: _extractedData!['experiences'] ?? [],
                          onComplete: _onExperienceEditComplete,
                          isActive: _currentStep == 3,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep >= 4 && _extractedData != null) ...[
                        CertificateEditStep(
                          //certificates: _extractedData!['certificates'] ?? [],
                          onComplete: _onCertificateEditComplete,
                          isActive: _currentStep == 4,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep >= 5 && _extractedData != null) ...[
                        SkillsEditStep(
                          //skills: _extractedData!['skills'] ?? [],
                          onComplete: _onSkillsEditComplete,
                          isActive: _currentStep == 5,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      if (_currentStep == _totalSteps - 1) ...[
                        CompletionStep(
                          hasWallet: _hasWallet,
                          walletAddress: _walletAddress,
                          hasCVUploaded: _uploadedCVPath != null,
                          onComplete: _completeConfiguration,
                          isActive: _currentStep == _totalSteps - 1,
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