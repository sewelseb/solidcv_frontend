import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeStep extends StatelessWidget {
  final Function({Map<String, dynamic>? data}) onNext;
  final VoidCallback onPrevious;

  const WelcomeStep({super.key, required this.onNext, required this.onPrevious});

  List<String> _getBenefits(BuildContext context) {
    return [
      AppLocalizations.of(context)!.personalizedCareerRecommendations,
      AppLocalizations.of(context)!.skillsGapAnalysis,
      AppLocalizations.of(context)!.industryInsights,
      AppLocalizations.of(context)!.nextStepsCareerGrowth,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final Color primaryColor = const Color(0xFF7B3FE4);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add some top spacing for mobile to center content better
          SizedBox(height: isMobile ? 20 : 40),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
            ),
            child: Icon(
              Icons.psychology, 
              color: Colors.white, 
              size: isMobile ? 40 : 48,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Text(
            AppLocalizations.of(context)!.welcomeToAICareerAdvisor,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            AppLocalizations.of(context)!.careerJourneyDescription,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14 : 16,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.whatYoullGet,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                ..._getBenefits(context).map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle, 
                        color: primaryColor, 
                        size: isMobile ? 18 : 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 13 : 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 32 : 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onNext(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.letsGetStarted,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Add bottom spacing for mobile
          SizedBox(height: isMobile ? 20 : 0),
        ],
      ),
    );
  }
}