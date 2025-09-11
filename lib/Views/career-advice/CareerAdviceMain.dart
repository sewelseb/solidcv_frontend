import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/career-advice/steps/CVCheckStep.dart';
import 'package:solid_cv/Views/career-advice/steps/WelcomeStep.dart';
import 'package:solid_cv/Views/career-advice/steps/CareerGoalsStep.dart';
import 'package:solid_cv/Views/career-advice/steps/IndustryPreferencesStep.dart';
import 'package:solid_cv/Views/career-advice/steps/AdviceResultsStep.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class CareerAdviceMain extends StatefulWidget {
  const CareerAdviceMain({super.key});

  @override
  State<CareerAdviceMain> createState() => _CareerAdviceMainState();
}

class _CareerAdviceMainState extends State<CareerAdviceMain> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  // Data collected during the process
  Map<String, dynamic> _careerData = {};
  
  final Color _primaryColor = const Color(0xFF7B3FE4);

  List<String> _getStepTitles(BuildContext context) {
    return [
      AppLocalizations.of(context)!.cvCheck,
      AppLocalizations.of(context)!.welcome,
      AppLocalizations.of(context)!.careerGoals,
      AppLocalizations.of(context)!.industryPreferences,
      AppLocalizations.of(context)!.yourCareerAdvice,
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep({Map<String, dynamic>? data}) {
    if (data != null) {
      setState(() {
        _careerData.addAll(data);
      });
    }
    
    if (_currentStep < _getStepTitles(context).length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _restartProcess() {
    setState(() {
      _currentStep = 0;
      _careerData = {};
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.careerAdvisor,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _showRestartDialog(),
              tooltip: AppLocalizations.of(context)!.restartProcess,
            ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(isMobile),
          
          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CVCheckStep(onNext: _nextStep),
                WelcomeStep(onNext: _nextStep, onPrevious: _previousStep),
                CareerGoalsStep(onNext: _nextStep, onPrevious: _previousStep),
                IndustryPreferencesStep(onNext: _nextStep, onPrevious: _previousStep),
                AdviceResultsStep(
                  careerData: _careerData,
                  onRestart: _restartProcess,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isMobile) {
    final stepTitles = _getStepTitles(context);
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stepTitles[_currentStep],
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
              Text(
                '${_currentStep + 1} / ${stepTitles.length}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentStep + 1) / stepTitles.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.restartCareerAdvisor),
        content: Text(AppLocalizations.of(context)!.restartConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartProcess();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.restart),
          ),
        ],
      ),
    );
  }
}