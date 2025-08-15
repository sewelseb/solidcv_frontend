import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeStep extends StatelessWidget {
  final Function({Map<String, dynamic>? data}) onNext;
  final VoidCallback onPrevious;

  const WelcomeStep({super.key, required this.onNext, required this.onPrevious});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final Color primaryColor = const Color(0xFF7B3FE4);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Your AI Career Advisor',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'I\'m here to help you navigate your career journey. Based on your CV and preferences, I\'ll provide personalized advice to help you achieve your professional goals.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'What you\'ll get:',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ...[
                  'Personalized career recommendations',
                  'Skills gap analysis and improvement tips',
                  'Industry insights and trends',
                  'Next steps for your career growth',
                ].map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: GoogleFonts.inter(
                            fontSize: 14,
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
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onNext(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Let\'s Get Started!'),
            ),
          ),
        ],
      ),
    );
  }
}